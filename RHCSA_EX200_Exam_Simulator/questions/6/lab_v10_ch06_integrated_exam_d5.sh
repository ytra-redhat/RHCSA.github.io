#!/bin/bash
# RHCSA v10 objective 6.1: Create, mount, unmount, and use VFAT, ext4, and XFS file systems
# Difficulty: 5/5

IS_LAB=true
LAB_ID="v10_6_1_ch6_integrated_d5"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="5"
OBJECTIVE_TAG="Integrated RHCSA v10 chapter 6 scenario"
OBJECTIVE_IDS="6.1,6.2,6.3,6.4,6.5"
LAB_KIND="integrated-exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="mixed"
QUESTION="Integrated RHCSA v10 chapter 6 scenario"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Mount the prepared NFS export 127.0.0.1:/srv/v10int at /mnt/v10int-nfs and add a persistent fstab entry."
TASK_1_HINT="Use the NFS source directly in fstab."
TASK_1_COMMAND_1="mkdir -p /mnt/v10int-nfs; printf \"127.0.0.1:/srv/v10int /mnt/v10int-nfs nfs defaults,_netdev 0 0\\n\" >> /etc/fstab; mount /mnt/v10int-nfs"

TASK_2_QUESTION="Configure autofs map /net/v10int/data for the same export."
TASK_2_HINT="Create an indirect map and restart autofs."
TASK_2_COMMAND_1="printf \"/net/v10int /etc/auto.v10int\\n\" > /etc/auto.master.d/v10int.autofs; printf \"data -fstype=nfs4 127.0.0.1:/srv/v10int\\n\" > /etc/auto.v10int; systemctl restart autofs; cat /net/v10int/data/probe"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /srv/v10int /mnt/v10int-nfs /etc/auto.master.d; printf integrated > /srv/v10int/probe; printf "/srv/v10int 127.0.0.1(rw,sync,no_root_squash)\n" > /etc/exports.d/v10int.exports; systemctl enable --now nfs-server autofs >/dev/null; exportfs -ra
}

_check_task_1_live() {
  findmnt -rn -t nfs,nfs4 /mnt/v10int-nfs >/dev/null && grep -q "^127.0.0.1:/srv/v10int /mnt/v10int-nfs nfs " /etc/fstab
}

_check_task_2_live() {
  [[ "$(cat /net/v10int/data/probe)" == integrated ]]
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
  umount /mnt/v10int-nfs >/dev/null 2>&1 || true; sed -i "\| /mnt/v10int-nfs |d" /etc/fstab; rm -f /etc/auto.master.d/v10int.autofs /etc/auto.v10int /etc/exports.d/v10int.exports; exportfs -ra >/dev/null 2>&1 || true; rm -rf /srv/v10int /mnt/v10int-nfs
}
