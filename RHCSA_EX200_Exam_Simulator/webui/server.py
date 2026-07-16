#!/usr/bin/env python3
"""RHCSA Exam Simulator Web API."""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import urllib.request
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

INSTALL_DIR = Path(
    os.environ.get(
        "RHCSA_INSTALL_DIR",
        str(Path(__file__).resolve().parents[1]),
    )
).resolve()
WEBUI_DIR = INSTALL_DIR / "webui"
QUESTIONS_DIR = INSTALL_DIR / "questions"
PROGRESS_FILE = INSTALL_DIR / "progress.json"
VERSION_FILE = INSTALL_DIR / ".version"
UPDATE_STATE_FILE = Path("/var/lib/rhcsa/update-state.json")
UPDATE_LOG_FILE = Path("/var/log/rhcsa/update.log")
TMUX_SESSION = "rhcsa-terminal"
WEBUI_PORT = int(os.environ.get("RHCSA_WEBUI_PORT", "8080"))

sys.path.insert(0, str(INSTALL_DIR))
from lib.progress import ProgressStore  # noqa: E402

PROGRESS = ProgressStore(PROGRESS_FILE, QUESTIONS_DIR)
VALIDATION_MODE = os.environ.get(
    "RHCSA_VALIDATION_MODE", ""
).strip().lower() in {"1", "true", "yes"}

# Normal runtime performs the legacy progress migration. The release validator
# skips this expensive startup operation only for its temporary HTTP smoke test.
if not VALIDATION_MODE:
    PROGRESS.migrate_legacy(
        [INSTALL_DIR / ".progress", Path("/tmp/.rhcsa_progress")]
    )


def load_repository_config() -> dict[str, str]:
    candidates = [
        INSTALL_DIR / "config" / "repository.env",
        INSTALL_DIR.parent / "config" / "repository.env",
    ]
    values: dict[str, str] = {}
    for candidate in candidates:
        if not candidate.is_file():
            continue
        for raw_line in candidate.read_text(
            encoding="utf-8", errors="replace"
        ).splitlines():
            line = raw_line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            values[key.strip()] = value.strip().strip('"').strip("'")
        break

    repository = values.get("RHCSA_GITHUB_REPOSITORY", "")
    branch = values.get("RHCSA_GITHUB_BRANCH", "")
    if repository != "ytra-redhat/RHCSA.github.io" or branch != "main":
        raise RuntimeError("Invalid or missing central repository configuration")

    web_url = f"https://github.com/{repository}"
    api_url = f"https://api.github.com/repos/{repository}"
    raw_url = f"https://raw.githubusercontent.com/{repository}/{branch}"
    return {
        "repository": repository,
        "branch": branch,
        "web_url": web_url,
        "api_url": api_url,
        "raw_url": raw_url,
        "archive_url": f"{web_url}/archive/refs/heads/{branch}.tar.gz",
        "installer_url": f"{raw_url}/Install_RHCSA_EX200_Exam_Simulator.sh",
    }


def load_objective_titles() -> dict[str, str]:
    path = INSTALL_DIR / "objective_titles.json"
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError, TypeError):
        return {}
    return {str(key): str(value) for key, value in data.items()}


def natural_key(value: str):
    return [int(part) if part.isdigit() else part.lower()
            for part in re.split(r"(\d+)", value)]


def parse_shell_assignment(content: str, name: str) -> str | None:
    """Read a quoted shell metadata assignment without executing the lab."""
    pattern = re.compile(
        rf"(?ms)^[ \t]*{re.escape(name)}[ \t]*=[ \t]*"
        rf"(?P<quote>[\"'])(?P<value>.*?)(?P=quote)[ \t]*$"
    )
    match = pattern.search(content)
    if not match:
        return None
    value = match.group("value")
    return (
        value.replace(r"\"", '"')
        .replace(r"\'", "'")
        .replace(r"\$", "$")
    )


def parse_integer_assignment(content: str, name: str, default: int = 0) -> int:
    match = re.search(
        rf"(?m)^[ \t]*{re.escape(name)}[ \t]*=[ \t]*(\d+)[ \t]*$",
        content,
    )
    return int(match.group(1)) if match else default


