#!/bin/bash
# RHCSA v10 objective 9.3: Create, delete, and modify local groups and memberships
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_9_3_manage_groups_and_memberships_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Manage groups and memberships"
OBJECTIVE_IDS="9.3"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Manage groups and memberships"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create group project10 with GID 20110."
TASK_1_HINT="Use the specified numeric GID."
TASK_1_COMMAND_1="groupadd -g 20110 project10"

TASK_2_QUESTION="Add analyst10 to project10 as a supplementary member."
TASK_2_HINT="Do not replace existing supplementary memberships."
TASK_2_COMMAND_1="usermod -aG project10 analyst10"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  userdel -r analyst10 >/dev/null 2>&1 || true; groupdel project10 >/dev/null 2>&1 || true; useradd -m analyst10
}

_check_task_1_live() {
  [[ "$(getent group project10 | cut -d: -f3)" == 20110 ]]
}

_check_task_2_live() {
  id -nG analyst10 | tr " " "\n" | grep -Fxq project10
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
  userdel -r analyst10 >/dev/null 2>&1 || true; groupdel project10 >/dev/null 2>&1 || true
}
