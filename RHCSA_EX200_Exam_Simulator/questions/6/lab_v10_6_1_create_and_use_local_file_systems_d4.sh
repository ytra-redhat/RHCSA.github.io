#!/bin/bash
# RHCSA v10 objective 6.1: Create, mount, unmount, and use VFAT, ext4, and XFS file systems
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_6_1_create_and_use_local_file_systems_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Create and use local file systems"
OBJECTIVE_IDS="6.1"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Create and use local file systems"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create an XFS filesystem labeled V10XFS on the device in /tmp/exam/v10/6.1/xfs-device and mount it at /mnt/v10xfs."
TASK_1_HINT="Create the mount point and verify the filesystem type after mounting."
TASK_1_COMMAND_1="mkfs.xfs -f -L V10XFS \"\$(cat /tmp/exam/v10/6.1/xfs-device)\" >/dev/null; mkdir -p /mnt/v10xfs; mount \"\$(cat /tmp/exam/v10/6.1/xfs-device)\" /mnt/v10xfs"

TASK_2_QUESTION="Create an ext4 filesystem labeled V10EXT4 on the device in /tmp/exam/v10/6.1/ext4-device and mount it at /mnt/v10ext4."
TASK_2_HINT="Use the filesystem-specific creation tool."
TASK_2_COMMAND_1="mkfs.ext4 -F -L V10EXT4 \"\$(cat /tmp/exam/v10/6.1/ext4-device)\" >/dev/null; mkdir -p /mnt/v10ext4; mount \"\$(cat /tmp/exam/v10/6.1/ext4-device)\" /mnt/v10ext4"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/6.1; mkdir -p /tmp/exam/v10/6.1; for t in xfs ext4; do truncate -s 128M /tmp/exam/v10/6.1/$t.img; losetup --find --show /tmp/exam/v10/6.1/$t.img > /tmp/exam/v10/6.1/$t-device; done
}

_check_task_1_live() {
  [[ "$(findmnt -n -o FSTYPE /mnt/v10xfs)" == xfs ]]
}

_check_task_2_live() {
  [[ "$(findmnt -n -o FSTYPE /mnt/v10ext4)" == ext4 ]]
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
  umount /mnt/v10xfs /mnt/v10ext4 >/dev/null 2>&1 || true; for f in /tmp/exam/v10/6.1/*-device; do dev=$(cat "$f" 2>/dev/null); [[ -n "$dev" ]] && losetup -d "$dev" >/dev/null 2>&1 || true; done; rmdir /mnt/v10xfs /mnt/v10ext4 >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/6.1
}
