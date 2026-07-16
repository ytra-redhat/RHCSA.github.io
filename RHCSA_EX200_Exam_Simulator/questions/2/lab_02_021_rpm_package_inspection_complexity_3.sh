#!/bin/bash
# Chapter 2: Manage software
# Objective: DNF queries
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch02_021_rpm_package_inspection_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="DNF queries"
QUESTION="RPM package inspection - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Run rpm -qi bash and write the complete standard output to /tmp/exam/ch02_21_rpm.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_1_HINT="Suggested command: rpm -qi bash > /tmp/exam/ch02_21_rpm.txt. Explanation: > overwrites the destination with standard output. rpm -qi queries installed-package metadata."
TASK_1_COMMAND_1="rpm -qi bash > /tmp/exam/ch02_21_rpm.txt"

TASK_2_QUESTION="Run rpm -ql bash and write the complete standard output to /tmp/exam/ch02_21_files.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_2_HINT="Suggested command: rpm -ql bash > /tmp/exam/ch02_21_files.txt. Explanation: > overwrites the destination with standard output. rpm -ql lists files owned by an installed package."
TASK_2_COMMAND_1="rpm -ql bash > /tmp/exam/ch02_21_files.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch02_21* /tmp/rhcsa_2_21 /var/tmp/rhcsa_2_21.img
}

_check_task_1_live() {
  grep -Eqi "^Name.*bash" /tmp/exam/ch02_21_rpm.txt
}

_check_task_2_live() {
  grep -q /bin/bash /tmp/exam/ch02_21_files.txt
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
  rm -rf /tmp/exam/ch02_21* /tmp/rhcsa_2_21 /var/tmp/rhcsa_2_21.img
}
