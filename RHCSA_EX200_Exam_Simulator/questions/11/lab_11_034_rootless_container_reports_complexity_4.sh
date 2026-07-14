#!/bin/bash
# Chapter 11: Bonus RHEL 9 containers with Podman
# Objective: images
# Difficulty: 4/5

IS_LAB=true
LAB_ID="ch11_034_rootless_container_reports_complexity_4"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="4"
OBJECTIVE_TAG="images"
QUESTION="Rootless container reports - complexity 4"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Save subordinate IDs in /tmp/exam/ch11_34_subuid.txt"
TASK_1_HINT="Use grep for current user in /etc/subuid"
TASK_1_COMMAND_1="grep \"^\$(whoami):\" /etc/subuid > /tmp/exam/ch11_34_subuid.txt 2>&1"

TASK_2_QUESTION="Save podman info in /tmp/exam/ch11_34_info.txt"
TASK_2_HINT="Use podman info"
TASK_2_COMMAND_1="podman info > /tmp/exam/ch11_34_info.txt 2>&1"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch11_34* /tmp/rhcsa_11_34 /var/tmp/rhcsa_11_34.img
}

_check_task_1_live() {
  [[ -f /tmp/exam/ch11_34_subuid.txt ]]
}

_check_task_2_live() {
  [[ -f /tmp/exam/ch11_34_info.txt ]]
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
  rm -rf /tmp/exam/ch11_34* /tmp/rhcsa_11_34 /var/tmp/rhcsa_11_34.img
}
