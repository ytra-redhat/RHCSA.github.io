#!/usr/bin/env python3
"""Rewrite and audit RHCSA task questions for clarity and non-ambiguity.

The script never changes task commands, preparation logic or validation logic.
It only rewrites TASK_n_QUESTION and TASK_n_HINT metadata.
"""
from __future__ import annotations

import argparse
import json
import re
import shlex
from pathlib import Path
from typing import Iterable

ASSIGNMENT = re.compile(
    r"^(?P<name>[A-Z0-9_]+)=(?P<quote>[\"'])(?P<value>.*)(?P=quote)\s*$"
)
UNQUOTED_ASSIGNMENT = re.compile(r"^(?P<name>[A-Z0-9_]+)=(?P<value>[^#]*?)\s*$")
VAGUE_PATTERNS = (
    re.compile(r"\brun it\b", re.I),
    re.compile(r"\bits ownership\b", re.I),
    re.compile(r"\bboth directives\b", re.I),
    re.compile(r"\ban Image line\b", re.I),
    re.compile(r"\bwith text and reboot\b", re.I),
)


def decode_metadata(raw: str) -> str:
    """Decode the limited escapes used in double-quoted lab metadata."""
    return (
        raw.replace(r"\$", "$")
        .replace(r'\"', '"')
        .replace(r"\`", "`")
        .replace("\\\\", "\\")
    )


def encode_double(value: str) -> str:
    """Encode a value safely for a Bash double-quoted assignment."""
    return (
        value.replace("\\", "\\\\")
        .replace('"', r'\"')
        .replace("$", r"\$")
        .replace("`", r"\`")
    )


def ensure_period(text: str) -> str:
    text = re.sub(r"\s+", " ", text.strip())
    return text if text.endswith((".", "?", "!")) else text + "."


def decode_printf_content(command: str) -> list[str]:
    match = re.search(r"\bprintf\s+'(?P<content>.*?)'", command, re.S)
    if not match:
        return []
    content = match.group("content")
    content = (
        content.replace(r"\n", "\n")
        .replace(r"\t", "\t")
        .replace(r"\$", "$")
        .replace(r'\"', '"')
        .replace("\\\\", "\\")
    )
    return [line for line in content.splitlines() if line != ""]


def quoted_items(lines: Iterable[str]) -> str:
    cleaned = [line.strip() for line in lines if line.strip()]
    if not cleaned:
        return ""
    return "; ".join(f'"{line}"' for line in cleaned)


def parse_redirect(command: str):
    """Return body, operator, target and stderr-merged flag for final redirect."""
    match = re.match(
        r"^(?P<body>.*?)(?P<op>2>|>>|>)\s*(?P<target>/[^\s;]+)"
        r"(?P<merged>\s+2>&1)?\s*$",
        command.strip(),
        re.S,
    )
    if not match:
        return None
    return (
        match.group("body").strip(),
        match.group("op"),
        match.group("target"),
        bool(match.group("merged")),
    )


def source_paths(command: str) -> list[str]:
    return list(dict.fromkeys(re.findall(r"(?<![A-Za-z0-9_.-])(/[A-Za-z0-9_./?*+():=-]+)", command)))


