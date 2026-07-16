#!/bin/bash
# RHCSA v10 objective 5.1: List, create, and delete partitions on GPT disks
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_5_1_create_and_delete_gpt_partitions_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Create and delete GPT partitions"
OBJECTIVE_IDS="5.1"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Create and delete GPT partitions"
LAB_TASK_COUNT=2

TASK_1_QUESTION="On the device named in /tmp/exam/v10/5.1/device, create a GPT table and one 64 MiB partition starting at 1 MiB."
TASK_1_HINT="Use noninteractive parted with MiB units."
TASK_1_COMMAND_1="dev=\$(cat /tmp/exam/v10/5.1/device); parted -s \"\$dev\" mklabel gpt mkpart primary 1MiB 65MiB"

TASK_2_QUESTION="Delete partition 1 from that device."
TASK_2_HINT="Remove the partition by number."
TASK_2_COMMAND_1="dev=\$(cat /tmp/exam/v10/5.1/device); parted -s \"\$dev\" rm 1"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/5.1; mkdir -p /tmp/exam/v10/5.1; truncate -s 128M /tmp/exam/v10/5.1/disk.img; losetup --find --show --partscan /tmp/exam/v10/5.1/disk.img > /tmp/exam/v10/5.1/device
}

_check_task_1_live() {
  dev=$(cat /tmp/exam/v10/5.1/device); parted -s "$dev" unit MiB print | grep -Eq "^ 1[[:space:]]"
}

_check_task_2_live() {
  dev=$(cat /tmp/exam/v10/5.1/device); ! parted -s "$dev" print | grep -Eq "^ 1[[:space:]]"
}

check_tasks() {
  TASK_STATUS[0]="false"
  if _is_done 1; then
    TASK_STATUS[0]="true"
  elif _check_task_1_live; then
    TASK_STATUS[0]="true"
    _mark_done 1
  fi
  TASK_STATUS[1]="false"
  if _is_done 2; then
    TASK_STATUS[1]="true"
  elif _check_task_2_live; then
    TASK_STATUS[1]="true"
    _mark_done 2
  fi
}

cleanup_lab() {
  dev=$(cat /tmp/exam/v10/5.1/device 2>/dev/null); [[ -n "$dev" ]] && losetup -d "$dev" >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/5.1
}
