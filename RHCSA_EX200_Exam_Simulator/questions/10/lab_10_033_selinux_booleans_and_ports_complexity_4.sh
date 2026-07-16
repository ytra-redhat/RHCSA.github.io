#!/bin/bash
# Chapter 10: Manage security
# Objective: firewalld
# Difficulty: 4/5

IS_LAB=true
LAB_ID="ch10_033_selinux_booleans_and_ports_complexity_4"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="4"
OBJECTIVE_TAG="firewalld"
OBJECTIVE_IDS="10.1,10.7,10.8"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="SELinux booleans and ports - complexity 4"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Write the standard output of \`getsebool -a | grep httpd\` to /tmp/exam/ch10_33_bool.txt."
TASK_1_HINT="Review the getsebool manual page and verify the requested final state."
TASK_1_COMMAND_1="getsebool -a | grep httpd > /tmp/exam/ch10_33_bool.txt"

TASK_2_QUESTION="Write the standard output of \`semanage port -l | grep http_port_t\` to /tmp/exam/ch10_33_ports.txt."
TASK_2_HINT="Review the semanage manual page and verify the requested final state."
TASK_2_COMMAND_1="semanage port -l | grep http_port_t > /tmp/exam/ch10_33_ports.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch10_33* /tmp/rhcsa_10_33 /var/tmp/rhcsa_10_33.img
}

_check_task_1_live() {
  [[ -s /tmp/exam/ch10_33_bool.txt ]]
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch10_33_ports.txt ]]
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
  rm -rf /tmp/exam/ch10_33* /tmp/rhcsa_10_33 /var/tmp/rhcsa_10_33.img; semanage fcontext -d "/tmp/rhcsa_web_33(/.*)?" 2>/dev/null || true
}
