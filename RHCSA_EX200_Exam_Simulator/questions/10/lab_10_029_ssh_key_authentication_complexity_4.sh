#!/bin/bash
# Chapter 10: Manage security
# Objective: SELinux contexts
# Difficulty: 4/5

IS_LAB=true
LAB_ID="ch10_029_ssh_key_authentication_complexity_4"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="4"
OBJECTIVE_TAG="SELinux contexts"
QUESTION="SSH key authentication - complexity 4"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Generate an Ed25519 SSH key pair at /tmp/exam/ch10_29_key with an empty passphrase. Both /tmp/exam/ch10_29_key and /tmp/exam/ch10_29_key.pub must be created."
TASK_1_HINT="Suggested command: ssh-keygen -q -t ed25519 -N \"\" -f /tmp/exam/ch10_29_key. Explanation: -t selects Ed25519, -N sets the passphrase and -f selects the key path."
TASK_1_COMMAND_1="ssh-keygen -q -t ed25519 -N \"\" -f /tmp/exam/ch10_29_key"

TASK_2_QUESTION="Copy /tmp/exam/ch10_29_key.pub to /tmp/exam/ch10_29_authorized and set the resulting file's numeric mode to 600. The destination must contain the public key and have exactly that mode."
TASK_2_HINT="Suggested command: cp /tmp/exam/ch10_29_key.pub /tmp/exam/ch10_29_authorized; chmod 600 /tmp/exam/ch10_29_authorized. Explanation: run the command exactly as shown and verify the requested final state or output file."
TASK_2_COMMAND_1="cp /tmp/exam/ch10_29_key.pub /tmp/exam/ch10_29_authorized; chmod 600 /tmp/exam/ch10_29_authorized"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch10_29* /tmp/rhcsa_10_29 /var/tmp/rhcsa_10_29.img
}

_check_task_1_live() {
  [[ -f /tmp/exam/ch10_29_key.pub ]]
}

_check_task_2_live() {
  [[ "$(stat -c %a /tmp/exam/ch10_29_authorized)" = 600 ]]
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
  rm -rf /tmp/exam/ch10_29* /tmp/rhcsa_10_29 /var/tmp/rhcsa_10_29.img; semanage fcontext -d "/tmp/rhcsa_web_29(/.*)?" 2>/dev/null || true
}
