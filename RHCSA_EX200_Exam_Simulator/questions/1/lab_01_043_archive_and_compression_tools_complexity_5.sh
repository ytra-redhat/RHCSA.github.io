#!/bin/bash
# Chapter 1: Understand and use essential tools
# Objective: links
# Difficulty: 5/5

IS_LAB=true
LAB_ID="ch01_043_archive_and_compression_tools_complexity_5"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="5"
OBJECTIVE_TAG="links"
QUESTION="Archive and compression tools - complexity 5"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create archive /tmp/exam/ch01_43.tar.gz using gzip compression and include /etc/hosts."
TASK_1_HINT="Suggested command: tar -czf /tmp/exam/ch01_43.tar.gz /etc/hosts. Explanation: -c creates the archive, -z enables gzip and -f names the output file."
TASK_1_COMMAND_1="tar -czf /tmp/exam/ch01_43.tar.gz /etc/hosts"

TASK_2_QUESTION="Create archive /tmp/exam/ch01_43.tar.bz2 using bzip2 compression and include /etc/services."
TASK_2_HINT="Suggested command: tar -cjf /tmp/exam/ch01_43.tar.bz2 /etc/services. Explanation: -c creates the archive, -j enables bzip2 and -f names the output file."
TASK_2_COMMAND_1="tar -cjf /tmp/exam/ch01_43.tar.bz2 /etc/services"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch01_43* /tmp/rhcsa_1_43 /var/tmp/rhcsa_1_43.img
}

_check_task_1_live() {
  tar -tzf /tmp/exam/ch01_43.tar.gz | grep -q etc/hosts
}

_check_task_2_live() {
  tar -tjf /tmp/exam/ch01_43.tar.bz2 | grep -q etc/services
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
  rm -rf /tmp/exam/ch01_43* /tmp/rhcsa_1_43 /var/tmp/rhcsa_1_43.img
}
