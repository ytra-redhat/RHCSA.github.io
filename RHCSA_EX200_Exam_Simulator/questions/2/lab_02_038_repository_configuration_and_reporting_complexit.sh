#!/bin/bash
# Chapter 2: Manage software
# Objective: RPM packages
# Difficulty: 5/5

IS_LAB=true
LAB_ID="ch02_038_repository_configuration_and_reporting_complexit"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="5"
OBJECTIVE_TAG="RPM packages"
QUESTION="Repository configuration and reporting - complexity 5"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create or overwrite /tmp/exam/ch02_38.repo with the following exact line(s): \"[lab38]\"; \"name=Lab 38\"; \"baseurl=file:///tmp/repo38\"; \"enabled=1\"; \"gpgcheck=0\"."
TASK_1_HINT="Suggested command: printf '[lab38]\\nname=Lab 38\\nbaseurl=file:///tmp/repo38\\nenabled=1\\ngpgcheck=0\\n' > /tmp/exam/ch02_38.repo. Explanation: > overwrites the destination with standard output. printf writes deterministic text, including the requested line breaks."
TASK_1_COMMAND_1="printf '[lab38]\\nname=Lab 38\\nbaseurl=file:///tmp/repo38\\nenabled=1\\ngpgcheck=0\\n' > /tmp/exam/ch02_38.repo"

TASK_2_QUESTION="Run dnf repolist enabled and write both standard output and standard error to /tmp/exam/ch02_38_repos.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_2_HINT="Suggested command: dnf repolist enabled > /tmp/exam/ch02_38_repos.txt 2>&1. Explanation: 2>&1 merges standard error into the standard-output stream before it is written. > overwrites the destination with standard output."
TASK_2_COMMAND_1="dnf repolist enabled > /tmp/exam/ch02_38_repos.txt 2>&1"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch02_38* /tmp/rhcsa_2_38 /var/tmp/rhcsa_2_38.img
}

_check_task_1_live() {
  grep -Fxq "enabled=1" /tmp/exam/ch02_38.repo && grep -Fxq "gpgcheck=0" /tmp/exam/ch02_38.repo
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch02_38_repos.txt ]]
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
  rm -rf /tmp/exam/ch02_38* /tmp/rhcsa_2_38 /var/tmp/rhcsa_2_38.img
}
