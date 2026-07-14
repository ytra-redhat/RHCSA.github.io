#!/bin/bash
# Chapter 10: Manage security
# Objective: port labels
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch10_023_selinux_booleans_and_ports_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="port labels"
QUESTION="SELinux booleans and ports - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Save httpd booleans in /tmp/exam/ch10_23_bool.txt"
TASK_1_HINT="Use getsebool -a | grep httpd"
TASK_1_COMMAND_1="getsebool -a | grep httpd > /tmp/exam/ch10_23_bool.txt"

TASK_2_QUESTION="Save http port labels in /tmp/exam/ch10_23_ports.txt"
TASK_2_HINT="Use semanage port -l | grep http_port_t"
TASK_2_COMMAND_1="semanage port -l | grep http_port_t > /tmp/exam/ch10_23_ports.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch10_23* /tmp/rhcsa_10_23 /var/tmp/rhcsa_10_23.img
}

_check_task_1_live() {
  [[ -s /tmp/exam/ch10_23_bool.txt ]]
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch10_23_ports.txt ]]
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
  rm -rf /tmp/exam/ch10_23* /tmp/rhcsa_10_23 /var/tmp/rhcsa_10_23.img; semanage fcontext -d "/tmp/rhcsa_web_23(/.*)?" 2>/dev/null || true
}
