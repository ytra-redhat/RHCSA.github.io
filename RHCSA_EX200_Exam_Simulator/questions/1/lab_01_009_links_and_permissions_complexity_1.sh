#!/bin/bash
# Chapter 1: Understand and use essential tools
# Objective: documentation
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch01_009_links_and_permissions_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="documentation"
OBJECTIVE_IDS="1.9,1.10,1.11"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Links and permissions - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create /tmp/exam/ch01_09_source containing the text data, then create the hard link /tmp/exam/ch01_09_hard to that same inode. Both paths must exist and refer to the same file data."
TASK_1_HINT="Use standard-output redirection to the requested path."
TASK_1_COMMAND_1="echo data > /tmp/exam/ch01_09_source; ln /tmp/exam/ch01_09_source /tmp/exam/ch01_09_hard"

TASK_2_QUESTION="Create the regular file /tmp/exam/ch01_09_private and set its numeric mode to exactly 640."
TASK_2_HINT="Review the install manual page and verify the requested final state."
TASK_2_COMMAND_1="install -m 640 /dev/null /tmp/exam/ch01_09_private"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch01_09* /tmp/rhcsa_1_09 /var/tmp/rhcsa_1_09.img
}

_check_task_1_live() {
  [[ "$(stat -c %i /tmp/exam/ch01_09_source)" = "$(stat -c %i /tmp/exam/ch01_09_hard)" ]]
}

_check_task_2_live() {
  [[ "$(stat -c %a /tmp/exam/ch01_09_private)" = 640 ]]
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
  rm -rf /tmp/exam/ch01_09* /tmp/rhcsa_1_09 /var/tmp/rhcsa_1_09.img
}
