#!/bin/bash
# Chapter 4: Operate running systems
# Objective: processes
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch04_020_tuning_and_scheduling_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="processes"
OBJECTIVE_IDS="4.5,4.6"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Tuning and scheduling - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="tuned-adm active and write both standard output and standard error to /tmp/exam/ch04_20_tuned.txt."
TASK_1_HINT="Use file descriptor 2 redirection."
TASK_1_COMMAND_1="tuned-adm active > /tmp/exam/ch04_20_tuned.txt 2>&1"

TASK_2_QUESTION="Write the standard output of \`ps -eo pid,ni,comm\` to /tmp/exam/ch04_20_nice.txt."
TASK_2_HINT="Use standard-output redirection to the requested path."
TASK_2_COMMAND_1="ps -eo pid,ni,comm > /tmp/exam/ch04_20_nice.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch04_20* /tmp/rhcsa_4_20 /var/tmp/rhcsa_4_20.img
}

_check_task_1_live() {
  [[ -f /tmp/exam/ch04_20_tuned.txt ]]
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch04_20_nice.txt ]]
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
  rm -rf /tmp/exam/ch04_20* /tmp/rhcsa_4_20 /var/tmp/rhcsa_4_20.img
}
