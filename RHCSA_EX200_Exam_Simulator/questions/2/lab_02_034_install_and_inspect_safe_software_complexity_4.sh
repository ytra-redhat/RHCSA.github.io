#!/bin/bash
# Chapter 2: Manage software
# Objective: local packages
# Difficulty: 4/5

IS_LAB=true
LAB_ID="ch02_034_install_and_inspect_safe_software_complexity_4"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="4"
OBJECTIVE_TAG="local packages"
OBJECTIVE_IDS="2.2"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Install and inspect safe software - complexity 4"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Install the RPM package bash-completion with DNF. The package must be installed when the task is checked."
TASK_1_HINT="Review the dnf manual page and verify the requested final state."
TASK_1_COMMAND_1="dnf install -y bash-completion"

TASK_2_QUESTION="Write the standard output of \`rpm -qi bash-completion\` to /tmp/exam/ch02_34_pkg.txt."
TASK_2_HINT="Review the rpm manual page and verify the requested final state."
TASK_2_COMMAND_1="rpm -qi bash-completion > /tmp/exam/ch02_34_pkg.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch02_34* /tmp/rhcsa_2_34 /var/tmp/rhcsa_2_34.img
}

_check_task_1_live() {
  rpm -q bash-completion >/dev/null 2>&1
}

_check_task_2_live() {
  grep -Eqi "^Name.*bash-completion" /tmp/exam/ch02_34_pkg.txt
}

check_tasks() {
  TASK_STATUS[0]="false"
  TASK_STATUS[1]="false"
  if _is_done 1; then
    TASK_STATUS[0]="true"
  elif _check_task_1_live; then
    TASK_STATUS[0]="true"
    _mark_done 1
  fi
  if _is_done 2; then
    TASK_STATUS[1]="true"
  elif _check_task_2_live; then
    TASK_STATUS[1]="true"
    _mark_done 2
  fi
}

cleanup_lab() {
  rm -rf /tmp/exam/ch02_34* /tmp/rhcsa_2_34 /var/tmp/rhcsa_2_34.img
}
