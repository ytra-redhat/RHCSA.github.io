#!/bin/bash
# Chapter 6: Create and configure file systems
# Objective: VFAT
# Difficulty: 4/5

IS_LAB=true
LAB_ID="ch06_033_autofs_maps_complexity_4"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="4"
OBJECTIVE_TAG="VFAT"
QUESTION="Autofs maps - complexity 4"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create or overwrite /tmp/exam/ch06_33_master with the following exact line(s): \"/shares /tmp/exam/ch06_33_map\"."
TASK_1_HINT="Suggested command: printf '/shares /tmp/exam/ch06_33_map\\n' > /tmp/exam/ch06_33_master. Explanation: > overwrites the destination with standard output. printf writes deterministic text, including the requested line breaks."
TASK_1_COMMAND_1="printf '/shares /tmp/exam/ch06_33_map\\n' > /tmp/exam/ch06_33_master"

TASK_2_QUESTION="Create or overwrite /tmp/exam/ch06_33_map with the following exact line(s): \"docs -fstype=nfs server:/docs\"."
TASK_2_HINT="Suggested command: printf 'docs -fstype=nfs server:/docs\\n' > /tmp/exam/ch06_33_map. Explanation: > overwrites the destination with standard output. printf writes deterministic text, including the requested line breaks."
TASK_2_COMMAND_1="printf 'docs -fstype=nfs server:/docs\\n' > /tmp/exam/ch06_33_map"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch06_33* /tmp/rhcsa_6_33 /var/tmp/rhcsa_6_33.img
}

_check_task_1_live() {
  grep -Fxq "/shares /tmp/exam/ch06_33_map" /tmp/exam/ch06_33_master
}

_check_task_2_live() {
  grep -Fxq "docs -fstype=nfs server:/docs" /tmp/exam/ch06_33_map
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
  rm -rf /tmp/exam/ch06_33* /tmp/rhcsa_6_33 /var/tmp/rhcsa_6_33.img
}
