#!/bin/bash
# RHCSA v10 objective 5.2: Create and remove physical volumes
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_5_2_create_and_remove_an_lvm_physical_volume_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Create and remove an LVM physical volume"
OBJECTIVE_IDS="5.2"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Create and remove an LVM physical volume"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Initialize the device named in /tmp/exam/v10/5.2/device as an LVM physical volume."
TASK_1_HINT="Read the exact device name from the prepared file."
TASK_1_COMMAND_1="pvcreate -ff -y \"\$(cat /tmp/exam/v10/5.2/device)\""

TASK_2_QUESTION="Remove the LVM physical-volume label from that device."
TASK_2_HINT="Complete task 1 before removing the label."
TASK_2_COMMAND_1="pvremove -ff -y \"\$(cat /tmp/exam/v10/5.2/device)\""

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/5.2; mkdir -p /tmp/exam/v10/5.2; truncate -s 128M /tmp/exam/v10/5.2/disk.img; losetup --find --show /tmp/exam/v10/5.2/disk.img > /tmp/exam/v10/5.2/device
}

_check_task_1_live() {
  pvs --noheadings -o pv_name | grep -Fxq "  $(cat /tmp/exam/v10/5.2/device)" || pvs --noheadings -o pv_name | xargs -n1 | grep -Fxq "$(cat /tmp/exam/v10/5.2/device)"
}

_check_task_2_live() {
  ! pvs --noheadings -o pv_name 2>/dev/null | xargs -n1 | grep -Fxq "$(cat /tmp/exam/v10/5.2/device)"
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
  dev=$(cat /tmp/exam/v10/5.2/device 2>/dev/null); [[ -n "$dev" ]] && pvremove -ff -y "$dev" >/dev/null 2>&1 || true; [[ -n "$dev" ]] && losetup -d "$dev" >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/5.2
}
