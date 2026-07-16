#!/bin/bash
# Chapter 9: Manage users and groups
# Objective: groups
# Difficulty: 5/5

IS_LAB=true
LAB_ID="ch09_038_password_aging_complexity_5"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="5"
OBJECTIVE_TAG="groups"
QUESTION="Password aging - complexity 5"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create the local user account rhcsa_u38, create its home directory. The account and its home directory must both be present."
TASK_1_HINT="Suggested command: useradd -m rhcsa_u38. Explanation: useradd -m creates the account and its home directory."
TASK_1_COMMAND_1="useradd -m rhcsa_u38"

TASK_2_QUESTION="Set the maximum password age for user rhcsa_u38 to exactly 45 days. Verify that the account records that value."
TASK_2_HINT="Suggested command: chage -M 45 rhcsa_u38. Explanation: chage -M sets the maximum password lifetime in days."
TASK_2_COMMAND_1="chage -M 45 rhcsa_u38"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch09_38* /tmp/rhcsa_9_38 /var/tmp/rhcsa_9_38.img
}

_check_task_1_live() {
  id rhcsa_u38 >/dev/null 2>&1
}

_check_task_2_live() {
  chage -l rhcsa_u38 | grep -Eqi "Maximum.*45"
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
  rm -rf /tmp/exam/ch09_38* /tmp/rhcsa_9_38 /var/tmp/rhcsa_9_38.img; userdel -r rhcsa_u38 2>/dev/null || true; groupdel rhcsa_g38 2>/dev/null || true
}
