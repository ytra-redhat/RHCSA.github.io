#!/bin/bash
# Chapter 11: Bonus RHEL 9 containers with Podman
# Objective: environment
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch11_006_podman_inventories_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="environment"
QUESTION="Podman inventories - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Save containers in /tmp/exam/ch11_06_containers.txt"
TASK_1_HINT="Use podman ps -a"
TASK_1_COMMAND_1="podman ps -a > /tmp/exam/ch11_06_containers.txt 2>&1"

TASK_2_QUESTION="Save images in /tmp/exam/ch11_06_images.txt"
TASK_2_HINT="Use podman images"
TASK_2_COMMAND_1="podman images > /tmp/exam/ch11_06_images.txt 2>&1"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch11_06* /tmp/rhcsa_11_06 /var/tmp/rhcsa_11_06.img
}

_check_task_1_live() {
  [[ -f /tmp/exam/ch11_06_containers.txt ]]
}

_check_task_2_live() {
  [[ -f /tmp/exam/ch11_06_images.txt ]]
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
  rm -rf /tmp/exam/ch11_06* /tmp/rhcsa_11_06 /var/tmp/rhcsa_11_06.img
}
