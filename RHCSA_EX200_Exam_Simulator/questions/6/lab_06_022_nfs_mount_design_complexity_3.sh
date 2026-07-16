#!/bin/bash
# Chapter 6: Create and configure file systems
# Objective: autofs
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch06_022_nfs_mount_design_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="autofs"
QUESTION="NFS mount design - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create or overwrite /tmp/exam/ch06_22_nfs.txt with the following exact line(s): \"server:/share /mnt/share22 nfs defaults,_netdev 0 0\"."
TASK_1_HINT="Suggested command: printf 'server:/share /mnt/share22 nfs defaults,_netdev 0 0\\n' > /tmp/exam/ch06_22_nfs.txt. Explanation: > overwrites the destination with standard output. printf writes deterministic text, including the requested line breaks."
TASK_1_COMMAND_1="printf 'server:/share /mnt/share22 nfs defaults,_netdev 0 0\\n' > /tmp/exam/ch06_22_nfs.txt"

TASK_2_QUESTION="Create directory /tmp/rhcsa_22, including missing parent directories, and set its numeric mode to exactly 755."
TASK_2_HINT="Suggested command: install -d -m 755 /tmp/rhcsa_22. Explanation: install -d creates directories while -m applies the requested mode atomically."
TASK_2_COMMAND_1="install -d -m 755 /tmp/rhcsa_22"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch06_22* /tmp/rhcsa_6_22 /var/tmp/rhcsa_6_22.img
}

_check_task_1_live() {
  [[ -s /tmp/exam/ch06_22_nfs.txt ]]
}

_check_task_2_live() {
  [[ "$(stat -c %a /tmp/rhcsa_22)" = 755 ]]
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
  rm -rf /tmp/exam/ch06_22* /tmp/rhcsa_6_22 /var/tmp/rhcsa_6_22.img
}
