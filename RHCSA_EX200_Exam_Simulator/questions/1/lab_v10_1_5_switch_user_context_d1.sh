#!/bin/bash
# RHCSA v10 objective 1.5: Log in and switch users in multiuser targets
# Difficulty: 1/5

IS_LAB=true
LAB_ID="v10_1_5_switch_user_context_d1"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="1"
OBJECTIVE_TAG="Switch user context - practice level 1"
OBJECTIVE_IDS="1.5"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Switch user context - practice level 1"
LAB_TASK_COUNT=1

TASK_1_QUESTION="Run id -un in a login shell as rhcsa_switch and write the result to /tmp/exam/v10/1.5/user."
TASK_1_HINT="Use a login-shell user switch and execute one command."
TASK_1_COMMAND_1="su - rhcsa_switch -c \"id -un\" > /tmp/exam/v10/1.5/user"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/1.5; mkdir -p /tmp/exam/v10/1.5; id rhcsa_switch >/dev/null 2>&1 || useradd -m rhcsa_switch
}

_check_task_1_live() {
  grep -Fxq rhcsa_switch /tmp/exam/v10/1.5/user
}

check_tasks() {
  TASK_STATUS[0]="false"
  if _is_done 1; then
    TASK_STATUS[0]="true"
  elif _check_task_1_live; then
    TASK_STATUS[0]="true"
    _mark_done 1
  fi
}

cleanup_lab() {
  userdel -r rhcsa_switch >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/1.5
}
