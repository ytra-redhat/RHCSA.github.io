#!/bin/bash
# Chapter 2: Manage software
# Objective: DNF queries
# Difficulty: 4/5

IS_LAB=true
LAB_ID="ch02_033_repository_configuration_and_reporting_complexit"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="4"
OBJECTIVE_TAG="DNF queries"
QUESTION="Repository configuration and reporting - complexity 4"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create a repository definition in /tmp/exam/ch02_33.repo"
TASK_1_HINT="Create a repo with id lab33, file baseurl, enabled=1 and gpgcheck=0"
TASK_1_COMMAND_1="printf '[lab33]\\nname=Lab 33\\nbaseurl=file:///tmp/repo33\\nenabled=1\\ngpgcheck=0\\n' > /tmp/exam/ch02_33.repo"

TASK_2_QUESTION="Save enabled repositories in /tmp/exam/ch02_33_repos.txt"
TASK_2_HINT="Use dnf repolist enabled"
TASK_2_COMMAND_1="dnf repolist enabled > /tmp/exam/ch02_33_repos.txt 2>&1"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch02_33* /tmp/rhcsa_2_33 /var/tmp/rhcsa_2_33.img
}

_check_task_1_live() {
  grep -Fxq "enabled=1" /tmp/exam/ch02_33.repo && grep -Fxq "gpgcheck=0" /tmp/exam/ch02_33.repo
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch02_33_repos.txt ]]
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
  rm -rf /tmp/exam/ch02_33* /tmp/rhcsa_2_33 /var/tmp/rhcsa_2_33.img
}
