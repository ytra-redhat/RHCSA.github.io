#!/bin/bash
# RHCSA v10 objective 1.4: Access remote systems using SSH
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_1_4_ssh_client_configuration_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="SSH client configuration"
OBJECTIVE_IDS="1.4"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="SSH client configuration"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create an Ed25519 key pair at /tmp/exam/v10/1.4/id_ed25519 without a passphrase."
TASK_1_HINT="Use ssh-keygen and specify the output path."
TASK_1_COMMAND_1="ssh-keygen -q -t ed25519 -N \"\" -f /tmp/exam/v10/1.4/id_ed25519"

TASK_2_QUESTION="Configure host alias rhcsa-local in /tmp/exam/v10/1.4/config for root@127.0.0.1 using that private key."
TASK_2_HINT="Use a Host block with HostName, User, and IdentityFile."
TASK_2_COMMAND_1="printf \"Host rhcsa-local\\n  HostName 127.0.0.1\\n  User root\\n  IdentityFile /tmp/exam/v10/1.4/id_ed25519\\n\" > /tmp/exam/v10/1.4/config"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/1.4; mkdir -p /tmp/exam/v10/1.4
}

_check_task_1_live() {
  [[ -f /tmp/exam/v10/1.4/id_ed25519 && -f /tmp/exam/v10/1.4/id_ed25519.pub ]]
}

_check_task_2_live() {
  grep -q "^Host rhcsa-local$" /tmp/exam/v10/1.4/config && grep -q "HostName 127.0.0.1" /tmp/exam/v10/1.4/config && grep -q "IdentityFile /tmp/exam/v10/1.4/id_ed25519" /tmp/exam/v10/1.4/config
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
  rm -rf /tmp/exam/v10/1.4
}