def clear_question(original: str, commands: list[str], previous_question: str = "") -> str:
    command = commands[0].strip() if commands else ""
    decoded = command

    # The user's concrete example and equivalent stderr tasks.
    redirect = parse_redirect(decoded)
    if redirect and redirect[1] == "2>":
        body, _, target, _ = redirect
        paths = source_paths(body)
        source = paths[-1] if paths else "the intentionally missing source path"
        command_name = body.split()[0] if body.split() else "the command"
        return ensure_period(
            f"Run {command_name} against the intentionally absent path {source} and redirect only "
            f"standard error (file descriptor 2) to {target}. The task is complete when "
            f"{target} exists and contains the resulting error message"
        )

    if re.search(r"\bRun it twice\b", original, re.I):
        scripts = re.findall(r"(/usr/local/bin/[^\s;]+)", decoded)
        target_match = re.search(r">\s*(/[^\s;]+)\s*$", decoded)
        script = scripts[0] if scripts else "the script created in task 1"
        target = target_match.group(1) if target_match else "the required output file"
        return ensure_period(
            f"Execute {script} twice. Discard the first run's output and redirect the second "
            f"run's standard output to {target}. The file must contain the output from only "
            f"the second execution"
        )

    if re.search(r"\bSave its ownership and mode\b", original, re.I):
        match = re.search(r"\bstat\b.*?\s(/[^\s;]+)\s*>\s*(/[^\s;]+)", decoded)
        if match:
            source, target = match.groups()
            return ensure_period(
                f"Use stat to write the owner, group and numeric permission mode of {source} "
                f"to {target}, in that order. The output file must contain all three values"
            )

    # Script creation commands end with chmod rather than a final redirect.
    script_match = re.search(
        r"^printf\s+'(?P<content>.*?)'\s*>\s*(?P<target>/usr/local/bin/[^;\s]+);\s*"
        r"chmod\s+\+x\s+(?P=target)$",
        decoded,
        re.S,
    )
    if script_match:
        target = script_match.group("target")
        return ensure_period(
            f"{original}. Make {target} executable. The task is complete only when running "
            f"that exact script produces the behavior and output stated above"
        )

    # Commands that create exact text files are made explicit about all lines.
    if redirect and redirect[0].lstrip().startswith("printf "):
        body, op, target, merged = redirect
        lines = decode_printf_content(body)
        content = quoted_items(lines)
        if op == ">>":
            prefix = f"Append the following exact line(s) to {target} without removing its existing content"
        else:
            prefix = f"Create or overwrite {target} with the following exact line(s)"
        if content:
            return ensure_period(f"{prefix}: {content}")
        return ensure_period(prefix)

    # General output-capture tasks identify the command, stream and destination.
    if redirect:
        body, op, target, merged = redirect
        if merged:
            stream = "both standard output and standard error"
        elif op == ">>":
            stream = "standard output, appending it without truncating existing content"
        else:
            stream = "the complete standard output"
        overwrite = "" if op == ">>" else " Overwrite the destination if it already exists."
        return ensure_period(
            f"Run {body} and write {stream} to {target}.{overwrite} The task is complete when "
            f"the destination file exists and contains the requested command output"
        )

    # Multi-command artifact creation without a final redirect.
    if decoded.startswith("echo data >") and "; ln " in decoded:
        match = re.search(r"echo\s+data\s*>\s*(/[^\s;]+);\s*ln\s+(/[^\s;]+)\s+(/[^\s;]+)", decoded)
        if match:
            source, link_source, hard = match.groups()
            return ensure_period(
                f"Create {source} containing the text data, then create the hard link {hard} "
                f"to that same inode. Both paths must exist and refer to the same file data"
            )

    if decoded.startswith("cp ") and "; chmod " in decoded:
        match = re.search(r"cp\s+(/[^\s;]+)\s+(/[^\s;]+);\s*chmod\s+(\d+)\s+(/[^\s;]+)", decoded)
        if match:
            source, target, mode, chmod_target = match.groups()
            return ensure_period(
                f"Copy {source} to {target} and set the resulting file's numeric mode to {mode}. "
                f"The destination must contain the public key and have exactly that mode"
            )

    # Direct state-changing commands.
    try:
        tokens = shlex.split(decoded)
    except ValueError:
        tokens = decoded.split()
    if tokens:
        cmd = tokens[0]
        if cmd == "useradd":
            user = tokens[-1]
            groups = tokens[tokens.index("-G") + 1] if "-G" in tokens else ""
            detail = f" and add it to supplementary group {groups}" if groups else ""
            acceptance = (
                "The account, home directory and supplementary group membership must all be present"
                if groups else
                "The account and its home directory must both be present"
            )
            return ensure_period(
                f"Create the local user account {user}, create its home directory{detail}. {acceptance}"
            )
        if cmd == "groupadd":
            return ensure_period(f"Create the local group {tokens[-1]}. The group must exist in the local group database")
        if cmd == "chage" and "-M" in tokens:
            age = tokens[tokens.index("-M") + 1]
            user = tokens[-1]
            return ensure_period(
                f"Set the maximum password age for user {user} to exactly {age} days. Verify that the account records that value"
            )
        if cmd == "chmod" and len(tokens) >= 3:
            return ensure_period(
                f"Set the numeric permission mode of {tokens[-1]} to exactly {tokens[-2]}. Do not change the file's contents"
            )
        if cmd == "install" and "-d" in tokens and "-m" in tokens:
            mode = tokens[tokens.index("-m") + 1]
            target = tokens[-1]
            return ensure_period(
                f"Create directory {target}, including missing parent directories, and set its numeric mode to exactly {mode}"
            )
        if cmd == "install" and "-m" in tokens:
            mode = tokens[tokens.index("-m") + 1]
            target = tokens[-1]
            return ensure_period(
                f"Create the regular file {target} and set its numeric mode to exactly {mode}. The file may be empty"
            )
        if cmd == "mkdir":
            target = tokens[-1]
            return ensure_period(f"Create directory {target}, including any missing parent directories. The exact path must exist")
        if cmd == "dnf" and len(tokens) >= 4 and tokens[1] == "install":
            package = tokens[-1]
            return ensure_period(f"Install the RPM package {package} with DNF. The package must be installed when the task is checked")
        if cmd == "truncate" and "-s" in tokens:
            size = tokens[tokens.index("-s") + 1]
            target = tokens[-1]
            return ensure_period(f"Create the disk-image file {target} with an exact apparent size of {size}")
        if cmd == "parted" and "mklabel" in tokens:
            target = tokens[tokens.index("-s") + 1]
            label = tokens[-1]
            return ensure_period(f"Write a {label.upper()} partition-table label to disk image {target}. Use non-interactive operation")
        if cmd == "ssh-keygen" and "-f" in tokens:
            target = tokens[tokens.index("-f") + 1]
            return ensure_period(
                f"Generate an Ed25519 SSH key pair at {target} with an empty passphrase. Both {target} and {target}.pub must be created"
            )
        if cmd == "tar":
            target = tokens[2] if len(tokens) > 2 else "the requested archive"
            source = tokens[-1]
            compression = "gzip" if "z" in tokens[1] else "bzip2" if "j" in tokens[1] else "the requested"
            return ensure_period(f"Create archive {target} using {compression} compression and include {source}")
        if cmd == "semanage" and "restorecon" in decoded:
            match = re.search(r"-t\s+(\S+)\s+'?([^';]+)'?;\s*restorecon\s+-\S+\s+(\S+)", decoded)
            if match:
                sel_type, pattern, target = match.groups()
                return ensure_period(
                    f"Create a persistent SELinux file-context mapping that assigns type {sel_type} to {pattern}, then apply the mapping immediately to {target} with restorecon"
                )

    # Fallback remains explicit about exact values and final state.
    return ensure_period(
        f"{original}. Use every name, path, value and option exactly as stated; the task is complete only when the requested persistent or runtime state exists"
    )


