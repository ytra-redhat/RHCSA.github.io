#!/bin/bash
# Chapter 8: Manage basic networking
# Objective: hostname resolution
# Difficulty: 5/5

IS_LAB=true
LAB_ID="ch08_038_hostname_resolution_complexity_5"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="5"
OBJECTIVE_TAG="hostname resolution"
QUESTION="Hostname resolution - complexity 5"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create or overwrite /tmp/exam/ch08_38_hosts with the following exact line(s): \"192.0.2.38 server38.example.com server38\"."
TASK_1_HINT="Suggested command: printf '192.0.2.38 server38.example.com server38\\n' > /tmp/exam/ch08_38_hosts. Explanation: > overwrites the destination with standard output. printf writes deterministic text, including the requested line breaks."
TASK_1_COMMAND_1="printf '192.0.2.38 server38.example.com server38\\n' > /tmp/exam/ch08_38_hosts"

TASK_2_QUESTION="Run cat /etc/resolv.conf and write the complete standard output to /tmp/exam/ch08_38_resolver.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_2_HINT="Suggested command: cat /etc/resolv.conf > /tmp/exam/ch08_38_resolver.txt. Explanation: > overwrites the destination with standard output."
TASK_2_COMMAND_1="cat /etc/resolv.conf > /tmp/exam/ch08_38_resolver.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch08_38* /tmp/rhcsa_8_38 /var/tmp/rhcsa_8_38.img
}

_check_task_1_live() {
  [[ -s /tmp/exam/ch08_38_hosts ]]
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch08_38_resolver.txt ]]
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
  rm -rf /tmp/exam/ch08_38* /tmp/rhcsa_8_38 /var/tmp/rhcsa_8_38.img
}
