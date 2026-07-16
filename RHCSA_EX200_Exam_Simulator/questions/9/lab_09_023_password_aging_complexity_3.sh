#!/bin/bash
# Chapter 9: Manage users and groups
# Objective: password aging
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch09_023_password_aging_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="password aging"
OBJECTIVE_IDS="9.1,9.2"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Password aging - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create local user rhcsa_u23 with the options required by the task title."
TASK_1_HINT="Use the local account-management command and verify the relevant database entry."
TASK_1_COMMAND_1="useradd -m rhcsa_u23"

TASK_2_QUESTION="Set the maximum password age for user rhcsa_u23 to exactly 45 days."
TASK_2_HINT="Use the local account-management command and verify the relevant database entry."
TASK_2_COMMAND_1="chage -M 45 rhcsa_u23"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch09_23* /tmp/rhcsa_9_23 /var/tmp/rhcsa_9_23.img
}

_check_task_1_live() {
  id rhcsa_u23 >/dev/null 2>&1
}

_check_task_2_live() {
  chage -l rhcsa_u23 | grep -Eqi "Maximum.*45"
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
  rm -rf /tmp/exam/ch09_23* /tmp/rhcsa_9_23 /var/tmp/rhcsa_9_23.img; userdel -r rhcsa_u23 2>/dev/null || true; groupdel rhcsa_g23 2>/dev/null || true
}
