#!/bin/bash
# Chapter 6: Create and configure file systems
# Objective: XFS
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch06_019_permission_diagnosis_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="XFS"
OBJECTIVE_IDS="6.1,6.5"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Permission diagnosis - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create the regular file /tmp/exam/ch06_19_file and set its numeric mode to exactly 600."
TASK_1_HINT="Review the install manual page and verify the requested final state."
TASK_1_COMMAND_1="install -m 600 /dev/null /tmp/exam/ch06_19_file"

TASK_2_QUESTION="Write the standard output of \`stat -c '%U %G %a' /tmp/exam/ch06_19_file\` to /tmp/exam/ch06_19_stat.txt."
TASK_2_HINT="Use standard-output redirection to the requested path."
TASK_2_COMMAND_1="stat -c '%U %G %a' /tmp/exam/ch06_19_file > /tmp/exam/ch06_19_stat.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch06_19* /tmp/rhcsa_6_19 /var/tmp/rhcsa_6_19.img
}

_check_task_1_live() {
  [[ "$(stat -c %a /tmp/exam/ch06_19_file)" = 600 ]]
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch06_19_stat.txt ]]
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
  rm -rf /tmp/exam/ch06_19* /tmp/rhcsa_6_19 /var/tmp/rhcsa_6_19.img
}
