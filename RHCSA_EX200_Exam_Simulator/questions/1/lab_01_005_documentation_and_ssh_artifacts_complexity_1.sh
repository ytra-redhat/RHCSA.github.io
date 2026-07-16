#!/bin/bash
# Chapter 1: Understand and use essential tools
# Objective: text files
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch01_005_documentation_and_ssh_artifacts_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="text files"
QUESTION="Documentation and SSH artifacts - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Run apropos passwd and write the complete standard output to /tmp/exam/ch01_05_apropos.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_1_HINT="Suggested command: apropos passwd > /tmp/exam/ch01_05_apropos.txt. Explanation: > overwrites the destination with standard output."
TASK_1_COMMAND_1="apropos passwd > /tmp/exam/ch01_05_apropos.txt"

TASK_2_QUESTION="Generate an Ed25519 SSH key pair at /tmp/exam/ch01_05_key with an empty passphrase. Both /tmp/exam/ch01_05_key and /tmp/exam/ch01_05_key.pub must be created."
TASK_2_HINT="Suggested command: ssh-keygen -q -t ed25519 -N \"\" -f /tmp/exam/ch01_05_key. Explanation: -t selects Ed25519, -N sets the passphrase and -f selects the key path."
TASK_2_COMMAND_1="ssh-keygen -q -t ed25519 -N \"\" -f /tmp/exam/ch01_05_key"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch01_05* /tmp/rhcsa_1_05 /var/tmp/rhcsa_1_05.img
}

_check_task_1_live() {
  [[ -s /tmp/exam/ch01_05_apropos.txt ]]
}

_check_task_2_live() {
  [[ -f /tmp/exam/ch01_05_key && -f /tmp/exam/ch01_05_key.pub ]]
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
  rm -rf /tmp/exam/ch01_05* /tmp/rhcsa_1_05 /var/tmp/rhcsa_1_05.img
}
