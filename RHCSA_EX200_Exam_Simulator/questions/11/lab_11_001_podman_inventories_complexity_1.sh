#!/bin/bash
# Chapter 11: Bonus RHEL 9 containers with Podman
# Objective: rootless containers
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch11_001_podman_inventories_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="rootless containers"
QUESTION="Podman inventories - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Run podman ps -a and write both standard output and standard error to /tmp/exam/ch11_01_containers.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_1_HINT="Suggested command: podman ps -a > /tmp/exam/ch11_01_containers.txt 2>&1. Explanation: 2>&1 merges standard error into the standard-output stream before it is written. > overwrites the destination with standard output. podman reports the current container-engine state for the executing user."
TASK_1_COMMAND_1="podman ps -a > /tmp/exam/ch11_01_containers.txt 2>&1"

TASK_2_QUESTION="Run podman images and write both standard output and standard error to /tmp/exam/ch11_01_images.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_2_HINT="Suggested command: podman images > /tmp/exam/ch11_01_images.txt 2>&1. Explanation: 2>&1 merges standard error into the standard-output stream before it is written. > overwrites the destination with standard output. podman reports the current container-engine state for the executing user."
TASK_2_COMMAND_1="podman images > /tmp/exam/ch11_01_images.txt 2>&1"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch11_01* /tmp/rhcsa_11_01 /var/tmp/rhcsa_11_01.img
}

_check_task_1_live() {
  [[ -f /tmp/exam/ch11_01_containers.txt ]]
}

_check_task_2_live() {
  [[ -f /tmp/exam/ch11_01_images.txt ]]
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
  rm -rf /tmp/exam/ch11_01* /tmp/rhcsa_11_01 /var/tmp/rhcsa_11_01.img
}
