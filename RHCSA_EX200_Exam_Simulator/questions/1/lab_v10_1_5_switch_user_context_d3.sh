#!/bin/bash
# RHCSA v10 objective 1.5: Log in and switch users in multiuser targets
# Difficulty: 3/5

IS_LAB=true
LAB_ID="v10_1_5_switch_user_context_d3"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="3"
OBJECTIVE_TAG="Switch user context - practice level 3"
OBJECTIVE_IDS="1.5"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Switch user context - practice level 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Run id -un in a login shell as rhcsa_switch and write the result to /tmp/exam/v10/1.5/user."
TASK_1_HINT="Use a login-shell user switch and execute one command."
TASK_1_COMMAND_1="su - rhcsa_switch -c \"id -un\" > /tmp/exam/v10/1.5/user"

TASK_2_QUESTION="As rhcsa_switch, create ~/from-switch containing the account home directory."
TASK_2_HINT="Run the command in the target user context."
TASK_2_COMMAND_1="su - rhcsa_switch -c \"printf '%s\\n' '\$HOME' > ~/from-switch\""

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

_check_task_2_live() {
  [[ -f /home/rhcsa_switch/from-switch ]] && grep -Fxq /home/rhcsa_switch /home/rhcsa_switch/from-switch
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
  userdel -r rhcsa_switch >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/1.5
}
