#!/bin/bash
# Chapter 9: Manage users and groups
# Objective: memberships
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch09_004_sudo_policy_artifact_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="memberships"
QUESTION="Sudo policy artifact - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create sudo rule in /tmp/exam/ch09_04_sudoers"
TASK_1_HINT="Write %rhcsa_g04 ALL=(root) /usr/bin/id"
TASK_1_COMMAND_1="printf '%rhcsa_g04 ALL=(root) /usr/bin/id\\n' > /tmp/exam/ch09_04_sudoers"

TASK_2_QUESTION="Set mode 440 on /tmp/exam/ch09_04_sudoers"
TASK_2_HINT="Use chmod 440"
TASK_2_COMMAND_1="chmod 440 /tmp/exam/ch09_04_sudoers"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch09_04* /tmp/rhcsa_9_04 /var/tmp/rhcsa_9_04.img
}

_check_task_1_live() {
  [[ -s /tmp/exam/ch09_04_sudoers ]]
}

_check_task_2_live() {
  [[ "$(stat -c %a /tmp/exam/ch09_04_sudoers)" = 440 ]]
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
  rm -rf /tmp/exam/ch09_04* /tmp/rhcsa_9_04 /var/tmp/rhcsa_9_04.img; userdel -r rhcsa_u04 2>/dev/null || true; groupdel rhcsa_g04 2>/dev/null || true
}
