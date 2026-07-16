#!/bin/bash
# Chapter 9: Manage users and groups
# Objective: account modification
# Difficulty: 4/5

IS_LAB=true
LAB_ID="ch09_034_sudo_policy_artifact_complexity_4"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="4"
OBJECTIVE_TAG="account modification"
OBJECTIVE_IDS="9.1,9.4"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Sudo policy artifact - complexity 4"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create or overwrite /tmp/exam/ch09_34_sudoers with the following exact line(s): \"%rhcsa_g34 ALL=(root) /usr/bin/id\"."
TASK_1_HINT="Review the printf manual page and verify the requested final state."
TASK_1_COMMAND_1="printf '%rhcsa_g34 ALL=(root) /usr/bin/id\\n' > /tmp/exam/ch09_34_sudoers"

TASK_2_QUESTION="Set /tmp/exam/ch09_34_sudoers to permission mode 440."
TASK_2_HINT="Review the chmod manual page and verify the requested final state."
TASK_2_COMMAND_1="chmod 440 /tmp/exam/ch09_34_sudoers"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch09_34* /tmp/rhcsa_9_34 /var/tmp/rhcsa_9_34.img
}

_check_task_1_live() {
  [[ -s /tmp/exam/ch09_34_sudoers ]]
}

_check_task_2_live() {
  [[ "$(stat -c %a /tmp/exam/ch09_34_sudoers)" = 440 ]]
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
  rm -rf /tmp/exam/ch09_34* /tmp/rhcsa_9_34 /var/tmp/rhcsa_9_34.img; userdel -r rhcsa_u34 2>/dev/null || true; groupdel rhcsa_g34 2>/dev/null || true
}
