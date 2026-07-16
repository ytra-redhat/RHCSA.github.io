#!/bin/bash
# Chapter 2: Manage software
# Objective: RPM repositories
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch02_025_flatpak_repositories_and_applications_complexity"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="RPM repositories"
OBJECTIVE_IDS="2.1,2.2,2.3,2.4"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Flatpak repositories and applications - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="flatpak remotes --columns=name,url and write both standard output and standard error to /tmp/exam/ch02_25_remotes.txt."
TASK_1_HINT="Use file descriptor 2 redirection."
TASK_1_COMMAND_1="flatpak remotes --columns=name,url > /tmp/exam/ch02_25_remotes.txt 2>&1"

TASK_2_QUESTION="flatpak list --app and write both standard output and standard error to /tmp/exam/ch02_25_apps.txt."
TASK_2_HINT="Use file descriptor 2 redirection."
TASK_2_COMMAND_1="flatpak list --app > /tmp/exam/ch02_25_apps.txt 2>&1"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch02_25* /tmp/rhcsa_2_25 /var/tmp/rhcsa_2_25.img
}

_check_task_1_live() {
  [[ -f /tmp/exam/ch02_25_remotes.txt ]]
}

_check_task_2_live() {
  [[ -f /tmp/exam/ch02_25_apps.txt ]]
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
  rm -rf /tmp/exam/ch02_25* /tmp/rhcsa_2_25 /var/tmp/rhcsa_2_25.img
}
