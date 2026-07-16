#!/bin/bash
# Chapter 9: Manage users and groups
# Objective: password aging
# Difficulty: 5/5

IS_LAB=true
LAB_ID="ch09_037_group_membership_complexity_5"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="5"
OBJECTIVE_TAG="password aging"
OBJECTIVE_IDS="9.1,9.2,9.3"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Group membership - complexity 5"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create local group rhcsa_g37."
TASK_1_HINT="Review the groupadd manual page and verify the requested final state."
TASK_1_COMMAND_1="groupadd rhcsa_g37"

TASK_2_QUESTION="Create local user rhcsa_u37 with the options required by the task title."
TASK_2_HINT="Review the useradd manual page and verify the requested final state."
TASK_2_COMMAND_1="useradd -m -G rhcsa_g37 rhcsa_u37"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch09_37* /tmp/rhcsa_9_37 /var/tmp/rhcsa_9_37.img
}

_check_task_1_live() {
  getent group rhcsa_g37 >/dev/null
}

_check_task_2_live() {
  id -nG rhcsa_u37 | grep -qw rhcsa_g37
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
  rm -rf /tmp/exam/ch09_37* /tmp/rhcsa_9_37 /var/tmp/rhcsa_9_37.img; userdel -r rhcsa_u37 2>/dev/null || true; groupdel rhcsa_g37 2>/dev/null || true
}
