#!/bin/bash
# Chapter 12: Bonus RHEL 9 installation and legacy administration
# Objective: Cockpit
# Difficulty: 5/5

IS_LAB=true
LAB_ID="ch12_038_subscription_reports_complexity_5"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="5"
OBJECTIVE_TAG="Cockpit"
QUESTION="Subscription reports - complexity 5"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Save subscription identity in /tmp/exam/ch12_38_identity.txt"
TASK_1_HINT="Use subscription-manager identity"
TASK_1_COMMAND_1="subscription-manager identity > /tmp/exam/ch12_38_identity.txt 2>&1"

TASK_2_QUESTION="Save enabled subscription repositories in /tmp/exam/ch12_38_repos.txt"
TASK_2_HINT="Use subscription-manager repos --list-enabled"
TASK_2_COMMAND_1="subscription-manager repos --list-enabled > /tmp/exam/ch12_38_repos.txt 2>&1"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch12_38* /tmp/rhcsa_12_38 /var/tmp/rhcsa_12_38.img
}

_check_task_1_live() {
  [[ -f /tmp/exam/ch12_38_identity.txt ]]
}

_check_task_2_live() {
  [[ -f /tmp/exam/ch12_38_repos.txt ]]
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
  rm -rf /tmp/exam/ch12_38* /tmp/rhcsa_12_38 /var/tmp/rhcsa_12_38.img
}
