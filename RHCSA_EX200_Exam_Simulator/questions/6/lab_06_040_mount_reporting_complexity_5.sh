#!/bin/bash
# Chapter 6: Create and configure file systems
# Objective: permissions
# Difficulty: 5/5

IS_LAB=true
LAB_ID="ch06_040_mount_reporting_complexity_5"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="5"
OBJECTIVE_TAG="permissions"
QUESTION="Mount reporting - complexity 5"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Save current mounts in /tmp/exam/ch06_40_mounts.txt"
TASK_1_HINT="Use findmnt"
TASK_1_COMMAND_1="findmnt > /tmp/exam/ch06_40_mounts.txt"

TASK_2_QUESTION="Save XFS information or lsblk fallback in /tmp/exam/ch06_40_xfs.txt"
TASK_2_HINT="Use xfs_info / or lsblk -f"
TASK_2_COMMAND_1="(xfs_info / 2>/dev/null || lsblk -f) > /tmp/exam/ch06_40_xfs.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch06_40* /tmp/rhcsa_6_40 /var/tmp/rhcsa_6_40.img
}

_check_task_1_live() {
  [[ -s /tmp/exam/ch06_40_mounts.txt ]]
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch06_40_xfs.txt ]]
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
  rm -rf /tmp/exam/ch06_40* /tmp/rhcsa_6_40 /var/tmp/rhcsa_6_40.img
}
