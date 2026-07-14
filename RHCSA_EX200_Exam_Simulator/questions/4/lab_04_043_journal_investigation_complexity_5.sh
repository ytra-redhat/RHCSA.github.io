#!/bin/bash
# Chapter 4: Operate running systems
# Objective: persistent journal
# Difficulty: 5/5

IS_LAB=true
LAB_ID="ch04_043_journal_investigation_complexity_5"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="5"
OBJECTIVE_TAG="persistent journal"
QUESTION="Journal investigation - complexity 5"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Save current boot warnings in /tmp/exam/ch04_43_warnings.txt"
TASK_1_HINT="Use journalctl -b -p warning --no-pager"
TASK_1_COMMAND_1="journalctl -b -p warning --no-pager > /tmp/exam/ch04_43_warnings.txt"

TASK_2_QUESTION="Save sshd journal entries in /tmp/exam/ch04_43_sshd.txt"
TASK_2_HINT="Use journalctl -u sshd --no-pager"
TASK_2_COMMAND_1="journalctl -u sshd --no-pager > /tmp/exam/ch04_43_sshd.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch04_43* /tmp/rhcsa_4_43 /var/tmp/rhcsa_4_43.img
}

_check_task_1_live() {
  [[ -f /tmp/exam/ch04_43_warnings.txt ]]
}

_check_task_2_live() {
  [[ -f /tmp/exam/ch04_43_sshd.txt ]]
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
  rm -rf /tmp/exam/ch04_43* /tmp/rhcsa_4_43 /var/tmp/rhcsa_4_43.img
}
