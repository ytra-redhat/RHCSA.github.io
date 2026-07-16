#!/bin/bash
# RHCSA v10 objective 5.5: Configure file systems to mount at boot by UUID or label
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_5_5_configure_a_persistent_filesystem_mount_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Configure a persistent filesystem mount"
OBJECTIVE_IDS="5.5"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Configure a persistent filesystem mount"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create an ext4 filesystem labeled RHCSA_V10 on the device in /tmp/exam/v10/5.5/device."
TASK_1_HINT="Set the label while creating the filesystem."
TASK_1_COMMAND_1="mkfs.ext4 -F -L RHCSA_V10 \"\$(cat /tmp/exam/v10/5.5/device)\""

TASK_2_QUESTION="Mount it at /mnt/rhcsa-v10 and add a persistent /etc/fstab entry using its UUID."
TASK_2_HINT="Use the UUID rather than the device path."
TASK_2_COMMAND_1="mkdir -p /mnt/rhcsa-v10; uuid=\$(blkid -s UUID -o value \"\$(cat /tmp/exam/v10/5.5/device)\"); printf \"UUID=%s /mnt/rhcsa-v10 ext4 defaults 0 2\\n\" \"\$uuid\" >> /etc/fstab; mount /mnt/rhcsa-v10"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/5.5; mkdir -p /tmp/exam/v10/5.5; truncate -s 128M /tmp/exam/v10/5.5/disk.img; losetup --find --show /tmp/exam/v10/5.5/disk.img > /tmp/exam/v10/5.5/device; sed -i "\| /mnt/rhcsa-v10 |d" /etc/fstab; umount /mnt/rhcsa-v10 >/dev/null 2>&1 || true
}

_check_task_1_live() {
  [[ "$(blkid -s LABEL -o value "$(cat /tmp/exam/v10/5.5/device)")" == RHCSA_V10 ]]
}

_check_task_2_live() {
  findmnt -rn /mnt/rhcsa-v10 >/dev/null && grep -Eq "^UUID=[^ ]+ /mnt/rhcsa-v10 ext4 " /etc/fstab
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
  umount /mnt/rhcsa-v10 >/dev/null 2>&1 || true; sed -i "\| /mnt/rhcsa-v10 |d" /etc/fstab; dev=$(cat /tmp/exam/v10/5.5/device 2>/dev/null); [[ -n "$dev" ]] && losetup -d "$dev" >/dev/null 2>&1 || true; rmdir /mnt/rhcsa-v10 >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/5.5
}
