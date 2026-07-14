#!/bin/bash
# Chapter 5: Configure local storage
# Objective: volume groups
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch05_024_persistent_mount_planning_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="volume groups"
QUESTION="Persistent mount planning - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create an fstab proposal in /tmp/exam/ch05_24_fstab.txt"
TASK_1_HINT="Write UUID=REPLACE-ME /data24 xfs defaults 0 0"
TASK_1_COMMAND_1="printf 'UUID=REPLACE-ME /data24 xfs defaults 0 0\\n' > /tmp/exam/ch05_24_fstab.txt"

TASK_2_QUESTION="Create mountpoint /tmp/rhcsa_24 with mode 755"
TASK_2_HINT="Use install -d -m 755"
TASK_2_COMMAND_1="install -d -m 755 /tmp/rhcsa_24"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch05_24* /tmp/rhcsa_5_24 /var/tmp/rhcsa_5_24.img
}

_check_task_1_live() {
  grep -Fxq "UUID=REPLACE-ME /data24 xfs defaults 0 0" /tmp/exam/ch05_24_fstab.txt
}

_check_task_2_live() {
  [[ "$(stat -c %a /tmp/rhcsa_24)" = 755 ]]
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
  rm -rf /tmp/exam/ch05_24* /tmp/rhcsa_5_24 /var/tmp/rhcsa_5_24.img
}
