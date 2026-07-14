#!/bin/bash
# Chapter 5: Configure local storage
# Objective: GPT partitions
# Difficulty: 2/5

IS_LAB=true
LAB_ID="ch05_015_swap_and_capacity_complexity_2"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="2"
OBJECTIVE_TAG="GPT partitions"
QUESTION="Swap and capacity - complexity 2"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Save swap inventory in /tmp/exam/ch05_15_swap.txt"
TASK_1_HINT="Use swapon --show"
TASK_1_COMMAND_1="swapon --show > /tmp/exam/ch05_15_swap.txt"

TASK_2_QUESTION="Save filesystem capacity in /tmp/exam/ch05_15_df.txt"
TASK_2_HINT="Use df -hT"
TASK_2_COMMAND_1="df -hT > /tmp/exam/ch05_15_df.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch05_15* /tmp/rhcsa_5_15 /var/tmp/rhcsa_5_15.img
}

_check_task_1_live() {
  [[ -f /tmp/exam/ch05_15_swap.txt ]]
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch05_15_df.txt ]]
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
  rm -rf /tmp/exam/ch05_15* /tmp/rhcsa_5_15 /var/tmp/rhcsa_5_15.img
}
