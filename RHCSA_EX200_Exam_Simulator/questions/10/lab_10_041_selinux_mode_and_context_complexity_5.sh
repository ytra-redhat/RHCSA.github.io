#!/bin/bash
# Chapter 10: Manage security
# Objective: firewalld
# Difficulty: 5/5

IS_LAB=true
LAB_ID="ch10_041_selinux_mode_and_context_complexity_5"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="5"
OBJECTIVE_TAG="firewalld"
OBJECTIVE_IDS="10.1,10.4,10.5"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="SELinux mode and context - complexity 5"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Write the standard output of \`getenforce\` to /tmp/exam/ch10_41_mode.txt."
TASK_1_HINT="Review the getenforce manual page and verify the requested final state."
TASK_1_COMMAND_1="getenforce > /tmp/exam/ch10_41_mode.txt"

TASK_2_QUESTION="Write the standard output of \`ls -Z /etc/passwd\` to /tmp/exam/ch10_41_ctx.txt."
TASK_2_HINT="Review the ls manual page and verify the requested final state."
TASK_2_COMMAND_1="ls -Z /etc/passwd > /tmp/exam/ch10_41_ctx.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch10_41* /tmp/rhcsa_10_41 /var/tmp/rhcsa_10_41.img
}

_check_task_1_live() {
  [[ -s /tmp/exam/ch10_41_mode.txt ]]
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch10_41_ctx.txt ]]
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
  rm -rf /tmp/exam/ch10_41* /tmp/rhcsa_10_41 /var/tmp/rhcsa_10_41.img; semanage fcontext -d "/tmp/rhcsa_web_41(/.*)?" 2>/dev/null || true
}
