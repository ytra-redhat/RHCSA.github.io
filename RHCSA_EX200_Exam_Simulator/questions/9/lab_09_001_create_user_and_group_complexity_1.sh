#!/bin/bash
# Chapter 9: Manage users and groups
# Objective: users
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch09_001_create_user_and_group_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="users"
QUESTION="Create user and group - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create user rhcsa_u01 with home"
TASK_1_HINT="Use useradd -m rhcsa_u01"
TASK_1_COMMAND_1="useradd -m rhcsa_u01"

TASK_2_QUESTION="Create group rhcsa_g01"
TASK_2_HINT="Use groupadd rhcsa_g01"
TASK_2_COMMAND_1="groupadd rhcsa_g01"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch09_01* /tmp/rhcsa_9_01 /var/tmp/rhcsa_9_01.img
}

_check_task_1_live() {
  id rhcsa_u01 >/dev/null 2>&1
}

_check_task_2_live() {
  getent group rhcsa_g01 >/dev/null
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
  rm -rf /tmp/exam/ch09_01* /tmp/rhcsa_9_01 /var/tmp/rhcsa_9_01.img; userdel -r rhcsa_u01 2>/dev/null || true; groupdel rhcsa_g01 2>/dev/null || true
}
