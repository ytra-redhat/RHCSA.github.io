#!/bin/bash
# Chapter 2: Manage software
# Objective: DNF queries
# Difficulty: 5/5

IS_LAB=true
LAB_ID="ch02_045_flatpak_repositories_and_applications_complexity"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="5"
OBJECTIVE_TAG="DNF queries"
QUESTION="Flatpak repositories and applications - complexity 5"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Run flatpak remotes --columns=name,url and write both standard output and standard error to /tmp/exam/ch02_45_remotes.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_1_HINT="Suggested command: flatpak remotes --columns=name,url > /tmp/exam/ch02_45_remotes.txt 2>&1. Explanation: 2>&1 merges standard error into the standard-output stream before it is written. > overwrites the destination with standard output."
TASK_1_COMMAND_1="flatpak remotes --columns=name,url > /tmp/exam/ch02_45_remotes.txt 2>&1"

TASK_2_QUESTION="Run flatpak list --app and write both standard output and standard error to /tmp/exam/ch02_45_apps.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_2_HINT="Suggested command: flatpak list --app > /tmp/exam/ch02_45_apps.txt 2>&1. Explanation: 2>&1 merges standard error into the standard-output stream before it is written. > overwrites the destination with standard output."
TASK_2_COMMAND_1="flatpak list --app > /tmp/exam/ch02_45_apps.txt 2>&1"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch02_45* /tmp/rhcsa_2_45 /var/tmp/rhcsa_2_45.img
}

_check_task_1_live() {
  [[ -f /tmp/exam/ch02_45_remotes.txt ]]
}

_check_task_2_live() {
  [[ -f /tmp/exam/ch02_45_apps.txt ]]
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
  rm -rf /tmp/exam/ch02_45* /tmp/rhcsa_2_45 /var/tmp/rhcsa_2_45.img
}
