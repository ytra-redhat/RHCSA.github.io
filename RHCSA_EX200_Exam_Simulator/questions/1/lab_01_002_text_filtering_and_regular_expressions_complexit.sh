#!/bin/bash
# Chapter 1: Understand and use essential tools
# Objective: grep regex
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch01_002_text_filtering_and_regular_expressions_complexit"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="grep regex"
QUESTION="Text filtering and regular expressions - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Run grep '^root:' /etc/passwd and write the complete standard output to /tmp/exam/ch01_02_root.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_1_HINT="Suggested command: grep '^root:' /etc/passwd > /tmp/exam/ch01_02_root.txt. Explanation: > overwrites the destination with standard output. grep selects only records matching the requested expression."
TASK_1_COMMAND_1="grep '^root:' /etc/passwd > /tmp/exam/ch01_02_root.txt"

TASK_2_QUESTION="Run grep -E ':/(bin/)?bash\$' /etc/passwd and write the complete standard output to /tmp/exam/ch01_02_bash.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_2_HINT="Suggested command: grep -E ':/(bin/)?bash\$' /etc/passwd > /tmp/exam/ch01_02_bash.txt. Explanation: > overwrites the destination with standard output. grep selects only records matching the requested expression."
TASK_2_COMMAND_1="grep -E ':/(bin/)?bash\$' /etc/passwd > /tmp/exam/ch01_02_bash.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch01_02* /tmp/rhcsa_1_02 /var/tmp/rhcsa_1_02.img
}

_check_task_1_live() {
  grep -Eq "^root:" /tmp/exam/ch01_02_root.txt
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch01_02_bash.txt ]]
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
  rm -rf /tmp/exam/ch01_02* /tmp/rhcsa_1_02 /var/tmp/rhcsa_1_02.img
}
