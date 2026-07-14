#!/bin/bash
# Chapter 10: Manage security
# Objective: SELinux contexts
# Difficulty: 5/5

IS_LAB=true
LAB_ID="ch10_037_persistent_file_context_complexity_5"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="5"
OBJECTIVE_TAG="SELinux contexts"
QUESTION="Persistent file context - complexity 5"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create directory /tmp/rhcsa_web_37"
TASK_1_HINT="Use mkdir -p /tmp/rhcsa_web_37"
TASK_1_COMMAND_1="mkdir -p /tmp/rhcsa_web_37"

TASK_2_QUESTION="Assign persistent httpd_sys_content_t to /tmp/rhcsa_web_37"
TASK_2_HINT="Use semanage fcontext and restorecon"
TASK_2_COMMAND_1="semanage fcontext -a -t httpd_sys_content_t '/tmp/rhcsa_web_37(/.*)?'; restorecon -Rv /tmp/rhcsa_web_37"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch10_37* /tmp/rhcsa_10_37 /var/tmp/rhcsa_10_37.img
}

_check_task_1_live() {
  [[ -d /tmp/rhcsa_web_37 ]]
}

_check_task_2_live() {
  ls -Zd /tmp/rhcsa_web_37 | grep -q httpd_sys_content_t
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
  rm -rf /tmp/exam/ch10_37* /tmp/rhcsa_10_37 /var/tmp/rhcsa_10_37.img; semanage fcontext -d "/tmp/rhcsa_web_37(/.*)?" 2>/dev/null || true
}
