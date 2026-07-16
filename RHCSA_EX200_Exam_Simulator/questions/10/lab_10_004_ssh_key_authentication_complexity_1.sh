#!/bin/bash
# Chapter 10: Manage security
# Objective: SELinux modes
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch10_004_ssh_key_authentication_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="SELinux modes"
OBJECTIVE_IDS="10.3,10.4"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="SSH key authentication - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create an Ed25519 SSH key pair at /tmp/exam/ch10_04_key without a passphrase."
TASK_1_HINT="Use ssh-keygen with the requested key type, path, and passphrase policy."
TASK_1_COMMAND_1="ssh-keygen -q -t ed25519 -N \"\" -f /tmp/exam/ch10_04_key"

TASK_2_QUESTION="Copy /tmp/exam/ch10_04_key.pub to /tmp/exam/ch10_04_authorized and set the resulting file's numeric mode to 600. The destination must contain the public key and have exactly that mode."
TASK_2_HINT="Review the cp manual page and verify the requested final state."
TASK_2_COMMAND_1="cp /tmp/exam/ch10_04_key.pub /tmp/exam/ch10_04_authorized; chmod 600 /tmp/exam/ch10_04_authorized"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch10_04* /tmp/rhcsa_10_04 /var/tmp/rhcsa_10_04.img
}

_check_task_1_live() {
  [[ -f /tmp/exam/ch10_04_key.pub ]]
}

_check_task_2_live() {
  [[ "$(stat -c %a /tmp/exam/ch10_04_authorized)" = 600 ]]
}

check_tasks() {
  TASK_STATUS[0]="false"
  TASK_STATUS[1]="false"
  if _is_done 1; then
    TASK_STATUS[0]="true"
  elif _check_task_1_live; then
    TASK_STATUS[0]="true"
    _mark_done 1
  fi
  if _is_done 2; then
    TASK_STATUS[1]="true"
  elif _check_task_2_live; then
    TASK_STATUS[1]="true"
    _mark_done 2
  fi
}

cleanup_lab() {
  rm -rf /tmp/exam/ch10_04* /tmp/rhcsa_10_04 /var/tmp/rhcsa_10_04.img; semanage fcontext -d "/tmp/rhcsa_web_04(/.*)?" 2>/dev/null || true
}
