#!/bin/bash
# Chapter 8: Manage basic networking
# Objective: hostname resolution
# Difficulty: 2/5

IS_LAB=true
LAB_ID="ch08_017_ipv4_and_ipv6_inventory_complexity_2"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="2"
OBJECTIVE_TAG="hostname resolution"
QUESTION="IPv4 and IPv6 inventory - complexity 2"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Run ip -4 address show and write the complete standard output to /tmp/exam/ch08_17_ipv4.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_1_HINT="Suggested command: ip -4 address show > /tmp/exam/ch08_17_ipv4.txt. Explanation: > overwrites the destination with standard output."
TASK_1_COMMAND_1="ip -4 address show > /tmp/exam/ch08_17_ipv4.txt"

TASK_2_QUESTION="Run ip -6 address show and write the complete standard output to /tmp/exam/ch08_17_ipv6.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_2_HINT="Suggested command: ip -6 address show > /tmp/exam/ch08_17_ipv6.txt. Explanation: > overwrites the destination with standard output."
TASK_2_COMMAND_1="ip -6 address show > /tmp/exam/ch08_17_ipv6.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch08_17* /tmp/rhcsa_8_17 /var/tmp/rhcsa_8_17.img
}

_check_task_1_live() {
  [[ -s /tmp/exam/ch08_17_ipv4.txt ]]
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch08_17_ipv6.txt ]]
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
  rm -rf /tmp/exam/ch08_17* /tmp/rhcsa_8_17 /var/tmp/rhcsa_8_17.img
}
