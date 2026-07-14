#!/bin/bash
# Chapter 7: Deploy configure and maintain systems
# Objective: cron
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch07_002_systemd_timer_units_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="cron"
QUESTION="Systemd timer units - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create oneshot service /tmp/exam/ch07_02.service"
TASK_1_HINT="Use ExecStart=/usr/bin/true"
TASK_1_COMMAND_1="printf '[Service]\\nType=oneshot\\nExecStart=/usr/bin/true\\n' > /tmp/exam/ch07_02.service"

TASK_2_QUESTION="Create daily timer /tmp/exam/ch07_02.timer"
TASK_2_HINT="Use OnCalendar=daily and WantedBy=timers.target"
TASK_2_COMMAND_1="printf '[Timer]\\nOnCalendar=daily\\n[Install]\\nWantedBy=timers.target\\n' > /tmp/exam/ch07_02.timer"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch07_02* /tmp/rhcsa_7_02 /var/tmp/rhcsa_7_02.img
}

_check_task_1_live() {
  grep -Fxq "ExecStart=/usr/bin/true" /tmp/exam/ch07_02.service
}

_check_task_2_live() {
  grep -Fxq "OnCalendar=daily" /tmp/exam/ch07_02.timer
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
  rm -rf /tmp/exam/ch07_02* /tmp/rhcsa_7_02 /var/tmp/rhcsa_7_02.img
}
