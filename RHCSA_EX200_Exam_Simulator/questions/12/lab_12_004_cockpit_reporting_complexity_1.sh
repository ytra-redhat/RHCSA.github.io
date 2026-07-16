#!/bin/bash
# Chapter 12: Bonus RHEL 9 installation and legacy administration
# Objective: subscription management
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch12_004_cockpit_reporting_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="subscription management"
OBJECTIVE_IDS="12.0"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Cockpit reporting - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="systemctl status cockpit.socket --no-pager and write both standard output and standard error to /tmp/exam/ch12_04_cockpit.txt."
TASK_1_HINT="Use file descriptor 2 redirection."
TASK_1_COMMAND_1="systemctl status cockpit.socket --no-pager > /tmp/exam/ch12_04_cockpit.txt 2>&1"

TASK_2_QUESTION="firewall-cmd --query-service=cockpit and write both standard output and standard error to /tmp/exam/ch12_04_firewall.txt."
TASK_2_HINT="Use file descriptor 2 redirection."
TASK_2_COMMAND_1="firewall-cmd --query-service=cockpit > /tmp/exam/ch12_04_firewall.txt 2>&1"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch12_04* /tmp/rhcsa_12_04 /var/tmp/rhcsa_12_04.img
}

_check_task_1_live() {
  [[ -f /tmp/exam/ch12_04_cockpit.txt ]]
}

_check_task_2_live() {
  [[ -f /tmp/exam/ch12_04_firewall.txt ]]
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
  rm -rf /tmp/exam/ch12_04* /tmp/rhcsa_12_04 /var/tmp/rhcsa_12_04.img
}
