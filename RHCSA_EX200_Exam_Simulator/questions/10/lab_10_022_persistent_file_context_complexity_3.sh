#!/bin/bash
# Chapter 10: Manage security
# Objective: restorecon
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch10_022_persistent_file_context_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="restorecon"
QUESTION="Persistent file context - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create directory /tmp/rhcsa_web_22, including any missing parent directories. The exact path must exist."
TASK_1_HINT="Suggested command: mkdir -p /tmp/rhcsa_web_22. Explanation: mkdir -p creates the directory and any missing parent directories."
TASK_1_COMMAND_1="mkdir -p /tmp/rhcsa_web_22"

TASK_2_QUESTION="Create a persistent SELinux file-context mapping that assigns type httpd_sys_content_t to /tmp/rhcsa_web_22(/.*)?, then apply the mapping immediately to /tmp/rhcsa_web_22 with restorecon."
TASK_2_HINT="Suggested command: semanage fcontext -a -t httpd_sys_content_t '/tmp/rhcsa_web_22(/.*)?'; restorecon -Rv /tmp/rhcsa_web_22. Explanation: semanage fcontext records a persistent SELinux mapping and restorecon applies it."
TASK_2_COMMAND_1="semanage fcontext -a -t httpd_sys_content_t '/tmp/rhcsa_web_22(/.*)?'; restorecon -Rv /tmp/rhcsa_web_22"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch10_22* /tmp/rhcsa_10_22 /var/tmp/rhcsa_10_22.img
}

_check_task_1_live() {
  [[ -d /tmp/rhcsa_web_22 ]]
}

_check_task_2_live() {
  ls -Zd /tmp/rhcsa_web_22 | grep -q httpd_sys_content_t
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
  rm -rf /tmp/exam/ch10_22* /tmp/rhcsa_10_22 /var/tmp/rhcsa_10_22.img; semanage fcontext -d "/tmp/rhcsa_web_22(/.*)?" 2>/dev/null || true
}
