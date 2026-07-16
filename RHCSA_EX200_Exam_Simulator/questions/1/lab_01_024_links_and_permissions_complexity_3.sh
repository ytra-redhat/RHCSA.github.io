#!/bin/bash
# Chapter 1: Understand and use essential tools
# Objective: file operations
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch01_024_links_and_permissions_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="file operations"
QUESTION="Links and permissions - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create /tmp/exam/ch01_24_source containing the text data, then create the hard link /tmp/exam/ch01_24_hard to that same inode. Both paths must exist and refer to the same file data."
TASK_1_HINT="Suggested command: echo data > /tmp/exam/ch01_24_source; ln /tmp/exam/ch01_24_source /tmp/exam/ch01_24_hard. Explanation: > overwrites the destination with standard output."
TASK_1_COMMAND_1="echo data > /tmp/exam/ch01_24_source; ln /tmp/exam/ch01_24_source /tmp/exam/ch01_24_hard"

TASK_2_QUESTION="Create the regular file /tmp/exam/ch01_24_private and set its numeric mode to exactly 640. The file may be empty."
TASK_2_HINT="Suggested command: install -m 640 /dev/null /tmp/exam/ch01_24_private. Explanation: install creates the file and applies the requested mode in one operation."
TASK_2_COMMAND_1="install -m 640 /dev/null /tmp/exam/ch01_24_private"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch01_24* /tmp/rhcsa_1_24 /var/tmp/rhcsa_1_24.img
}

_check_task_1_live() {
  [[ "$(stat -c %i /tmp/exam/ch01_24_source)" = "$(stat -c %i /tmp/exam/ch01_24_hard)" ]]
}

_check_task_2_live() {
  [[ "$(stat -c %a /tmp/exam/ch01_24_private)" = 640 ]]
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
  rm -rf /tmp/exam/ch01_24* /tmp/rhcsa_1_24 /var/tmp/rhcsa_1_24.img
}
