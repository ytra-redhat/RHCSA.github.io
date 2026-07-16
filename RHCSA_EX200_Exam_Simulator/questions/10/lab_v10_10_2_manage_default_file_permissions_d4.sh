#!/bin/bash
# RHCSA v10 objective 10.2: Manage default file permissions
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_10_2_manage_default_file_permissions_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Manage default file permissions"
OBJECTIVE_IDS="10.2"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Manage default file permissions"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Configure login shells to use umask 027 through /etc/profile.d/rhcsa-v10-umask.sh."
TASK_1_HINT="Create a readable shell fragment."
TASK_1_COMMAND_1="printf \"umask 027\\n\" > /etc/profile.d/rhcsa-v10-umask.sh; chmod 0644 /etc/profile.d/rhcsa-v10-umask.sh"

TASK_2_QUESTION="Using a new Bash login shell, create /tmp/exam/v10/10.2/newfile and verify it receives mode 0640."
TASK_2_HINT="Source the profile fragment in a fresh shell before creating the file."
TASK_2_COMMAND_1="bash -lc \"source /etc/profile.d/rhcsa-v10-umask.sh; : > /tmp/exam/v10/10.2/newfile\""

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/10.2; mkdir -p /tmp/exam/v10/10.2; rm -f /etc/profile.d/rhcsa-v10-umask.sh
}

_check_task_1_live() {
  grep -Fxq "umask 027" /etc/profile.d/rhcsa-v10-umask.sh && [[ "$(stat -c %a /etc/profile.d/rhcsa-v10-umask.sh)" == 644 ]]
}

_check_task_2_live() {
  [[ "$(stat -c %a /tmp/exam/v10/10.2/newfile)" == 640 ]]
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
  rm -f /etc/profile.d/rhcsa-v10-umask.sh; rm -rf /tmp/exam/v10/10.2
}
