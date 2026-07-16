#!/bin/bash
# Chapter 10: Manage security
# Objective: umask
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch10_002_persistent_file_context_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="umask"
OBJECTIVE_IDS="10.2,10.6"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Persistent file context - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create directory /tmp/rhcsa_web_02, including missing parent directories."
TASK_1_HINT="Review the mkdir manual page and verify the requested final state."
TASK_1_COMMAND_1="mkdir -p /tmp/rhcsa_web_02"

TASK_2_QUESTION="Create a persistent SELinux file-context mapping that assigns type httpd_sys_content_t to /tmp/rhcsa_web_02(/.*)?, then apply the mapping immediately to /tmp/rhcsa_web_02 with restorecon."
TASK_2_HINT="Create a persistent SELinux policy mapping, then apply or verify it."
TASK_2_COMMAND_1="semanage fcontext -a -t httpd_sys_content_t '/tmp/rhcsa_web_02(/.*)?'; restorecon -Rv /tmp/rhcsa_web_02"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch10_02* /tmp/rhcsa_10_02 /var/tmp/rhcsa_10_02.img
}

_check_task_1_live() {
  [[ -d /tmp/rhcsa_web_02 ]]
}

_check_task_2_live() {
  ls -Zd /tmp/rhcsa_web_02 | grep -q httpd_sys_content_t
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
  rm -rf /tmp/exam/ch10_02* /tmp/rhcsa_10_02 /var/tmp/rhcsa_10_02.img; semanage fcontext -d "/tmp/rhcsa_web_02(/.*)?" 2>/dev/null || true
}
