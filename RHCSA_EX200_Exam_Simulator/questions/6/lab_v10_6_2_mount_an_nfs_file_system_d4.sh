#!/bin/bash
# RHCSA v10 objective 6.2: Mount and unmount NFS network file systems
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_6_2_mount_an_nfs_file_system_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Mount an NFS file system"
OBJECTIVE_IDS="6.2"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Mount an NFS file system"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Mount 127.0.0.1:/srv/rhcsa-v10-nfs at /mnt/rhcsa-v10-nfs."
TASK_1_HINT="Use the NFS filesystem type and the prepared local export."
TASK_1_COMMAND_1="mkdir -p /mnt/rhcsa-v10-nfs; mount -t nfs 127.0.0.1:/srv/rhcsa-v10-nfs /mnt/rhcsa-v10-nfs"

TASK_2_QUESTION="Unmount /mnt/rhcsa-v10-nfs."
TASK_2_HINT="Verify that no mount remains."
TASK_2_COMMAND_1="umount /mnt/rhcsa-v10-nfs"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /srv/rhcsa-v10-nfs /mnt/rhcsa-v10-nfs; printf data > /srv/rhcsa-v10-nfs/data; printf "/srv/rhcsa-v10-nfs 127.0.0.1(rw,sync,no_root_squash)\n" > /etc/exports.d/rhcsa-v10.exports; systemctl enable --now nfs-server >/dev/null; exportfs -ra
}

_check_task_1_live() {
  findmnt -rn -t nfs,nfs4 /mnt/rhcsa-v10-nfs >/dev/null
}

_check_task_2_live() {
  ! findmnt -rn /mnt/rhcsa-v10-nfs >/dev/null
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
  umount /mnt/rhcsa-v10-nfs >/dev/null 2>&1 || true; rm -f /etc/exports.d/rhcsa-v10.exports; exportfs -ra >/dev/null 2>&1 || true; rm -rf /srv/rhcsa-v10-nfs /mnt/rhcsa-v10-nfs
}
