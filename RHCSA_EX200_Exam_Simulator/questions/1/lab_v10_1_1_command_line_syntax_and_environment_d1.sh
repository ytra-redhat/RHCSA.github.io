#!/bin/bash
# RHCSA v10 objective 1.1: Access a shell prompt and issue commands with correct syntax
# Difficulty: 1/5

IS_LAB=true
LAB_ID="v10_1_1_command_line_syntax_and_environment_d1"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="1"
OBJECTIVE_TAG="Command-line syntax and environment - practice level 1"
OBJECTIVE_IDS="1.1"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Command-line syntax and environment - practice level 1"
LAB_TASK_COUNT=1

TASK_1_QUESTION="Create /tmp/exam/v10/1.1/result containing the current shell name and the number of words in PATH."
TASK_1_HINT="Use shell parameter expansion and a pipeline; write exactly two lines."
TASK_1_COMMAND_1="printf \"%s\\n%s\\n\" \"\$SHELL\" \"\$(tr : '\\n' <<<\"\$PATH\" | wc -l)\" > /tmp/exam/v10/1.1/result"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/1.1; mkdir -p /tmp/exam/v10/1.1
}

_check_task_1_live() {
  [[ -s /tmp/exam/v10/1.1/result && "$(wc -l < /tmp/exam/v10/1.1/result)" -eq 2 ]]
}

check_tasks() {
  TASK_STATUS[0]="false"
  if _is_done 1; then
    TASK_STATUS[0]="true"
  elif _check_task_1_live; then
    TASK_STATUS[0]="true"
    _mark_done 1
  fi
}

cleanup_lab() {
  rm -rf /tmp/exam/v10/1.1
}
