#!/bin/bash
# RHCSA v10 objective 5.4: Create and delete logical volumes
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_5_4_create_and_delete_a_logical_volume_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Create and delete a logical volume"
OBJECTIVE_IDS="5.4"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Create and delete a logical volume"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create logical volume data of size 64 MiB in rhcsa_v10_vg."
TASK_1_HINT="Use the exact LV name and size."
TASK_1_COMMAND_1="lvcreate -L 64M -n data rhcsa_v10_vg"

TASK_2_QUESTION="Remove rhcsa_v10_vg/data."
TASK_2_HINT="Complete task 1 before removing it."
TASK_2_COMMAND_1="lvremove -ff -y rhcsa_v10_vg/data"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/5.4; mkdir -p /tmp/exam/v10/5.4; truncate -s 256M /tmp/exam/v10/5.4/disk.img; losetup --find --show /tmp/exam/v10/5.4/disk.img > /tmp/exam/v10/5.4/device; pvcreate -ff -y "$(cat /tmp/exam/v10/5.4/device)" >/dev/null; vgcreate rhcsa_v10_vg "$(cat /tmp/exam/v10/5.4/device)" >/dev/null
}

_check_task_1_live() {
  lvs rhcsa_v10_vg/data >/dev/null 2>&1
}

_check_task_2_live() {
  ! lvs rhcsa_v10_vg/data >/dev/null 2>&1
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
  vgremove -ff -y rhcsa_v10_vg >/dev/null 2>&1 || true; dev=$(cat /tmp/exam/v10/5.4/device 2>/dev/null); [[ -n "$dev" ]] && losetup -d "$dev" >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/5.4
}
