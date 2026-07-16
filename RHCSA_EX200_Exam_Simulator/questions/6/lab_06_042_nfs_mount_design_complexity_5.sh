#!/bin/bash
# Chapter 6: Create and configure file systems
# Objective: ext4
# Difficulty: 5/5

IS_LAB=true
LAB_ID="ch06_042_nfs_mount_design_complexity_5"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="5"
OBJECTIVE_TAG="ext4"
OBJECTIVE_IDS="6.1,6.2"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="NFS mount design - complexity 5"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create or overwrite /tmp/exam/ch06_42_nfs.txt with the following exact line(s): \"server:/share /mnt/share42 nfs defaults,_netdev 0 0\"."
TASK_1_HINT="Review the printf manual page and verify the requested final state."
TASK_1_COMMAND_1="printf 'server:/share /mnt/share42 nfs defaults,_netdev 0 0\\n' > /tmp/exam/ch06_42_nfs.txt"

TASK_2_QUESTION="Create directory /tmp/rhcsa_42, including missing parent directories, and set its numeric mode to exactly 755."
TASK_2_HINT="Review the install manual page and verify the requested final state."
TASK_2_COMMAND_1="install -d -m 755 /tmp/rhcsa_42"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch06_42* /tmp/rhcsa_6_42 /var/tmp/rhcsa_6_42.img
}

_check_task_1_live() {
  [[ -s /tmp/exam/ch06_42_nfs.txt ]]
}

_check_task_2_live() {
  [[ "$(stat -c %a /tmp/rhcsa_42)" = 755 ]]
}

check_tasks() {
  TASK_STATUS[0]="false"
  TASK_STATUS[1]="false"
  if _is_done 1; then
    TASK_STATUS[0]="true"
  elif _check_task_1_live; then
    TASK_STATUS[0]="true"
    _mark_done 1
  fi
  if _is_done 2; then
    TASK_STATUS[1]="true"
  elif _check_task_2_live; then
    TASK_STATUS[1]="true"
    _mark_done 2
  fi
}

cleanup_lab() {
  rm -rf /tmp/exam/ch06_42* /tmp/rhcsa_6_42 /var/tmp/rhcsa_6_42.img
}
