#!/bin/bash
# Chapter 9: Manage users and groups
# Objective: account removal
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch09_007_group_membership_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="account removal"
QUESTION="Group membership - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create group rhcsa_g07"
TASK_1_HINT="Use groupadd rhcsa_g07"
TASK_1_COMMAND_1="groupadd rhcsa_g07"

TASK_2_QUESTION="Create user rhcsa_u07 in supplementary group rhcsa_g07"
TASK_2_HINT="Use useradd -m -G rhcsa_g07 rhcsa_u07"
TASK_2_COMMAND_1="useradd -m -G rhcsa_g07 rhcsa_u07"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch09_07* /tmp/rhcsa_9_07 /var/tmp/rhcsa_9_07.img
}

_check_task_1_live() {
  getent group rhcsa_g07 >/dev/null
}

_check_task_2_live() {
  id -nG rhcsa_u07 | grep -qw rhcsa_g07
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
  rm -rf /tmp/exam/ch09_07* /tmp/rhcsa_9_07 /var/tmp/rhcsa_9_07.img; userdel -r rhcsa_u07 2>/dev/null || true; groupdel rhcsa_g07 2>/dev/null || true
}
