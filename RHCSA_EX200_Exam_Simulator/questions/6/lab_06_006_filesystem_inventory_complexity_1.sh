#!/bin/bash
# Chapter 6: Create and configure file systems
# Objective: autofs
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch06_006_filesystem_inventory_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="autofs"
QUESTION="Filesystem inventory - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Run findmnt -o TARGET,SOURCE,FSTYPE and write the complete standard output to /tmp/exam/ch06_06_findmnt.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_1_HINT="Suggested command: findmnt -o TARGET,SOURCE,FSTYPE > /tmp/exam/ch06_06_findmnt.txt. Explanation: > overwrites the destination with standard output. findmnt reports the currently mounted filesystem topology."
TASK_1_COMMAND_1="findmnt -o TARGET,SOURCE,FSTYPE > /tmp/exam/ch06_06_findmnt.txt"

TASK_2_QUESTION="Run (command -v mkfs.xfs; command -v mkfs.ext4; command -v mkfs.vfat) and write both standard output and standard error to /tmp/exam/ch06_06_tools.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_2_HINT="Suggested command: (command -v mkfs.xfs; command -v mkfs.ext4; command -v mkfs.vfat) > /tmp/exam/ch06_06_tools.txt 2>&1. Explanation: 2>&1 merges standard error into the standard-output stream before it is written. > overwrites the destination with standard output."
TASK_2_COMMAND_1="(command -v mkfs.xfs; command -v mkfs.ext4; command -v mkfs.vfat) > /tmp/exam/ch06_06_tools.txt 2>&1"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch06_06* /tmp/rhcsa_6_06 /var/tmp/rhcsa_6_06.img
}

_check_task_1_live() {
  [[ -s /tmp/exam/ch06_06_findmnt.txt ]]
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch06_06_tools.txt ]]
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
  rm -rf /tmp/exam/ch06_06* /tmp/rhcsa_6_06 /var/tmp/rhcsa_6_06.img
}
