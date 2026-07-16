#!/bin/bash
# RHCSA v10 objective 9.1: Create, delete, and modify local user accounts
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_9_1_manage_a_local_user_account_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Manage a local user account"
OBJECTIVE_IDS="9.1"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Manage a local user account"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create user analyst10 with UID 10110, home /srv/analyst10, and shell /bin/bash."
TASK_1_HINT="Create the specified home directory."
TASK_1_COMMAND_1="useradd -u 10110 -d /srv/analyst10 -m -s /bin/bash analyst10"

TASK_2_QUESTION="Change analyst10 comment to RHCSA v10 Analyst."
TASK_2_HINT="Modify the existing account."
TASK_2_COMMAND_1="usermod -c \"RHCSA v10 Analyst\" analyst10"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  userdel -r analyst10 >/dev/null 2>&1 || true; rm -rf /srv/analyst10
}

_check_task_1_live() {
  [[ "$(id -u analyst10)" == 10110 && "$(getent passwd analyst10 | cut -d: -f6)" == /srv/analyst10 && -d /srv/analyst10 ]]
}

_check_task_2_live() {
  [[ "$(getent passwd analyst10 | cut -d: -f5)" == "RHCSA v10 Analyst" ]]
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
  userdel -r analyst10 >/dev/null 2>&1 || true; rm -rf /srv/analyst10
}
