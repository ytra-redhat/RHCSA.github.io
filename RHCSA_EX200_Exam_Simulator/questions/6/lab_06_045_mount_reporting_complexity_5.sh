#!/bin/bash
# Chapter 6: Create and configure file systems
# Objective: NFS
# Difficulty: 5/5

IS_LAB=true
LAB_ID="ch06_045_mount_reporting_complexity_5"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="5"
OBJECTIVE_TAG="NFS"
QUESTION="Mount reporting - complexity 5"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Run findmnt and write the complete standard output to /tmp/exam/ch06_45_mounts.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_1_HINT="Suggested command: findmnt > /tmp/exam/ch06_45_mounts.txt. Explanation: > overwrites the destination with standard output. findmnt reports the currently mounted filesystem topology."
TASK_1_COMMAND_1="findmnt > /tmp/exam/ch06_45_mounts.txt"

TASK_2_QUESTION="Run (xfs_info / 2>/dev/null || lsblk -f) and write the complete standard output to /tmp/exam/ch06_45_xfs.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_2_HINT="Suggested command: (xfs_info / 2>/dev/null || lsblk -f) > /tmp/exam/ch06_45_xfs.txt. Explanation: 2> redirects only standard error, leaving standard output unchanged. > overwrites the destination with standard output."
TASK_2_COMMAND_1="(xfs_info / 2>/dev/null || lsblk -f) > /tmp/exam/ch06_45_xfs.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch06_45* /tmp/rhcsa_6_45 /var/tmp/rhcsa_6_45.img
}

_check_task_1_live() {
  [[ -s /tmp/exam/ch06_45_mounts.txt ]]
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch06_45_xfs.txt ]]
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
  rm -rf /tmp/exam/ch06_45* /tmp/rhcsa_6_45 /var/tmp/rhcsa_6_45.img
}
