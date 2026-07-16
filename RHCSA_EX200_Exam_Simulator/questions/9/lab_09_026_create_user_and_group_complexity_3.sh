#!/bin/bash
# Chapter 9: Manage users and groups
# Objective: sudo
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch09_026_create_user_and_group_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="sudo"
QUESTION="Create user and group - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create the local user account rhcsa_u26, create its home directory. The account and its home directory must both be present."
TASK_1_HINT="Suggested command: useradd -m rhcsa_u26. Explanation: useradd -m creates the account and its home directory."
TASK_1_COMMAND_1="useradd -m rhcsa_u26"

TASK_2_QUESTION="Create the local group rhcsa_g26. The group must exist in the local group database."
TASK_2_HINT="Suggested command: groupadd rhcsa_g26. Explanation: groupadd creates a local group entry with the exact name supplied."
TASK_2_COMMAND_1="groupadd rhcsa_g26"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch09_26* /tmp/rhcsa_9_26 /var/tmp/rhcsa_9_26.img
}

_check_task_1_live() {
  id rhcsa_u26 >/dev/null 2>&1
}

_check_task_2_live() {
  getent group rhcsa_g26 >/dev/null
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
  rm -rf /tmp/exam/ch09_26* /tmp/rhcsa_9_26 /var/tmp/rhcsa_9_26.img; userdel -r rhcsa_u26 2>/dev/null || true; groupdel rhcsa_g26 2>/dev/null || true
}
