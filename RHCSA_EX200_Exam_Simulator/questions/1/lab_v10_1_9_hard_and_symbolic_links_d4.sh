#!/bin/bash
# RHCSA v10 objective 1.9: Create hard and soft links
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_1_9_hard_and_symbolic_links_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Hard and symbolic links"
OBJECTIVE_IDS="1.9"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Hard and symbolic links"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create hard link /tmp/exam/v10/1.9/hard to /tmp/exam/v10/1.9/original."
TASK_1_HINT="A hard link must share the inode."
TASK_1_COMMAND_1="ln /tmp/exam/v10/1.9/original /tmp/exam/v10/1.9/hard"

TASK_2_QUESTION="Create symbolic link /tmp/exam/v10/1.9/soft pointing to original."
TASK_2_HINT="Use a relative target name."
TASK_2_COMMAND_1="ln -s original /tmp/exam/v10/1.9/soft"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/1.9; mkdir -p /tmp/exam/v10/1.9; printf data > /tmp/exam/v10/1.9/original
}

_check_task_1_live() {
  [[ "$(stat -c %i /tmp/exam/v10/1.9/original)" == "$(stat -c %i /tmp/exam/v10/1.9/hard)" ]]
}

_check_task_2_live() {
  [[ "$(readlink /tmp/exam/v10/1.9/soft)" == original ]]
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
  rm -rf /tmp/exam/v10/1.9
}
