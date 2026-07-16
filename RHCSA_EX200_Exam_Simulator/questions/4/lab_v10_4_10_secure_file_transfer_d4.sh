#!/bin/bash
# RHCSA v10 objective 4.10: Securely transfer files between systems
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_4_10_secure_file_transfer_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Secure file transfer"
OBJECTIVE_IDS="4.10"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Secure file transfer"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Copy /etc/hosts over SSH to /tmp/exam/v10/4.10/hosts.copy using user rhcsa_scp at 127.0.0.1 and /tmp/exam/v10/4.10/id_ed25519."
TASK_1_HINT="Use scp with the prepared private key."
TASK_1_COMMAND_1="scp -q -o StrictHostKeyChecking=no -i /tmp/exam/v10/4.10/id_ed25519 rhcsa_scp@127.0.0.1:/etc/hosts /tmp/exam/v10/4.10/hosts.copy"

TASK_2_QUESTION="Copy /tmp/exam/v10/4.10/upload to /home/rhcsa_scp/uploaded over SSH."
TASK_2_HINT="Use the same account and key."
TASK_2_COMMAND_1="scp -q -o StrictHostKeyChecking=no -i /tmp/exam/v10/4.10/id_ed25519 /tmp/exam/v10/4.10/upload rhcsa_scp@127.0.0.1:/home/rhcsa_scp/uploaded"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/4.10; mkdir -p /tmp/exam/v10/4.10; id rhcsa_scp >/dev/null 2>&1 || useradd -m rhcsa_scp; ssh-keygen -q -t ed25519 -N "" -f /tmp/exam/v10/4.10/id_ed25519; install -d -m 700 -o rhcsa_scp -g rhcsa_scp /home/rhcsa_scp/.ssh; install -m 600 -o rhcsa_scp -g rhcsa_scp /tmp/exam/v10/4.10/id_ed25519.pub /home/rhcsa_scp/.ssh/authorized_keys; printf upload > /tmp/exam/v10/4.10/upload; systemctl start sshd
}

_check_task_1_live() {
  cmp -s /etc/hosts /tmp/exam/v10/4.10/hosts.copy
}

_check_task_2_live() {
  [[ -f /home/rhcsa_scp/uploaded ]] && cmp -s /tmp/exam/v10/4.10/upload /home/rhcsa_scp/uploaded
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
  userdel -r rhcsa_scp >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/4.10
}
