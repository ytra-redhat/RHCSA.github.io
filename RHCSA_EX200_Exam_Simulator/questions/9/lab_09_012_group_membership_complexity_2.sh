#!/bin/bash
# Chapter 9: Manage users and groups
# Objective: sudo
# Difficulty: 2/5

IS_LAB=true
LAB_ID="ch09_012_group_membership_complexity_2"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="2"
OBJECTIVE_TAG="sudo"
OBJECTIVE_IDS="9.1,9.3"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Group membership - complexity 2"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create local group rhcsa_g12."
TASK_1_HINT="Use the local account-management command and verify the relevant database entry."
TASK_1_COMMAND_1="groupadd rhcsa_g12"

TASK_2_QUESTION="Create local user rhcsa_u12 with the options required by the task title."
TASK_2_HINT="Use the local account-management command and verify the relevant database entry."
TASK_2_COMMAND_1="useradd -m -G rhcsa_g12 rhcsa_u12"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch09_12* /tmp/rhcsa_9_12 /var/tmp/rhcsa_9_12.img
}

_check_task_1_live() {
  getent group rhcsa_g12 >/dev/null
}

_check_task_2_live() {
  id -nG rhcsa_u12 | grep -qw rhcsa_g12
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
  rm -rf /tmp/exam/ch09_12* /tmp/rhcsa_9_12 /var/tmp/rhcsa_9_12.img; userdel -r rhcsa_u12 2>/dev/null || true; groupdel rhcsa_g12 2>/dev/null || true
}