def parse_lab_file(filepath: Path) -> dict | None:
    try:
        content = filepath.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return None

    lab_id = parse_shell_assignment(content, "LAB_ID")
    question = parse_shell_assignment(content, "QUESTION")
    task_count = parse_integer_assignment(content, "LAB_TASK_COUNT")
    if not lab_id or not question or task_count < 1:
        return None

    tasks: list[str] = []
    commands: list[dict] = []
    for task_number in range(1, task_count + 1):
        task_question = parse_shell_assignment(
            content, f"TASK_{task_number}_QUESTION"
        )
        task_hint = parse_shell_assignment(
            content, f"TASK_{task_number}_HINT"
        ) or ""
        if task_question is None:
            return None
        tasks.append(task_question)

        command_pattern = re.compile(
            rf"(?m)^[ \t]*TASK_{task_number}_COMMAND_(\d+)[ \t]*="
        )
        command_numbers = sorted(
            {int(match.group(1)) for match in command_pattern.finditer(content)}
        )
        for command_number in command_numbers:
            command = parse_shell_assignment(
                content, f"TASK_{task_number}_COMMAND_{command_number}"
            )
            if command is None:
                continue
            commands.append(
                {
                    "task": task_number,
                    "label": (
                        f"Task {task_number}"
                        if len(command_numbers) == 1
                        else f"Task {task_number} - Command {command_number}"
                    ),
                    "hint": task_hint if command_number == command_numbers[0] else "",
                    "command": command,
                }
            )

    return {
        "lab_id": lab_id,
        "lab_version": parse_shell_assignment(content, "LAB_VERSION") or "",
        "question": question,
        "tasks": tasks,
        "task_count": task_count,
        "commands": commands,
        "difficulty": parse_shell_assignment(content, "DIFFICULTY") or "",
        "objective_tag": parse_shell_assignment(content, "OBJECTIVE_TAG") or "",
        "file": filepath.name,
        "chapter": filepath.parent.name,
        "is_lab": "IS_LAB=true" in content,
    }


def discover_objectives() -> list[dict]:
    titles = load_objective_titles()
    objectives: list[dict] = []
    if not QUESTIONS_DIR.is_dir():
        return objectives

    chapters = sorted(
        (path for path in QUESTIONS_DIR.iterdir()
         if path.is_dir() and path.name.isdigit() and not path.is_symlink()),
        key=lambda path: int(path.name),
    )
    for chapter in chapters:
        labs = [
            path for path in chapter.glob("lab_*.sh")
            if path.is_file() and not path.is_symlink()
        ]
        if not labs:
            continue
        objectives.append(
            {
                "id": int(chapter.name),
                "title": titles.get(chapter.name, f"Chapter {chapter.name}"),
                "question_count": len(labs),
            }
        )
    return objectives


def resolve_lab_path(objective, filename) -> Path:
    objective_text = str(objective)
    filename_text = str(filename)
    if not objective_text.isdigit():
        raise ValueError("Invalid objective")
    if Path(filename_text).name != filename_text:
        raise ValueError("Invalid lab filename")
    if not filename_text.startswith("lab_") or not filename_text.endswith(".sh"):
        raise ValueError("Invalid lab filename")

    chapter_dir = (QUESTIONS_DIR / objective_text).resolve(strict=True)
    if chapter_dir.parent != QUESTIONS_DIR.resolve():
        raise ValueError("Invalid chapter path")
    candidate = chapter_dir / filename_text
    if candidate.is_symlink():
        raise ValueError("Symlinked labs are not allowed")
    resolved = candidate.resolve(strict=True)
    if resolved.parent != chapter_dir or not resolved.is_file():
        raise ValueError("Lab path outside questions tree")
    return resolved


def get_questions(objective) -> list[dict]:
    try:
        chapter = (QUESTIONS_DIR / str(objective)).resolve(strict=True)
    except (OSError, RuntimeError):
        return []
    if (
        not str(objective).isdigit()
        or chapter.parent != QUESTIONS_DIR.resolve()
        or not chapter.is_dir()
    ):
        return []

    questions: list[dict] = []
    for filepath in sorted(chapter.glob("lab_*.sh"), key=lambda p: natural_key(p.name)):
        if filepath.is_symlink():
            continue
        metadata = parse_lab_file(filepath)
        if metadata:
            questions.append(metadata)
    return questions


