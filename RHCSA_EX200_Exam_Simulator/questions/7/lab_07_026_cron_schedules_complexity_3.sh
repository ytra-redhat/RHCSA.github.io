#!/bin/bash
# Chapter 7: Deploy configure and maintain systems
# Objective: cron
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch07_026_cron_schedules_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="cron"
OBJECTIVE_IDS="7.1"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Cron schedules - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create or overwrite /tmp/exam/ch07_26_daily with the following exact line(s): \"15 2 * * * root date\"."
TASK_1_HINT="Use standard-output redirection to the requested path."
TASK_1_COMMAND_1="printf '15 2 * * * root date\\n' > /tmp/exam/ch07_26_daily"

TASK_2_QUESTION="Create or overwrite /tmp/exam/ch07_26_weekly with the following exact line(s): \"0 4 * * 0 root date\"."
TASK_2_HINT="Use standard-output redirection to the requested path."
TASK_2_COMMAND_1="printf '0 4 * * 0 root date\\n' > /tmp/exam/ch07_26_weekly"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch07_26* /tmp/rhcsa_7_26 /var/tmp/rhcsa_7_26.img
}

_check_task_1_live() {
  grep -Fxq "15 2 * * * root date" /tmp/exam/ch07_26_daily
}

_check_task_2_live() {
  grep -Fxq "0 4 * * 0 root date" /tmp/exam/ch07_26_weekly
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
  rm -rf /tmp/exam/ch07_26* /tmp/rhcsa_7_26 /var/tmp/rhcsa_7_26.img
}