def explain_command(command: str) -> str:
    points: list[str] = []
    if "2>&1" in command:
        points.append("2>&1 merges standard error into the standard-output stream before it is written")
    elif re.search(r"(^|\s)2>", command):
        points.append("2> redirects only standard error, leaving standard output unchanged")
    if ">>" in command:
        points.append(">> appends and preserves existing file content")
    elif re.search(r"(^|\s)>", command):
        points.append("> overwrites the destination with standard output")
    if "uname -r" in command:
        points.append("uname -r prints only the running kernel release")
    if "rpm -qi" in command:
        points.append("rpm -qi queries installed-package metadata")
    if "rpm -ql" in command:
        points.append("rpm -ql lists files owned by an installed package")
    if "useradd -m" in command:
        points.append("useradd -m creates the account and its home directory")
    if " -G " in command and "useradd" in command:
        points.append("-G assigns supplementary group membership")
    if command.startswith("groupadd "):
        points.append("groupadd creates a local group entry with the exact name supplied")
    if command.startswith("chmod "):
        points.append("chmod applies the requested numeric permission mode to the named path")
    if command.startswith("mkdir "):
        points.append("mkdir -p creates the directory and any missing parent directories")
    if command.startswith("dnf install "):
        points.append("dnf install resolves dependencies and installs the named RPM package")
    if command.startswith("chage -M"):
        points.append("chage -M sets the maximum password lifetime in days")
    if "semanage fcontext" in command:
        points.append("semanage fcontext records a persistent SELinux mapping and restorecon applies it")
    if command.startswith("systemctl get-default"):
        points.append("systemctl get-default reports the boot target selected as default")
    if command.startswith("journalctl -b -p warning"):
        points.append("-b limits results to the current boot and -p warning selects warning-or-higher priorities")
    if command.startswith("ssh-keygen"):
        points.append("-t selects Ed25519, -N sets the passphrase and -f selects the key path")
    if command.startswith("printf "):
        points.append("printf writes deterministic text, including the requested line breaks")
    if command.startswith("install -d"):
        points.append("install -d creates directories while -m applies the requested mode atomically")
    elif command.startswith("install -m"):
        points.append("install creates the file and applies the requested mode in one operation")
    if command.startswith("tar -czf"):
        points.append("-c creates the archive, -z enables gzip and -f names the output file")
    if command.startswith("tar -cjf"):
        points.append("-c creates the archive, -j enables bzip2 and -f names the output file")
    if command.startswith("parted -s"):
        points.append("-s runs non-interactively and mklabel writes the partition-table type")
    if command.startswith("truncate -s"):
        points.append("truncate -s sets the exact apparent file size")
    if command.startswith("grep "):
        points.append("grep selects only records matching the requested expression")
    if command.startswith("findmnt"):
        points.append("findmnt reports the currently mounted filesystem topology")
    if command.startswith("systemctl") and not any("systemctl" in p for p in points):
        points.append("systemctl queries systemd's current unit state")
    if command.startswith("firewall-cmd"):
        if "--permanent" in command:
            points.append("--permanent reads firewalld's saved configuration rather than the current runtime state")
        else:
            points.append("without --permanent, firewall-cmd queries the current runtime configuration")
    if command.startswith("nmcli"):
        points.append("nmcli reads NetworkManager's connection and device state")
    if command.startswith("podman"):
        points.append("podman reports the current container-engine state for the executing user")
    if not points:
        points.append("run the command exactly as shown and verify the requested final state or output file")
    return " ".join(ensure_period(point) for point in points)


