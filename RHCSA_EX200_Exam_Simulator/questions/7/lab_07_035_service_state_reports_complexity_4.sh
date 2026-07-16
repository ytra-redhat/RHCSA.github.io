#!/bin/bash
# Chapter 7: Deploy configure and maintain systems
# Objective: systemd timers
# Difficulty: 4/5

IS_LAB=true
LAB_ID="ch07_035_service_state_reports_complexity_4"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="4"
OBJECTIVE_TAG="systemd timers"
QUESTION="Service state reports - complexity 4"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Run systemctl is-enabled sshd and write both standard output and standard error to /tmp/exam/ch07_35_enabled.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_1_HINT="Suggested command: systemctl is-enabled sshd > /tmp/exam/ch07_35_enabled.txt 2>&1. Explanation: 2>&1 merges standard error into the standard-output stream before it is written. > overwrites the destination with standard output. systemctl queries systemd's current unit state."
TASK_1_COMMAND_1="systemctl is-enabled sshd > /tmp/exam/ch07_35_enabled.txt 2>&1"

TASK_2_QUESTION="Run systemctl status sshd --no-pager and write both standard output and standard error to /tmp/exam/ch07_35_status.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_2_HINT="Suggested command: systemctl status sshd --no-pager > /tmp/exam/ch07_35_status.txt 2>&1. Explanation: 2>&1 merges standard error into the standard-output stream before it is written. > overwrites the destination with standard output. systemctl queries systemd's current unit state."
TASK_2_COMMAND_1="systemctl status sshd --no-pager > /tmp/exam/ch07_35_status.txt 2>&1"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch07_35* /tmp/rhcsa_7_35 /var/tmp/rhcsa_7_35.img
}

_check_task_1_live() {
  [[ -s /tmp/exam/ch07_35_enabled.txt ]]
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch07_35_status.txt ]]
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
  rm -rf /tmp/exam/ch07_35* /tmp/rhcsa_7_35 /var/tmp/rhcsa_7_35.img
}
