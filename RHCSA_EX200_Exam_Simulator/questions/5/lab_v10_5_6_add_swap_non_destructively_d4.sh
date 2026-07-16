#!/bin/bash
# RHCSA v10 objective 5.6: Add partitions, logical volumes, and swap non-destructively
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_5_6_add_swap_non_destructively_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Add swap non-destructively"
OBJECTIVE_IDS="5.6"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Add swap non-destructively"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create swap on the device in /tmp/exam/v10/5.6/device and activate it."
TASK_1_HINT="Initialize the device before enabling it."
TASK_1_COMMAND_1="mkswap \"\$(cat /tmp/exam/v10/5.6/device)\" >/dev/null && swapon \"\$(cat /tmp/exam/v10/5.6/device)\""

TASK_2_QUESTION="Add a persistent /etc/fstab swap entry using the device UUID."
TASK_2_HINT="Do not use the loop-device path in fstab."
TASK_2_COMMAND_1="uuid=\$(blkid -s UUID -o value \"\$(cat /tmp/exam/v10/5.6/device)\"); printf \"UUID=%s none swap defaults 0 0\\n\" \"\$uuid\" >> /etc/fstab"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/5.6; mkdir -p /tmp/exam/v10/5.6; truncate -s 128M /tmp/exam/v10/5.6/swap.img; losetup --find --show /tmp/exam/v10/5.6/swap.img > /tmp/exam/v10/5.6/device
}

_check_task_1_live() {
  swapon --show=NAME --noheadings | xargs -n1 | grep -Fxq "$(cat /tmp/exam/v10/5.6/device)"
}

_check_task_2_live() {
  uuid=$(blkid -s UUID -o value "$(cat /tmp/exam/v10/5.6/device)"); grep -Eq "^UUID=$uuid none swap " /etc/fstab
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
  dev=$(cat /tmp/exam/v10/5.6/device 2>/dev/null); swapoff "$dev" >/dev/null 2>&1 || true; uuid=$(blkid -s UUID -o value "$dev" 2>/dev/null); [[ -n "$uuid" ]] && sed -i "\|^UUID=$uuid none swap |d" /etc/fstab || true; [[ -n "$dev" ]] && losetup -d "$dev" >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/5.6
}
