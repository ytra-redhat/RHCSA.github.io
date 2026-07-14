#!/bin/bash
# Chapter 1: Understand and use essential tools
# Objective: archives
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch01_004_links_and_permissions_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="archives"
QUESTION="Links and permissions - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create a hard link /tmp/exam/ch01_04_hard to /tmp/exam/ch01_04_source"
TASK_1_HINT="Create the source and use ln"
TASK_1_COMMAND_1="echo data > /tmp/exam/ch01_04_source; ln /tmp/exam/ch01_04_source /tmp/exam/ch01_04_hard"

TASK_2_QUESTION="Create /tmp/exam/ch01_04_private with mode 640"
TASK_2_HINT="Use install -m 640"
TASK_2_COMMAND_1="install -m 640 /dev/null /tmp/exam/ch01_04_private"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch01_04* /tmp/rhcsa_1_04 /var/tmp/rhcsa_1_04.img
}

_check_task_1_live() {
  [[ "$(stat -c %i /tmp/exam/ch01_04_source)" = "$(stat -c %i /tmp/exam/ch01_04_hard)" ]]
}

_check_task_2_live() {
  [[ "$(stat -c %a /tmp/exam/ch01_04_private)" = 640 ]]
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
  rm -rf /tmp/exam/ch01_04* /tmp/rhcsa_1_04 /var/tmp/rhcsa_1_04.img
}
