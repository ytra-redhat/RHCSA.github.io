#!/bin/bash
# RHCSA v10 objective 6.4: Extend existing logical volumes
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_6_4_extend_a_logical_volume_and_filesystem_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Extend a logical volume and filesystem"
OBJECTIVE_IDS="6.4"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Extend a logical volume and filesystem"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Extend /dev/rhcsa_v10_vg/data by 64 MiB and grow its ext4 filesystem."
TASK_1_HINT="Grow the LV and filesystem in one operation or in two verified steps."
TASK_1_COMMAND_1="lvextend -r -L +64M /dev/rhcsa_v10_vg/data"

TASK_2_QUESTION="Write the resulting filesystem size in bytes to /tmp/exam/v10/6.4/size."
TASK_2_HINT="Query the mounted filesystem rather than the image file."
TASK_2_COMMAND_1="stat -f -c %S:%b /mnt/rhcsa-v10-lv > /tmp/exam/v10/6.4/size"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/6.4; mkdir -p /tmp/exam/v10/6.4 /mnt/rhcsa-v10-lv; truncate -s 256M /tmp/exam/v10/6.4/disk.img; losetup --find --show /tmp/exam/v10/6.4/disk.img > /tmp/exam/v10/6.4/device; pvcreate -ff -y "$(cat /tmp/exam/v10/6.4/device)" >/dev/null; vgcreate rhcsa_v10_vg "$(cat /tmp/exam/v10/6.4/device)" >/dev/null; lvcreate -L 64M -n data rhcsa_v10_vg >/dev/null; mkfs.ext4 -F /dev/rhcsa_v10_vg/data >/dev/null; mount /dev/rhcsa_v10_vg/data /mnt/rhcsa-v10-lv
}

_check_task_1_live() {
  [[ "$(lvs --noheadings --units m --nosuffix -o lv_size rhcsa_v10_vg/data | xargs | cut -d. -f1)" -ge 120 ]]
}

_check_task_2_live() {
  [[ -s /tmp/exam/v10/6.4/size ]]
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
  umount /mnt/rhcsa-v10-lv >/dev/null 2>&1 || true; vgremove -ff -y rhcsa_v10_vg >/dev/null 2>&1 || true; dev=$(cat /tmp/exam/v10/6.4/device 2>/dev/null); [[ -n "$dev" ]] && losetup -d "$dev" >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/6.4 /mnt/rhcsa-v10-lv
}