def get_progress() -> dict:
    return {"completed": sorted(PROGRESS.list_completed())}


def get_health() -> dict:
    objectives = discover_objectives()
    terminal = ensure_terminal_session()
    return {
        "success": bool(objectives) and terminal.get("success", False),
        "chapter_count": len(objectives),
        "chapters": [item["id"] for item in objectives],
        "question_count": sum(item.get("question_count", 0) for item in objectives),
        "terminal_session": terminal,
    }


def shell_prelude() -> str:
    return r'''
RESET=$'\e[0m'
DIM=$'\e[2m'
GREEN=$'\e[32m'
RED=$'\e[31m'
YELLOW=$'\e[33m'
CYAN=$'\e[36m'
_build_hint() { :; }
'''


def run_lab_function(filepath: Path, function_name: str, timeout: int = 60) -> dict:
    if function_name not in {"prepare_lab", "cleanup_lab"}:
        return {"success": False, "error": "Invalid lab function"}
    script = shell_prelude() + r'''
source "$1"
declare -F "$2" >/dev/null || exit 3
"$2"
'''
    try:
        result = subprocess.run(
            ["bash", "-c", script, "rhcsa-lab", str(filepath), function_name],
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except subprocess.TimeoutExpired:
        return {"success": False, "error": f"{function_name} timed out"}
    if result.returncode:
        return {
            "success": False,
            "error": result.stderr.strip() or result.stdout.strip()
            or f"{function_name} failed",
        }
    return {"success": True}


def run_check_tasks(filepath: Path, task_count: int) -> list[bool]:
    script = shell_prelude() + r'''
declare -a TASK_STATUS
source "$1"
check_tasks
for ((i=0; i<"$2"; i++)); do
    printf '__RHCSA_STATUS__%s=%s\n' "$i" "${TASK_STATUS[$i]:-false}"
done
'''
    try:
        result = subprocess.run(
            ["bash", "-c", script, "rhcsa-check", str(filepath), str(task_count)],
            capture_output=True,
            text=True,
            timeout=60,
        )
    except subprocess.TimeoutExpired:
        return [False] * task_count

    status = [False] * task_count
    for line in result.stdout.splitlines():
        match = re.fullmatch(r"__RHCSA_STATUS__(\d+)=(true|false)", line.strip())
        if not match:
            continue
        index = int(match.group(1))
        if 0 <= index < task_count:
            status[index] = match.group(2) == "true"
    return status


def ensure_terminal_session() -> dict:
    """Ensure the shared tmux session exists before the API uses it."""
    try:
        check = subprocess.run(
            ["tmux", "has-session", "-t", TMUX_SESSION],
            capture_output=True,
            text=True,
        )
        if check.returncode == 0:
            return {"success": True}

        create = subprocess.run(
            ["tmux", "new-session", "-d", "-s", TMUX_SESSION, "-c", "/tmp"],
            capture_output=True,
            text=True,
        )
        if create.returncode:
            return {
                "success": False,
                "error": create.stderr.strip() or create.stdout.strip()
                or "Unable to create terminal session",
            }
        return {"success": True}
    except OSError as exc:
        return {"success": False, "error": str(exc)}


def reset_terminal() -> dict:
    """Reset the original shared terminal session to a predictable state."""
    session = ensure_terminal_session()
    if not session["success"]:
        return session

    subprocess.run(
        ["tmux", "send-keys", "-t", TMUX_SESSION, "C-c"],
        capture_output=True,
    )
    result = subprocess.run(
        ["tmux", "send-keys", "-t", TMUX_SESSION, "clear; cd /tmp", "Enter"],
        capture_output=True,
        text=True,
    )
    if result.returncode:
        return {
            "success": False,
            "error": result.stderr.strip() or result.stdout.strip()
            or "Unable to reset terminal session",
        }
    return {"success": True}


def start_lab(data: dict) -> dict:
    """Start a lab using the original simulator's non-blocking setup flow."""
    try:
        filepath = resolve_lab_path(data.get("objective"), data.get("file"))
    except (ValueError, OSError) as exc:
        return {"error": str(exc)}

    metadata = parse_lab_file(filepath)
    if not metadata:
        return {"error": "Invalid lab metadata"}

    terminal = reset_terminal()
    if not terminal["success"]:
        return {"error": terminal.get("error", "Terminal session unavailable")}

    # The original simulator did not reject the lab when prepare_lab returned
    # non-zero. Keep setup warnings non-fatal on reused practice VMs.
    preparation = run_lab_function(filepath, "prepare_lab")
    metadata["terminal_ready"] = True
    if not preparation["success"]:
        metadata["preparation_warning"] = preparation.get(
            "error", "Lab preparation returned a non-zero status"
        )
        print(
            f"Non-fatal prepare_lab warning for {filepath.name}: "
            f"{metadata['preparation_warning']}",
            file=sys.stderr,
            flush=True,
        )
    return metadata


def check_lab(data: dict) -> dict:
    try:
        filepath = resolve_lab_path(data.get("objective"), data.get("file"))
    except (ValueError, OSError) as exc:
        return {"error": str(exc), "status": [], "allComplete": False}
    metadata = parse_lab_file(filepath)
    if not metadata:
        return {"error": "Invalid lab metadata", "status": [], "allComplete": False}
    status = run_check_tasks(filepath, metadata["task_count"])
    all_complete = bool(status) and all(status)
    if all_complete:
        PROGRESS.mark_completed(
            metadata["lab_id"],
            lab_version=metadata["lab_version"],
            chapter=metadata["chapter"],
            filename=metadata["file"],
        )
    return {
        "lab_id": metadata["lab_id"],
        "status": status,
        "allComplete": all_complete,
    }


def get_hint(data: dict) -> dict:
    try:
        filepath = resolve_lab_path(data.get("objective"), data.get("file"))
    except (ValueError, OSError) as exc:
        return {"error": str(exc), "commands": []}
    metadata = parse_lab_file(filepath)
    return {"commands": metadata["commands"] if metadata else []}


def exit_lab(data: dict) -> dict:
    try:
        filepath = resolve_lab_path(data.get("objective"), data.get("file"))
    except (ValueError, OSError) as exc:
        return {"error": str(exc), "success": False}
    return run_lab_function(filepath, "cleanup_lab")


def send_to_terminal(data: dict) -> dict:
    command = str(data.get("command", ""))
    if not command:
        return {"error": "No command provided", "success": False}
    if "\x00" in command:
        return {"error": "Invalid command", "success": False}

    session = ensure_terminal_session()
    if not session["success"]:
        return {
            "error": session.get("error", "Terminal session not found"),
            "success": False,
        }

    try:
        subprocess.run(
            ["tmux", "send-keys", "-t", TMUX_SESSION, "-l", command],
            check=True,
            capture_output=True,
        )
        if data.get("pressEnter", False):
            subprocess.run(
                ["tmux", "send-keys", "-t", TMUX_SESSION, "Enter"],
                check=True,
                capture_output=True,
            )
        return {"success": True}
    except (OSError, subprocess.CalledProcessError) as exc:
        return {"error": str(exc), "success": False}


def get_update_status(refresh: bool = True) -> dict:
    updater = INSTALL_DIR / "scripts" / "rhcsa-update"
    if refresh and updater.is_file():
        try:
            result = subprocess.run(
                [str(updater), "--status", "--json", "--quiet"],
                capture_output=True,
                text=True,
                timeout=45,
            )
            if result.returncode == 0 and result.stdout.strip():
                return json.loads(result.stdout)
        except (OSError, subprocess.TimeoutExpired, json.JSONDecodeError):
            pass
    try:
        return json.loads(UPDATE_STATE_FILE.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError, TypeError):
        return {
            "update_available": False,
            "installed_commit": VERSION_FILE.read_text(encoding="utf-8").strip()
            if VERSION_FILE.is_file() else "",
            "latest_commit": "",
            "changed_files": [],
            "result": "unknown",
        }


def check_version() -> dict:
    try:
        state = get_update_status(refresh=True)
        installed = str(state.get("installed_commit", ""))
        latest = str(state.get("latest_commit", ""))
        return {
            "updateAvailable": bool(state.get("update_available", False)),
            "installed": installed[:7] or "unknown",
            "latest": latest[:7] or "unknown",
            "repository": state.get("repository", "ytra-redhat/RHCSA.github.io"),
            "branch": state.get("branch", "main"),
            "changedFiles": state.get("changed_files", []),
            "commitCount": state.get("commit_count", 0),
            "latestMessage": state.get("latest_commit_message", ""),
            "result": state.get("result", "unknown"),
            "error": state.get("error", ""),
        }
    except Exception as exc:
        return {"updateAvailable": False, "error": str(exc)}


def get_update_log() -> dict:
    try:
        lines = UPDATE_LOG_FILE.read_text(encoding="utf-8", errors="replace").splitlines()
        return {"lines": lines[-120:]}
    except OSError:
        return {"lines": []}


def run_update() -> dict:
    updater = INSTALL_DIR / "scripts" / "rhcsa-update"
    if not updater.is_file():
        return {"success": False, "error": "Updater is not installed"}
    try:
        # The systemd service provides locking, logging and a stable parent
        # process while the Web UI itself is replaced and restarted.
        result = subprocess.run(
            ["systemctl", "start", "--no-block", "rhcsa-update.service"],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode:
            return {
                "success": False,
                "error": result.stderr.strip() or result.stdout.strip()
                or "Could not start rhcsa-update.service",
            }
        return {
            "success": True,
            "message": "Update service started",
            "status": get_update_status(refresh=False),
        }
    except (OSError, subprocess.TimeoutExpired) as exc:
        return {"success": False, "error": str(exc)}


class RHCSAAPIHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(WEBUI_DIR), **kwargs)

    def log_message(self, format, *args):
        pass

    def end_headers(self):
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()

    def send_json(self, data: dict | list, status: int = 200):
        payload = json.dumps(data).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path
        if path == "/api/objectives":
            self.send_json(discover_objectives())
        elif path.startswith("/api/questions/"):
            self.send_json(get_questions(path.rsplit("/", 1)[-1]))
        elif path == "/api/progress":
            self.send_json(get_progress())
        elif path == "/api/health":
            self.send_json(get_health())
        elif path == "/api/version/check":
            self.send_json(check_version())
        elif path == "/api/update/status":
            self.send_json(get_update_status(refresh=False))
        elif path == "/api/update/log":
            self.send_json(get_update_log())
        elif path == "/api/config/repository":
            try:
                self.send_json(load_repository_config())
            except Exception as exc:
                self.send_json({"error": str(exc)}, 500)
        elif path.startswith("/api/"):
            self.send_json({"error": "Not found"}, 404)
        else:
            super().do_GET()

    def do_POST(self):
        path = urlparse(self.path).path
        try:
            length = int(self.headers.get("Content-Length", "0"))
            data = json.loads(self.rfile.read(length).decode("utf-8")) if length else {}
        except (ValueError, json.JSONDecodeError, UnicodeDecodeError):
            self.send_json({"error": "Invalid JSON"}, 400)
            return

        handlers = {
            "/api/lab/start": start_lab,
            "/api/lab/check": check_lab,
            "/api/lab/hint": get_hint,
            "/api/lab/exit": exit_lab,
            "/api/terminal/send": send_to_terminal,
            "/api/update/run": lambda _: run_update(),
        }
        handler = handlers.get(path)
        if handler is None:
            self.send_json({"error": "Not found"}, 404)
            return
        result = handler(data)
        self.send_json(result, 400 if isinstance(result, dict) and result.get("error") else 200)

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()


def main() -> None:
    server = ThreadingHTTPServer(("0.0.0.0", WEBUI_PORT), RHCSAAPIHandler)
    print(f"RHCSA Web UI listening on 0.0.0.0:{WEBUI_PORT}")
    server.serve_forever()


if __name__ == "__main__":
    main()
