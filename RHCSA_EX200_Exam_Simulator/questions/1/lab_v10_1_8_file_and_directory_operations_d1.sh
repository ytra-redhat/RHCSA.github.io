#!/bin/bash
# RHCSA v10 objective 1.8: Create, delete, copy, and move files and directories
# Difficulty: 1/5

IS_LAB=true
LAB_ID="v10_1_8_file_and_directory_operations_d1"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="1"
OBJECTIVE_TAG="File and directory operations - practice level 1"
OBJECTIVE_IDS="1.8"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="File and directory operations - practice level 1"
LAB_TASK_COUNT=1

TASK_1_QUESTION="Copy /tmp/exam/v10/1.8/source recursively to /tmp/exam/v10/1.8/archive."
TASK_1_HINT="Preserve the directory tree."
TASK_1_COMMAND_1="cp -a /tmp/exam/v10/1.8/source /tmp/exam/v10/1.8/archive"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/1.8; mkdir -p /tmp/exam/v10/1.8/source/sub; printf data > /tmp/exam/v10/1.8/source/sub/data
}

_check_task_1_live() {
  [[ -f /tmp/exam/v10/1.8/archive/sub/data ]]
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
  rm -rf /tmp/exam/v10/1.8
}
