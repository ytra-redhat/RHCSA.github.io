#!/bin/bash
# RHCSA v10 objective 1.2: Use input-output redirection (>, >>, |, 2>, etc.)
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_1_2_redirection_and_pipelines_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Redirection and pipelines"
OBJECTIVE_IDS="1.2"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Redirection and pipelines"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Write only the error produced for /missing-rhcsa-v10 to /tmp/exam/v10/1.2/error."
TASK_1_HINT="Redirect file descriptor 2."
TASK_1_COMMAND_1="ls /missing-rhcsa-v10 2> /tmp/exam/v10/1.2/error"

TASK_2_QUESTION="Write the five largest files under /etc, sorted by size, to /tmp/exam/v10/1.2/largest."
TASK_2_HINT="Combine find output, sorting, and a final output redirection."
TASK_2_COMMAND_1="find /etc -type f -printf \"%s %p\\n\" 2>/dev/null | sort -nr | head -5 > /tmp/exam/v10/1.2/largest"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/1.2; mkdir -p /tmp/exam/v10/1.2
}

_check_task_1_live() {
  [[ -s /tmp/exam/v10/1.2/error ]]
}

_check_task_2_live() {
  [[ "$(wc -l < /tmp/exam/v10/1.2/largest)" -eq 5 ]]
}

check_tasks() {
  TASK_STATUS[0]="false"
  if _is_done 1; then
    TASK_STATUS[0]="true"
  elif _check_task_1_live; then
    TASK_STATUS[0]="true"
    _mark_done 1
  fi
  TASK_STATUS[1]="false"
  if _is_done 2; then
    TASK_STATUS[1]="true"
  elif _check_task_2_live; then
    TASK_STATUS[1]="true"
    _mark_done 2
  fi
}

cleanup_lab() {
  rm -rf /tmp/exam/v10/1.2
}
