#!/bin/bash
# Chapter 6: Create and configure file systems
# Objective: ext4
# Difficulty: 4/5

IS_LAB=true
LAB_ID="ch06_034_permission_diagnosis_complexity_4"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="4"
OBJECTIVE_TAG="ext4"
QUESTION="Permission diagnosis - complexity 4"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create the regular file /tmp/exam/ch06_34_file and set its numeric mode to exactly 600. The file may be empty."
TASK_1_HINT="Suggested command: install -m 600 /dev/null /tmp/exam/ch06_34_file. Explanation: install creates the file and applies the requested mode in one operation."
TASK_1_COMMAND_1="install -m 600 /dev/null /tmp/exam/ch06_34_file"

TASK_2_QUESTION="Use stat to write the owner, group and numeric permission mode of /tmp/exam/ch06_34_file to /tmp/exam/ch06_34_stat.txt, in that order. The output file must contain all three values."
TASK_2_HINT="Suggested command: stat -c '%U %G %a' /tmp/exam/ch06_34_file > /tmp/exam/ch06_34_stat.txt. Explanation: > overwrites the destination with standard output."
TASK_2_COMMAND_1="stat -c '%U %G %a' /tmp/exam/ch06_34_file > /tmp/exam/ch06_34_stat.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch06_34* /tmp/rhcsa_6_34 /var/tmp/rhcsa_6_34.img
}

_check_task_1_live() {
  [[ "$(stat -c %a /tmp/exam/ch06_34_file)" = 600 ]]
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch06_34_stat.txt ]]
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
  rm -rf /tmp/exam/ch06_34* /tmp/rhcsa_6_34 /var/tmp/rhcsa_6_34.img
}
