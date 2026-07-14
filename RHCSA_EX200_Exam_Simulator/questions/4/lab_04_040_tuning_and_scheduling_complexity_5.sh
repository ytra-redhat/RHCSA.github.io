#!/bin/bash
# Chapter 4: Operate running systems
# Objective: nice priority
# Difficulty: 5/5

IS_LAB=true
LAB_ID="ch04_040_tuning_and_scheduling_complexity_5"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="5"
OBJECTIVE_TAG="nice priority"
QUESTION="Tuning and scheduling - complexity 5"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Save active tuned profile in /tmp/exam/ch04_40_tuned.txt"
TASK_1_HINT="Use tuned-adm active"
TASK_1_COMMAND_1="tuned-adm active > /tmp/exam/ch04_40_tuned.txt 2>&1"

TASK_2_QUESTION="Save process nice values in /tmp/exam/ch04_40_nice.txt"
TASK_2_HINT="Use ps -eo pid,ni,comm"
TASK_2_COMMAND_1="ps -eo pid,ni,comm > /tmp/exam/ch04_40_nice.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch04_40* /tmp/rhcsa_4_40 /var/tmp/rhcsa_4_40.img
}

_check_task_1_live() {
  [[ -f /tmp/exam/ch04_40_tuned.txt ]]
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch04_40_nice.txt ]]
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
  rm -rf /tmp/exam/ch04_40* /tmp/rhcsa_4_40 /var/tmp/rhcsa_4_40.img
}
