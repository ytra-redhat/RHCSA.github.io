#!/bin/bash
# Chapter 5: Configure local storage
# Objective: swap
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch05_006_gpt_disk_image_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="swap"
QUESTION="GPT disk image - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create the disk-image file /var/tmp/rhcsa_06.img with an exact apparent size of 128M."
TASK_1_HINT="Suggested command: truncate -s 128M /var/tmp/rhcsa_06.img. Explanation: truncate -s sets the exact apparent file size."
TASK_1_COMMAND_1="truncate -s 128M /var/tmp/rhcsa_06.img"

TASK_2_QUESTION="Write a GPT partition-table label to disk image /var/tmp/rhcsa_06.img. Use non-interactive operation."
TASK_2_HINT="Suggested command: parted -s /var/tmp/rhcsa_06.img mklabel gpt. Explanation: -s runs non-interactively and mklabel writes the partition-table type."
TASK_2_COMMAND_1="parted -s /var/tmp/rhcsa_06.img mklabel gpt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch05_06* /tmp/rhcsa_5_06 /var/tmp/rhcsa_5_06.img
}

_check_task_1_live() {
  [[ "$(stat -c %s /var/tmp/rhcsa_06.img)" -eq 134217728 ]]
}

_check_task_2_live() {
  parted -s /var/tmp/rhcsa_06.img print | grep -qi gpt
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
  rm -rf /tmp/exam/ch05_06* /tmp/rhcsa_5_06 /var/tmp/rhcsa_5_06.img
}
