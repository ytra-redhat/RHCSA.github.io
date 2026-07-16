#!/bin/bash
# RHCSA v10 objective 6.3: Configure autofs
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_6_3_configure_autofs_for_nfs_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Configure autofs for NFS"
OBJECTIVE_IDS="6.3"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Configure autofs for NFS"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Configure autofs so /net/rhcsa/data mounts 127.0.0.1:/srv/rhcsa-v10-auto."
TASK_1_HINT="Create a direct or indirect master entry and map."
TASK_1_COMMAND_1="printf \"/net/rhcsa /etc/auto.rhcsa-v10\\n\" > /etc/auto.master.d/rhcsa-v10.autofs; printf \"data -fstype=nfs4 127.0.0.1:/srv/rhcsa-v10-auto\\n\" > /etc/auto.rhcsa-v10"

TASK_2_QUESTION="Enable and start autofs, then read /net/rhcsa/data/probe."
TASK_2_HINT="Accessing the path should trigger the mount."
TASK_2_COMMAND_1="systemctl enable --now autofs; cat /net/rhcsa/data/probe"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /srv/rhcsa-v10-auto /etc/auto.master.d; printf autofs > /srv/rhcsa-v10-auto/probe; printf "/srv/rhcsa-v10-auto 127.0.0.1(rw,sync,no_root_squash)\n" > /etc/exports.d/rhcsa-v10-auto.exports; systemctl enable --now nfs-server >/dev/null; exportfs -ra; rm -f /etc/auto.master.d/rhcsa-v10.autofs /etc/auto.rhcsa-v10
}

_check_task_1_live() {
  grep -Fxq "/net/rhcsa /etc/auto.rhcsa-v10" /etc/auto.master.d/rhcsa-v10.autofs && grep -q "127.0.0.1:/srv/rhcsa-v10-auto" /etc/auto.rhcsa-v10
}

_check_task_2_live() {
  systemctl is-enabled --quiet autofs && [[ "$(cat /net/rhcsa/data/probe)" == autofs ]]
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
  systemctl stop autofs >/dev/null 2>&1 || true; rm -f /etc/auto.master.d/rhcsa-v10.autofs /etc/auto.rhcsa-v10 /etc/exports.d/rhcsa-v10-auto.exports; exportfs -ra >/dev/null 2>&1 || true; rm -rf /srv/rhcsa-v10-auto
}
