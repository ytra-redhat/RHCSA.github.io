#!/bin/bash
# Chapter 5: Configure local storage
# Objective: physical volumes
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch05_009_persistent_mount_planning_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="physical volumes"
QUESTION="Persistent mount planning - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create or overwrite /tmp/exam/ch05_09_fstab.txt with the following exact line(s): \"UUID=REPLACE-ME /data09 xfs defaults 0 0\"."
TASK_1_HINT="Suggested command: printf 'UUID=REPLACE-ME /data09 xfs defaults 0 0\\n' > /tmp/exam/ch05_09_fstab.txt. Explanation: > overwrites the destination with standard output. printf writes deterministic text, including the requested line breaks."
TASK_1_COMMAND_1="printf 'UUID=REPLACE-ME /data09 xfs defaults 0 0\\n' > /tmp/exam/ch05_09_fstab.txt"

TASK_2_QUESTION="Create directory /tmp/rhcsa_09, including missing parent directories, and set its numeric mode to exactly 755."
TASK_2_HINT="Suggested command: install -d -m 755 /tmp/rhcsa_09. Explanation: install -d creates directories while -m applies the requested mode atomically."
TASK_2_COMMAND_1="install -d -m 755 /tmp/rhcsa_09"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch05_09* /tmp/rhcsa_5_09 /var/tmp/rhcsa_5_09.img
}

_check_task_1_live() {
  grep -Fxq "UUID=REPLACE-ME /data09 xfs defaults 0 0" /tmp/exam/ch05_09_fstab.txt
}

_check_task_2_live() {
  [[ "$(stat -c %a /tmp/rhcsa_09)" = 755 ]]
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
  rm -rf /tmp/exam/ch05_09* /tmp/rhcsa_5_09 /var/tmp/rhcsa_5_09.img
}
