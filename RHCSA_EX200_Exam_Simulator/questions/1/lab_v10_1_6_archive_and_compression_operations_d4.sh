#!/bin/bash
# RHCSA v10 objective 1.6: Archive, compress, unpack, and uncompress files using tar, gzip, and bzip2
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_1_6_archive_and_compression_operations_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Archive and compression operations"
OBJECTIVE_IDS="1.6"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Archive and compression operations"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create /tmp/exam/v10/1.6/etc-backup.tar.gz containing /etc/hosts and /etc/hostname."
TASK_1_HINT="Use tar with gzip compression."
TASK_1_COMMAND_1="tar -czf /tmp/exam/v10/1.6/etc-backup.tar.gz /etc/hosts /etc/hostname"

TASK_2_QUESTION="Extract that archive below /tmp/exam/v10/1.6/restore."
TASK_2_HINT="Create the destination before extracting."
TASK_2_COMMAND_1="mkdir -p /tmp/exam/v10/1.6/restore && tar -xzf /tmp/exam/v10/1.6/etc-backup.tar.gz -C /tmp/exam/v10/1.6/restore"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/1.6; mkdir -p /tmp/exam/v10/1.6
}

_check_task_1_live() {
  tar -tzf /tmp/exam/v10/1.6/etc-backup.tar.gz | grep -q "etc/hosts" && tar -tzf /tmp/exam/v10/1.6/etc-backup.tar.gz | grep -q "etc/hostname"
}

_check_task_2_live() {
  [[ -f /tmp/exam/v10/1.6/restore/etc/hosts && -f /tmp/exam/v10/1.6/restore/etc/hostname ]]
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
  rm -rf /tmp/exam/v10/1.6
}
