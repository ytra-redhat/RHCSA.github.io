#!/bin/bash
# RHCSA v10 objective 10.5: List and identify SELinux file and process contexts
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_10_5_identify_selinux_contexts_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Identify SELinux contexts"
OBJECTIVE_IDS="10.5"
LAB_KIND="exam"
STATE_CHANGING="false"
PERSISTENCE_REQUIRED="false"
QUESTION="Identify SELinux contexts"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Write the full SELinux context of /etc/ssh/sshd_config to /tmp/exam/v10/10.5/file-context."
TASK_1_HINT="Use a context-aware file listing."
TASK_1_COMMAND_1="ls -Z /etc/ssh/sshd_config > /tmp/exam/v10/10.5/file-context"

TASK_2_QUESTION="Write the SELinux contexts of running sshd processes to /tmp/exam/v10/10.5/process-context."
TASK_2_HINT="Use a context-aware process listing and filter sshd."
TASK_2_COMMAND_1="ps -eZ | grep \"[s]shd\" > /tmp/exam/v10/10.5/process-context"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/10.5; mkdir -p /tmp/exam/v10/10.5; systemctl start sshd
}

_check_task_1_live() {
  grep -Eq "[[:alnum:]_]+_u:[[:alnum:]_]+_r:[[:alnum:]_]+_t:" /tmp/exam/v10/10.5/file-context
}

_check_task_2_live() {
  [[ -s /tmp/exam/v10/10.5/process-context ]]
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
  rm -rf /tmp/exam/v10/10.5
}
