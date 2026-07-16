#!/bin/bash
# RHCSA v10 objective 10.3: Configure key-based SSH authentication
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_10_3_configure_ssh_public_key_authentication_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Configure SSH public-key authentication"
OBJECTIVE_IDS="10.3"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Configure SSH public-key authentication"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create an Ed25519 key pair at /tmp/exam/v10/10.3/id_ed25519 without a passphrase."
TASK_1_HINT="Use a dedicated key path."
TASK_1_COMMAND_1="ssh-keygen -q -t ed25519 -N \"\" -f /tmp/exam/v10/10.3/id_ed25519"

TASK_2_QUESTION="Authorize that key for user sshuser10 with secure SSH directory and file modes."
TASK_2_HINT="The directory should be private and authorized_keys should not be writable by group or others."
TASK_2_COMMAND_1="install -d -m 700 -o sshuser10 -g sshuser10 /home/sshuser10/.ssh; install -m 600 -o sshuser10 -g sshuser10 /tmp/exam/v10/10.3/id_ed25519.pub /home/sshuser10/.ssh/authorized_keys"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/10.3; mkdir -p /tmp/exam/v10/10.3; id sshuser10 >/dev/null 2>&1 || useradd -m sshuser10
}

_check_task_1_live() {
  [[ -f /tmp/exam/v10/10.3/id_ed25519 && -f /tmp/exam/v10/10.3/id_ed25519.pub ]]
}

_check_task_2_live() {
  [[ "$(stat -c %a /home/sshuser10/.ssh)" == 700 && "$(stat -c %a /home/sshuser10/.ssh/authorized_keys)" == 600 ]] && cmp -s /tmp/exam/v10/10.3/id_ed25519.pub /home/sshuser10/.ssh/authorized_keys
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
  userdel -r sshuser10 >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/10.3
}
