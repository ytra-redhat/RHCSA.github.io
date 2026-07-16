#!/bin/bash
# Chapter 5: Configure local storage
# Objective: GPT partitions
# Difficulty: 4/5

IS_LAB=true
LAB_ID="ch05_029_persistent_mount_planning_complexity_4"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="4"
OBJECTIVE_TAG="GPT partitions"
OBJECTIVE_IDS="5.1,5.5"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Persistent mount planning - complexity 4"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create or overwrite /tmp/exam/ch05_29_fstab.txt with the following exact line(s): \"UUID=REPLACE-ME /data29 xfs defaults 0 0\"."
TASK_1_HINT="Review the printf manual page and verify the requested final state."
TASK_1_COMMAND_1="printf 'UUID=REPLACE-ME /data29 xfs defaults 0 0\\n' > /tmp/exam/ch05_29_fstab.txt"

TASK_2_QUESTION="Create directory /tmp/rhcsa_29, including missing parent directories, and set its numeric mode to exactly 755."
TASK_2_HINT="Review the install manual page and verify the requested final state."
TASK_2_COMMAND_1="install -d -m 755 /tmp/rhcsa_29"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch05_29* /tmp/rhcsa_5_29 /var/tmp/rhcsa_5_29.img
}

_check_task_1_live() {
  grep -Fxq "UUID=REPLACE-ME /data29 xfs defaults 0 0" /tmp/exam/ch05_29_fstab.txt
}

_check_task_2_live() {
  [[ "$(stat -c %a /tmp/rhcsa_29)" = 755 ]]
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
  rm -rf /tmp/exam/ch05_29* /tmp/rhcsa_5_29 /var/tmp/rhcsa_5_29.img
}
