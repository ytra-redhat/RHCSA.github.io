#!/bin/bash
# RHCSA v10 objective 1.10: List, set, and change standard ugo/rwx permissions
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_1_10_standard_permissions_and_ownership_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Standard permissions and ownership"
OBJECTIVE_IDS="1.10"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Standard permissions and ownership"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Set /tmp/exam/v10/1.10/shared to mode 0640."
TASK_1_HINT="Set the exact user, group, and other bits."
TASK_1_COMMAND_1="chmod 0640 /tmp/exam/v10/1.10/shared"

TASK_2_QUESTION="Set the group owner of /tmp/exam/v10/1.10/shared to rhcsa_perm."
TASK_2_HINT="Change only the group owner."
TASK_2_COMMAND_1="chown :rhcsa_perm /tmp/exam/v10/1.10/shared"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/1.10; mkdir -p /tmp/exam/v10/1.10; groupget="$(getent group rhcsa_perm || true)"; [[ -n "$groupget" ]] || groupadd rhcsa_perm; touch /tmp/exam/v10/1.10/shared
}

_check_task_1_live() {
  [[ "$(stat -c %a /tmp/exam/v10/1.10/shared)" == 640 ]]
}

_check_task_2_live() {
  [[ "$(stat -c %G /tmp/exam/v10/1.10/shared)" == rhcsa_perm ]]
}

check_tasks() {
  TASK_STATUS[0]="false"
  if _is_done 1; then
    TASK_STATUS[0]="true"
  elif _check_task_1_live; then
    TASK_STATUS[0]="true"
    _mark_done 1
  fi
  TASK_STATUS[1]="false"
  if _is_done 2; then
    TASK_STATUS[1]="true"
  elif _check_task_2_live; then
    TASK_STATUS[1]="true"
    _mark_done 2
  fi
}

cleanup_lab() {
  groupdel rhcsa_perm >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/1.10
}
