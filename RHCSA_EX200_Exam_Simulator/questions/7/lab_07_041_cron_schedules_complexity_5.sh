#!/bin/bash
# Chapter 7: Deploy configure and maintain systems
# Objective: at
# Difficulty: 5/5

IS_LAB=true
LAB_ID="ch07_041_cron_schedules_complexity_5"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="5"
OBJECTIVE_TAG="at"
QUESTION="Cron schedules - complexity 5"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create or overwrite /tmp/exam/ch07_41_daily with the following exact line(s): \"15 2 * * * root date\"."
TASK_1_HINT="Suggested command: printf '15 2 * * * root date\\n' > /tmp/exam/ch07_41_daily. Explanation: > overwrites the destination with standard output. printf writes deterministic text, including the requested line breaks."
TASK_1_COMMAND_1="printf '15 2 * * * root date\\n' > /tmp/exam/ch07_41_daily"

TASK_2_QUESTION="Create or overwrite /tmp/exam/ch07_41_weekly with the following exact line(s): \"0 4 * * 0 root date\"."
TASK_2_HINT="Suggested command: printf '0 4 * * 0 root date\\n' > /tmp/exam/ch07_41_weekly. Explanation: > overwrites the destination with standard output. printf writes deterministic text, including the requested line breaks."
TASK_2_COMMAND_1="printf '0 4 * * 0 root date\\n' > /tmp/exam/ch07_41_weekly"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch07_41* /tmp/rhcsa_7_41 /var/tmp/rhcsa_7_41.img
}

_check_task_1_live() {
  grep -Fxq "15 2 * * * root date" /tmp/exam/ch07_41_daily
}

_check_task_2_live() {
  grep -Fxq "0 4 * * 0 root date" /tmp/exam/ch07_41_weekly
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
  rm -rf /tmp/exam/ch07_41* /tmp/rhcsa_7_41 /var/tmp/rhcsa_7_41.img
}
