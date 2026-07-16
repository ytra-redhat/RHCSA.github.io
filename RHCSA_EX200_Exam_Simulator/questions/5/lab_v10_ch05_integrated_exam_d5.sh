#!/bin/bash
# RHCSA v10 objective 5.1: List, create, and delete partitions on GPT disks
# Difficulty: 5/5

IS_LAB=true
LAB_ID="v10_5_1_ch5_integrated_d5"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="5"
OBJECTIVE_TAG="Integrated RHCSA v10 chapter 5 scenario"
OBJECTIVE_IDS="5.1,5.2,5.3,5.4,5.5,5.6"
LAB_KIND="integrated-exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="mixed"
QUESTION="Integrated RHCSA v10 chapter 5 scenario"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create a 64 MiB logical volume /dev/v10int/data from the loop device recorded in /tmp/exam/v10/integrated5/device."
TASK_1_HINT="Build the PV and VG before the LV."
TASK_1_COMMAND_1="pvcreate -ff -y \"\$(cat /tmp/exam/v10/integrated5/device)\"; vgcreate v10int \"\$(cat /tmp/exam/v10/integrated5/device)\"; lvcreate -L 64M -n data v10int"

TASK_2_QUESTION="Create ext4 on /dev/v10int/data and mount it at /mnt/v10int using an fstab UUID entry."
TASK_2_HINT="Persist the mount by UUID."
TASK_2_COMMAND_1="mkfs.ext4 -F /dev/v10int/data >/dev/null; mkdir -p /mnt/v10int; uuid=\$(blkid -s UUID -o value /dev/v10int/data); printf \"UUID=%s /mnt/v10int ext4 defaults 0 2\\n\" \"\$uuid\" >> /etc/fstab; mount /mnt/v10int"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/integrated5; mkdir -p /tmp/exam/v10/integrated5; truncate -s 256M /tmp/exam/v10/integrated5/disk.img; losetup --find --show /tmp/exam/v10/integrated5/disk.img > /tmp/exam/v10/integrated5/device; sed -i "\| /mnt/v10int |d" /etc/fstab
}

_check_task_1_live() {
  lvs v10int/data >/dev/null 2>&1
}

_check_task_2_live() {
  findmnt -rn /mnt/v10int >/dev/null && grep -q " /mnt/v10int ext4 " /etc/fstab
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
  umount /mnt/v10int >/dev/null 2>&1 || true; sed -i "\| /mnt/v10int |d" /etc/fstab; vgremove -ff -y v10int >/dev/null 2>&1 || true; dev=$(cat /tmp/exam/v10/integrated5/device 2>/dev/null); [[ -n "$dev" ]] && losetup -d "$dev" >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/integrated5 /mnt/v10int
}
