#!/bin/bash
# Chapter 10: Manage security
# Objective: SELinux modes
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch10_020_firewall_runtime_and_permanent_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="SELinux modes"
QUESTION="Firewall runtime and permanent - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Save runtime services in /tmp/exam/ch10_20_runtime.txt"
TASK_1_HINT="Use firewall-cmd --zone=public --list-services"
TASK_1_COMMAND_1="firewall-cmd --zone=public --list-services > /tmp/exam/ch10_20_runtime.txt 2>&1"

TASK_2_QUESTION="Save permanent services in /tmp/exam/ch10_20_permanent.txt"
TASK_2_HINT="Use firewall-cmd --permanent --zone=public --list-services"
TASK_2_COMMAND_1="firewall-cmd --permanent --zone=public --list-services > /tmp/exam/ch10_20_permanent.txt 2>&1"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch10_20* /tmp/rhcsa_10_20 /var/tmp/rhcsa_10_20.img
}

_check_task_1_live() {
  [[ -f /tmp/exam/ch10_20_runtime.txt ]]
}

_check_task_2_live() {
  [[ -f /tmp/exam/ch10_20_permanent.txt ]]
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
  rm -rf /tmp/exam/ch10_20* /tmp/rhcsa_10_20 /var/tmp/rhcsa_10_20.img; semanage fcontext -d "/tmp/rhcsa_web_20(/.*)?" 2>/dev/null || true
}