def clear_hint(commands: list[str]) -> str:
    if not commands:
        return "Approach: identify the command that creates the exact state described in the task, execute it, and verify the result before checking the task."
    if len(commands) == 1:
        sequence = f"Suggested command: {commands[0]}."
    else:
        rendered = " ".join(f"Step {index}: {command}." for index, command in enumerate(commands, 1))
        sequence = f"Suggested command sequence: {rendered}"
    explanation = " ".join(explain_command(command) for command in commands)
    return ensure_period(f"{sequence} Explanation: {explanation}")


def parse_file(path: Path) -> tuple[list[str], dict[str, str]]:
    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    values: dict[str, str] = {}
    for line in lines:
        match = ASSIGNMENT.match(line)
        if match:
            values[match.group("name")] = decode_metadata(match.group("value"))
            continue
        plain = UNQUOTED_ASSIGNMENT.match(line)
        if plain:
            values[plain.group("name")] = plain.group("value").strip()
    return lines, values


def rewrite_file(path: Path) -> int:
    lines, values = parse_file(path)
    task_count = int(values.get("LAB_TASK_COUNT", "0") or 0)
    replacements: dict[str, str] = {}
    previous_question = ""
    for task in range(1, task_count + 1):
        original = values.get(f"TASK_{task}_QUESTION", "")
        commands = [
            values[name]
            for name in sorted(
                (key for key in values if key.startswith(f"TASK_{task}_COMMAND_")),
                key=lambda key: int(key.rsplit("_", 1)[-1]),
            )
        ]
        question = clear_question(original, commands, previous_question)
        hint = clear_hint(commands)
        replacements[f"TASK_{task}_QUESTION"] = question
        replacements[f"TASK_{task}_HINT"] = hint
        previous_question = question

    changed = 0
    output: list[str] = []
    for line in lines:
        match = ASSIGNMENT.match(line)
        if match and match.group("name") in replacements:
            name = match.group("name")
            new_line = f'{name}="{encode_double(replacements[name])}"'
            if new_line != line:
                changed += 1
            output.append(new_line)
        else:
            output.append(line)
    if changed:
        path.write_text("\n".join(output) + "\n", encoding="utf-8")
    return changed


