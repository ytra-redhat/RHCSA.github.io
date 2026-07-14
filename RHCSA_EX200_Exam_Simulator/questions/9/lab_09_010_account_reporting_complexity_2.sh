#!/bin/bash
# Chapter 9: Manage users and groups
# Objective: groups
# Difficulty: 2/5

IS_LAB=true
LAB_ID="ch09_010_account_reporting_complexity_2"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="2"
OBJECTIVE_TAG="groups"
QUESTION="Account reporting - complexity 2"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Save root passwd entry in /tmp/exam/ch09_10_passwd.txt"
TASK_1_HINT="Use getent passwd root"
TASK_1_COMMAND_1="getent passwd root > /tmp/exam/ch09_10_passwd.txt"

TASK_2_QUESTION="Save root identity in /tmp/exam/ch09_10_id.txt"
TASK_2_HINT="Use id root"
TASK_2_COMMAND_1="id root > /tmp/exam/ch09_10_id.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch09_10* /tmp/rhcsa_9_10 /var/tmp/rhcsa_9_10.img
}

_check_task_1_live() {
  grep -Eq "^root:" /tmp/exam/ch09_10_passwd.txt
}

_check_task_2_live() {
  grep -q uid= /tmp/exam/ch09_10_id.txt
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
  rm -rf /tmp/exam/ch09_10* /tmp/rhcsa_9_10 /var/tmp/rhcsa_9_10.img; userdel -r rhcsa_u10 2>/dev/null || true; groupdel rhcsa_g10 2>/dev/null || true
}
