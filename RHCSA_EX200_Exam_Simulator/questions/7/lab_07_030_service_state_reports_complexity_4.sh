#!/bin/bash
# Chapter 7: Deploy configure and maintain systems
# Objective: time clients
# Difficulty: 4/5

IS_LAB=true
LAB_ID="ch07_030_service_state_reports_complexity_4"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="4"
OBJECTIVE_TAG="time clients"
QUESTION="Service state reports - complexity 4"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Save sshd enablement in /tmp/exam/ch07_30_enabled.txt"
TASK_1_HINT="Use systemctl is-enabled sshd"
TASK_1_COMMAND_1="systemctl is-enabled sshd > /tmp/exam/ch07_30_enabled.txt 2>&1"

TASK_2_QUESTION="Save sshd status in /tmp/exam/ch07_30_status.txt"
TASK_2_HINT="Use systemctl status sshd --no-pager"
TASK_2_COMMAND_1="systemctl status sshd --no-pager > /tmp/exam/ch07_30_status.txt 2>&1"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch07_30* /tmp/rhcsa_7_30 /var/tmp/rhcsa_7_30.img
}

_check_task_1_live() {
  [[ -s /tmp/exam/ch07_30_enabled.txt ]]
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch07_30_status.txt ]]
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
  rm -rf /tmp/exam/ch07_30* /tmp/rhcsa_7_30 /var/tmp/rhcsa_7_30.img
}