def audit_file(path: Path) -> list[str]:
    _, values = parse_file(path)
    errors: list[str] = []
    task_count = int(values.get("LAB_TASK_COUNT", "0") or 0)
    for task in range(1, task_count + 1):
        question = values.get(f"TASK_{task}_QUESTION", "")
        hint = values.get(f"TASK_{task}_HINT", "")
        commands = [
            values[name]
            for name in sorted(
                (key for key in values if key.startswith(f"TASK_{task}_COMMAND_")),
                key=lambda key: int(key.rsplit("_", 1)[-1]),
            )
        ]
        label = f"{path}: task {task}"
        if len(question) < 55:
            errors.append(f"{label}: question is too terse ({len(question)} characters)")
        for pattern in VAGUE_PATTERNS:
            if pattern.search(question):
                errors.append(f"{label}: vague wording remains: {pattern.pattern}")
        if not hint.startswith(("Suggested command:", "Suggested command sequence:", "Approach:")):
            errors.append(f"{label}: hint does not provide a structured approach")
        if "Explanation:" not in hint and not hint.startswith("Approach:"):
            errors.append(f"{label}: hint lacks an explanation")
        if len(hint) < 80:
            errors.append(f"{label}: hint is not sufficiently explanatory ({len(hint)} characters)")
        for command in commands:
            redirect = parse_redirect(command)
            if redirect:
                target = redirect[2]
                if target not in question:
                    errors.append(f"{label}: question omits output target {target}")
        if commands:
            command_text = "; ".join(commands)
            ignored_paths = {"/dev/null", "/bin/bash"}
            paths = [path for path in source_paths(command_text) if path not in ignored_paths]
            redirected_targets = {
                redirect[2]
                for command in commands
                if (redirect := parse_redirect(command))
            }
            required_paths = [path for path in paths if path not in redirected_targets]
            missing_paths = [path for path in required_paths if path not in question]
            if missing_paths:
                errors.append(f"{label}: question omits exact source/resource path(s) {missing_paths}")
    return errors


def iter_labs(root: Path):
    yield from sorted(root.glob("[0-9]*/lab_*.sh"), key=lambda p: (int(p.parent.name), p.name))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("questions_dir", type=Path)
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    questions = args.questions_dir.resolve()
    labs = list(iter_labs(questions))
    changed_lines = 0
    if args.apply:
        for lab in labs:
            changed_lines += rewrite_file(lab)
    errors: list[str] = []
    for lab in labs:
        errors.extend(audit_file(lab))
    report = {
        "labs": len(labs),
        "tasks": sum(int(parse_file(lab)[1].get("LAB_TASK_COUNT", "0") or 0) for lab in labs),
        "changed_metadata_lines": changed_lines,
        "errors": errors,
    }
    if args.json:
        print(json.dumps(report, indent=2, sort_keys=True))
    else:
        print(f"Labs audited: {report['labs']}")
        print(f"Tasks audited: {report['tasks']}")
        print(f"Metadata lines changed: {changed_lines}")
        if errors:
            print(f"Clarity errors: {len(errors)}")
            for error in errors[:100]:
                print(f"- {error}")
        else:
            print("Clarity audit: PASS")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
