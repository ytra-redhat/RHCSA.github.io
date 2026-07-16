#!/usr/bin/env python3
"""Blocker release validation for the RHCSA simulator."""

from __future__ import annotations

import argparse
import json
import py_compile
import re
import subprocess
import os
import socket
import time
import urllib.request
from pathlib import Path

REQUIRED_FIELDS = ("IS_LAB", "LAB_ID", "LAB_VERSION", "QUESTION", "LAB_TASK_COUNT")
REQUIRED_FUNCTIONS = ("prepare_lab", "check_tasks", "cleanup_lab")
STATIC_CHAPTER_PATTERNS = (
    re.compile(r"\{1\.\.10\}"),
    re.compile(r"range\(\s*10\s*\)"),
    re.compile(r"range\(\s*1\s*,\s*11\s*\)"),
    re.compile(r"const\s+objectivesData\s*=\s*\["),
)
PLACEHOLDER_PATTERN = re.compile(
    r"\b(no questions available|geen vragen beschikbaar|coming soon|placeholder|tbd)\b",
    re.IGNORECASE,
)


def parse_assignment(content: str, name: str) -> str | None:
    match = re.search(
        rf"(?m)^[ \t]*{re.escape(name)}[ \t]*=[ \t]*([\"'])(.*?)\1[ \t]*$",
        content,
    )
    return match.group(2) if match else None


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "repository_root",
        nargs="?",
        type=Path,
        default=Path(__file__).resolve().parents[2],
    )
    args = parser.parse_args()
    repo_root = args.repository_root.resolve()
    simulator = repo_root / "RHCSA_EX200_Exam_Simulator"
    questions = simulator / "questions"
    installer = repo_root / "Install_RHCSA_EX200_Exam_Simulator.sh"
    errors: list[str] = []
    warnings: list[str] = []

    config = repo_root / "config" / "repository.env"
    if not config.is_file():
        errors.append("missing central config/repository.env")
        expected_repo = ""
    else:
        config_text = config.read_text(encoding="utf-8", errors="replace")
        assignments = re.findall(
            r"(?m)^[ \t]*RHCSA_GITHUB_REPOSITORY[ \t]*=[ \t]*[\"']([^\"']+)[\"']",
            config_text,
        )
        if len(assignments) != 1:
            errors.append(
                f"expected exactly one RHCSA_GITHUB_REPOSITORY assignment, found {len(assignments)}"
            )
            expected_repo = assignments[0] if assignments else ""
        else:
            expected_repo = assignments[0]
        if expected_repo != "ytra-redhat/RHCSA.github.io":
            errors.append(
                f"repository must be ytra-redhat/RHCSA.github.io, found {expected_repo!r}"
            )
        branch_assignments = re.findall(
            r"(?m)^[ \t]*RHCSA_GITHUB_BRANCH[ \t]*=[ \t]*[\"']([^\"']+)[\"']",
            config_text,
        )
        if branch_assignments != ["main"]:
            errors.append(
                "RHCSA_GITHUB_BRANCH must be assigned exactly once as main; "
                f"found: {branch_assignments}"
            )

    required_runtime_files = {
        simulator / "webui" / "rhcsa-webui.service": (
            "ExecStart=/usr/bin/python3 /usr/local/share/rhcsa/webui/server.py"
        ),
        simulator / "systemd" / "rhcsa-terminal.service": (
            "ExecStartPre=/usr/bin/tmux new-session -d -s rhcsa-terminal -c /tmp"
        ),
        simulator / "systemd" / "rhcsa-update.service": (
            "ExecStart=/usr/local/share/rhcsa/scripts/rhcsa-update --auto"
        ),
        simulator / "systemd" / "rhcsa-update.timer": "[Timer]",
        simulator / "scripts" / "install-systemd-units.sh": "install_unit",
        simulator / "scripts" / "repair-systemd-units.sh": (
            "install-systemd-units.sh"
        ),
    }
    for required_file, required_text in required_runtime_files.items():
        if not required_file.is_file():
            errors.append(
                f"missing required runtime file: {required_file.relative_to(repo_root)}"
            )
            continue
        content = required_file.read_text(encoding="utf-8", errors="replace")
        if required_text not in content:
            errors.append(
                f"{required_file.relative_to(repo_root)}: missing required content "
                f"{required_text!r}"
            )

    if installer.is_file():
        installer_text = installer.read_text(encoding="utf-8", errors="replace")
        if 'install-systemd-units.sh" --install-only' not in installer_text:
            errors.append(
                "installer must deploy systemd units through install-systemd-units.sh"
            )
        if re.search(
            r"cp\s+-a\s+[^\n]*(rhcsa-webui\.service|rhcsa-update\.(service|timer))",
            installer_text,
        ):
            errors.append(
                "installer must not copy systemd units with cp -a; stale destination "
                "directories and symlinks must be removed first"
            )
        if "wait_for_runtime" not in installer_text:
            errors.append("installer must perform a runtime readiness check")
        if "show_access_urls" not in installer_text:
            errors.append("installer must display detected Web UI IP addresses")
        if "rhcsa-terminal.service" not in installer_text:
            errors.append("installer must manage the dedicated terminal service")
    else:
        errors.append("top-level installer is missing")

    if not questions.is_dir():
        errors.append("questions directory is missing")
        chapter_dirs: list[Path] = []
    else:
        chapter_dirs = sorted(
            (p for p in questions.iterdir() if p.is_dir() and p.name.isdigit()),
            key=lambda p: int(p.name),
        )

    if not chapter_dirs:
        errors.append("no numeric question chapters found")

    labs: list[Path] = []
    chapter_counts: dict[str, int] = {}
    for chapter in chapter_dirs:
        active = sorted(chapter.glob("lab_*.sh"))
        chapter_counts[chapter.name] = len(active)
        if not active:
            errors.append(f"empty chapter: {chapter.relative_to(repo_root)}")
        labs.extend(active)

    lab_ids: dict[str, list[str]] = {}
    for lab in labs:
        rel = str(lab.relative_to(repo_root))
        if lab.is_symlink():
            errors.append(f"symlinked lab is not allowed: {rel}")
            continue
        result = subprocess.run(
            ["bash", "-n", str(lab)], capture_output=True, text=True
        )
        if result.returncode:
            errors.append(f"Bash syntax error in {rel}: {result.stderr.strip()}")
            continue

        content = lab.read_text(encoding="utf-8", errors="replace")
        for field in REQUIRED_FIELDS:
            if not re.search(rf"(?m)^[ \t]*{re.escape(field)}=", content):
                errors.append(f"{rel}: missing {field}")
        for function in REQUIRED_FUNCTIONS:
            if not re.search(
                rf"(?m)^[ \t]*{re.escape(function)}[ \t]*\(\)[ \t]*\{{",
                content,
            ):
                errors.append(f"{rel}: missing function {function}()")

        lab_id = parse_assignment(content, "LAB_ID")
        if lab_id:
            lab_ids.setdefault(lab_id, []).append(rel)
        else:
            errors.append(f"{rel}: LAB_ID is not a quoted stable value")

        task_count_match = re.search(r"(?m)^[ \t]*LAB_TASK_COUNT=(\d+)", content)
        if task_count_match:
            task_count = int(task_count_match.group(1))
            for task in range(1, task_count + 1):
                for suffix in ("QUESTION", "HINT"):
                    if not re.search(
                        rf"(?m)^[ \t]*TASK_{task}_{suffix}[ \t]*=",
                        content,
                    ):
                        errors.append(f"{rel}: missing TASK_{task}_{suffix}")
        if re.search(r"\btmux\b", content, re.IGNORECASE):
            errors.append(f"{rel}: tmux is forbidden in active questions")
        if re.search(r"echo[ \t]+\$\?|TASK_[0-9]+.*RC:|return.?code", content):
            errors.append(f"{rel}: artificial return-code task detected")

    for lab_id, paths in lab_ids.items():
        if len(paths) > 1:
            errors.append(f"duplicate LAB_ID {lab_id}: {', '.join(paths)}")

    source_script = r'''
set -e
_build_hint() { :; }
source "$1"
declare -F prepare_lab >/dev/null
declare -F check_tasks >/dev/null
declare -F cleanup_lab >/dev/null
'''
    for lab in labs:
        result = subprocess.run(
            ["bash", "-c", source_script, "bash", str(lab)],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode:
            errors.append(
                f"lab cannot be safely sourced: {lab.relative_to(repo_root)}: "
                f"{result.stderr.strip()}"
            )

    for shell in sorted(repo_root.rglob("*.sh")):
        if ".git" in shell.parts:
            continue
        result = subprocess.run(
            ["bash", "-n", str(shell)], capture_output=True, text=True
        )
        if result.returncode:
            errors.append(
                f"Bash syntax error in {shell.relative_to(repo_root)}: "
                f"{result.stderr.strip()}"
            )
    rhcsa = simulator / "rhcsa"
    if rhcsa.is_file():
        result = subprocess.run(
            ["bash", "-n", str(rhcsa)], capture_output=True, text=True
        )
        if result.returncode:
            errors.append(f"Bash syntax error in rhcsa: {result.stderr.strip()}")

    for py_file in sorted(repo_root.rglob("*.py")):
        if "__pycache__" in py_file.parts:
            continue
        try:
            py_compile.compile(str(py_file), doraise=True)
        except Exception as exc:
            errors.append(f"Python compile error in {py_file.relative_to(repo_root)}: {exc}")

    text_suffixes = {
        ".sh", ".py", ".js", ".html", ".md", ".txt", ".service", ".timer", ".json", ".env"
    }
    central_assignments = []
    for path in sorted(repo_root.rglob("*")):
        if not path.is_file() or ".git" in path.parts:
            continue
        rel = str(path.relative_to(repo_root))
        if path.name.startswith("._") or "__MACOSX" in path.parts:
            errors.append(f"Apple metadata is forbidden: {rel}")
            continue
        if path.suffix.lower() not in text_suffixes and path.name != "rhcsa":
            continue
        try:
            content = path.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        is_reference_document = (
            "contents" in path.parts
            or "docs" in path.parts
            or path.name.lower().startswith("requirements")
        )
        # Every concrete RHCSA GitHub URL must refer to the configured fork.
        # Template-derived URLs such as ${RHCSA_GITHUB_REPOSITORY} and
        # {repository} remain allowed because they resolve from central config.
        concrete_urls = re.findall(
            r"https://(?:github\.com|raw\.githubusercontent\.com|api\.github\.com/repos)/[^\s\"'<>)]*",
            content,
        )
        for url in concrete_urls:
            if "${RHCSA_GITHUB_REPOSITORY}" in url or "{repository}" in url:
                continue
            if "RHCSA.github.io" not in url:
                errors.append(f"non-RHCSA GitHub URL in {rel}: {url}")
                continue
            if "ytra-redhat/RHCSA.github.io" not in url:
                errors.append(f"GitHub URL outside configured fork in {rel}: {url}")
        if not is_reference_document:
            for _ in re.finditer(
                r"(?m)^[ \t]*RHCSA_GITHUB_REPOSITORY[ \t]*=", content
            ):
                central_assignments.append(rel)
        if path != config and not is_reference_document:
            for pattern in STATIC_CHAPTER_PATTERNS:
                if pattern.search(content):
                    errors.append(f"hardcoded ten-chapter pattern in {rel}")
                    break
        if path.is_relative_to(questions) and PLACEHOLDER_PATTERN.search(content):
            errors.append(f"question placeholder content in {rel}")

    if central_assignments != ["config/repository.env"]:
        errors.append(
            "RHCSA_GITHUB_REPOSITORY must be assigned only in config/repository.env; "
            f"found: {central_assignments}"
        )

    # Runtime smoke test: start the actual Web UI on an ephemeral port and
    # verify that it returns the same dynamically discovered chapters.
    server_py = simulator / "webui" / "server.py"
    if server_py.is_file() and chapter_dirs:
        sock = socket.socket()
        sock.bind(("127.0.0.1", 0))
        smoke_port = sock.getsockname()[1]
        sock.close()
        env = os.environ.copy()
        env["RHCSA_INSTALL_DIR"] = str(simulator)
        env["RHCSA_WEBUI_PORT"] = str(smoke_port)
        process = subprocess.Popen(
            ["python3", str(server_py)],
            cwd=str(simulator / "webui"),
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        try:
            payload = None
            last_error = ""
            for _ in range(50):
                if process.poll() is not None:
                    break
                try:
                    with urllib.request.urlopen(
                        f"http://127.0.0.1:{smoke_port}/api/objectives",
                        timeout=1,
                    ) as response:
                        payload = json.load(response)
                    break
                except Exception as exc:
                    last_error = str(exc)
                    time.sleep(0.1)
            if not isinstance(payload, list):
                if process.poll() is None:
                    process.terminate()
                stdout, stderr = process.communicate(timeout=3)
                errors.append(
                    "Web UI runtime smoke test failed: "
                    f"{last_error}; stdout={stdout.strip()!r}; stderr={stderr.strip()!r}"
                )
            else:
                returned = [str(item.get("id")) for item in payload]
                expected = [chapter.name for chapter in chapter_dirs]
                if returned != expected:
                    errors.append(
                        f"Web UI runtime chapter mismatch: expected {expected}, got {returned}"
                    )
        finally:
            if process.poll() is None:
                process.terminate()
                try:
                    process.wait(timeout=3)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait(timeout=3)


    expected_content_chapters = {"11", "12"}
    found_content_chapters = {
        match.group(1)
        for path in (repo_root / "contents").iterdir()
        if path.is_dir() and (match := re.match(r"^(\d+)-", path.name))
    } if (repo_root / "contents").is_dir() else set()
    missing_content = sorted(expected_content_chapters - found_content_chapters)
    if missing_content:
        errors.append(f"missing contents chapters: {missing_content}")

    web_index = simulator / "webui" / "index.html"
    if web_index.is_file():
        web_text = web_index.read_text(encoding="utf-8", errors="replace")
        if "chapters loaded" not in web_text:
            errors.append("Web UI must display the dynamically loaded chapter count")
        if "questions.length > 0 ?" not in web_text:
            errors.append("Web UI must render every discovered objective even if question loading fails")
        if "Failed to start lab: " not in web_text:
            errors.append("Web UI must show the concrete lab start error")

    terminal_unit = simulator / "systemd" / "rhcsa-terminal.service"
    if terminal_unit.is_file():
        terminal_text = terminal_unit.read_text(encoding="utf-8", errors="replace")
        for required in (
            "ExecStartPre=/usr/bin/tmux new-session -d -s rhcsa-terminal -c /tmp",
            "/usr/bin/tmux attach-session -t rhcsa-terminal",
        ):
            if required not in terminal_text:
                errors.append(f"terminal service missing original tmux lifecycle: {required}")

    server_file = simulator / "webui" / "server.py"
    if server_file.is_file():
        server_text = server_file.read_text(encoding="utf-8", errors="replace")
        if "def ensure_terminal_session()" not in server_text:
            errors.append("server must recover a missing tmux session")
        if 'metadata["preparation_warning"]' not in server_text:
            errors.append("prepare_lab failures must be non-fatal as in the original simulator")

    summary = {
        "repository": expected_repo,
        "chapters": chapter_counts,
        "chapter_count": len(chapter_counts),
        "lab_count": len(labs),
        "unique_lab_ids": len(lab_ids),
        "errors": errors,
        "warnings": warnings,
    }
    print(json.dumps(summary, indent=2, sort_keys=True))
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
