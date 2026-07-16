#!/bin/bash
# Chapter 1: Understand and use essential tools
# Objective: permissions
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch01_026_redirection_and_error_handling_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="permissions"
QUESTION="Redirection and error handling - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Run uname -r and write the complete standard output to /tmp/exam/ch01_26_kernel.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_1_HINT="Suggested command: uname -r > /tmp/exam/ch01_26_kernel.txt. Explanation: > overwrites the destination with standard output. uname -r prints only the running kernel release."
TASK_1_COMMAND_1="uname -r > /tmp/exam/ch01_26_kernel.txt"

TASK_2_QUESTION="Run ls against the intentionally absent path /missing-rhcsa-26 and redirect only standard error (file descriptor 2) to /tmp/exam/ch01_26_error.txt. The task is complete when /tmp/exam/ch01_26_error.txt exists and contains the resulting error message."
TASK_2_HINT="Suggested command: ls /missing-rhcsa-26 2> /tmp/exam/ch01_26_error.txt. Explanation: 2> redirects only standard error, leaving standard output unchanged."
TASK_2_COMMAND_1="ls /missing-rhcsa-26 2> /tmp/exam/ch01_26_error.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch01_26* /tmp/rhcsa_1_26 /var/tmp/rhcsa_1_26.img
}

_check_task_1_live() {
  grep -Fxq "$(uname -r)" /tmp/exam/ch01_26_kernel.txt
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch01_26_error.txt ]]
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
  rm -rf /tmp/exam/ch01_26* /tmp/rhcsa_1_26 /var/tmp/rhcsa_1_26.img
}
