#!/bin/bash
# Chapter 6: Create and configure file systems
# Objective: mounting
# Difficulty: 4/5

IS_LAB=true
LAB_ID="ch06_036_filesystem_inventory_complexity_4"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="4"
OBJECTIVE_TAG="mounting"
OBJECTIVE_IDS="6.1"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Filesystem inventory - complexity 4"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Write the standard output of \`findmnt -o TARGET,SOURCE,FSTYPE\` to /tmp/exam/ch06_36_findmnt.txt."
TASK_1_HINT="Review the findmnt manual page and verify the requested final state."
TASK_1_COMMAND_1="findmnt -o TARGET,SOURCE,FSTYPE > /tmp/exam/ch06_36_findmnt.txt"

TASK_2_QUESTION="(command -v mkfs.xfs; command -v mkfs.ext4; command -v mkfs.vfat) and write both standard output and standard error to /tmp/exam/ch06_36_tools.txt."
TASK_2_HINT="Review the (command manual page and verify the requested final state."
TASK_2_COMMAND_1="(command -v mkfs.xfs; command -v mkfs.ext4; command -v mkfs.vfat) > /tmp/exam/ch06_36_tools.txt 2>&1"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch06_36* /tmp/rhcsa_6_36 /var/tmp/rhcsa_6_36.img
}

_check_task_1_live() {
  [[ -s /tmp/exam/ch06_36_findmnt.txt ]]
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch06_36_tools.txt ]]
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
  rm -rf /tmp/exam/ch06_36* /tmp/rhcsa_6_36 /var/tmp/rhcsa_6_36.img
}
