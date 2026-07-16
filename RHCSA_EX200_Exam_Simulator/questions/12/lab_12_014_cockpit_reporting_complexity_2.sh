#!/bin/bash
# Chapter 12: Bonus RHEL 9 installation and legacy administration
# Objective: legacy networking
# Difficulty: 2/5

IS_LAB=true
LAB_ID="ch12_014_cockpit_reporting_complexity_2"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="2"
OBJECTIVE_TAG="legacy networking"
QUESTION="Cockpit reporting - complexity 2"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Run systemctl status cockpit.socket --no-pager and write both standard output and standard error to /tmp/exam/ch12_14_cockpit.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_1_HINT="Suggested command: systemctl status cockpit.socket --no-pager > /tmp/exam/ch12_14_cockpit.txt 2>&1. Explanation: 2>&1 merges standard error into the standard-output stream before it is written. > overwrites the destination with standard output. systemctl queries systemd's current unit state."
TASK_1_COMMAND_1="systemctl status cockpit.socket --no-pager > /tmp/exam/ch12_14_cockpit.txt 2>&1"

TASK_2_QUESTION="Run firewall-cmd --query-service=cockpit and write both standard output and standard error to /tmp/exam/ch12_14_firewall.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_2_HINT="Suggested command: firewall-cmd --query-service=cockpit > /tmp/exam/ch12_14_firewall.txt 2>&1. Explanation: 2>&1 merges standard error into the standard-output stream before it is written. > overwrites the destination with standard output. without --permanent, firewall-cmd queries the current runtime configuration."
TASK_2_COMMAND_1="firewall-cmd --query-service=cockpit > /tmp/exam/ch12_14_firewall.txt 2>&1"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch12_14* /tmp/rhcsa_12_14 /var/tmp/rhcsa_12_14.img
}

_check_task_1_live() {
  [[ -f /tmp/exam/ch12_14_cockpit.txt ]]
}

_check_task_2_live() {
  [[ -f /tmp/exam/ch12_14_firewall.txt ]]
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
  rm -rf /tmp/exam/ch12_14* /tmp/rhcsa_12_14 /var/tmp/rhcsa_12_14.img
}
