#!/bin/bash
# Chapter 7: Deploy configure and maintain systems
# Objective: default target
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch07_021_cron_schedules_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="default target"
QUESTION="Cron schedules - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create daily cron artifact /tmp/exam/ch07_21_daily"
TASK_1_HINT="Write 15 2 * * * root date"
TASK_1_COMMAND_1="printf '15 2 * * * root date\\n' > /tmp/exam/ch07_21_daily"

TASK_2_QUESTION="Create weekly cron artifact /tmp/exam/ch07_21_weekly"
TASK_2_HINT="Write 0 4 * * 0 root date"
TASK_2_COMMAND_1="printf '0 4 * * 0 root date\\n' > /tmp/exam/ch07_21_weekly"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch07_21* /tmp/rhcsa_7_21 /var/tmp/rhcsa_7_21.img
}

_check_task_1_live() {
  grep -Fxq "15 2 * * * root date" /tmp/exam/ch07_21_daily
}

_check_task_2_live() {
  grep -Fxq "0 4 * * 0 root date" /tmp/exam/ch07_21_weekly
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
  rm -rf /tmp/exam/ch07_21* /tmp/rhcsa_7_21 /var/tmp/rhcsa_7_21.img
}
