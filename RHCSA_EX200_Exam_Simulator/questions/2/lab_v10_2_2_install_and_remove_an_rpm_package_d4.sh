#!/bin/bash
# RHCSA v10 objective 2.2: Install and remove RPM software packages
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_2_2_install_and_remove_an_rpm_package_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Install and remove an RPM package"
OBJECTIVE_IDS="2.2"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Install and remove an RPM package"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Install the bc package with DNF."
TASK_1_HINT="Verify the package in the RPM database after installation."
TASK_1_COMMAND_1="dnf -y install bc"

TASK_2_QUESTION="Remove the bc package with DNF."
TASK_2_HINT="Complete task 1 before removing it."
TASK_2_COMMAND_1="dnf -y remove bc"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam/v10/2.2; if rpm -q bc >/dev/null 2>&1; then echo present > /tmp/exam/v10/2.2/initial; else echo absent > /tmp/exam/v10/2.2/initial; fi; [[ "$(cat /tmp/exam/v10/2.2/initial)" == absent ]] || dnf -y remove bc >/dev/null 2>&1 || true
}

_check_task_1_live() {
  rpm -q bc >/dev/null 2>&1
}

_check_task_2_live() {
  ! rpm -q bc >/dev/null 2>&1
}

check_tasks() {
  TASK_STATUS[0]="false"
  if _is_done 1; then
    TASK_STATUS[0]="true"
  elif _check_task_1_live; then
    TASK_STATUS[0]="true"
    _mark_done 1
  fi
  TASK_STATUS[1]="false"
  if _is_done 2; then
    TASK_STATUS[1]="true"
  elif _check_task_2_live; then
    TASK_STATUS[1]="true"
    _mark_done 2
  fi
}

cleanup_lab() {
  if [[ -f /tmp/exam/v10/2.2/initial && "$(cat /tmp/exam/v10/2.2/initial)" == present ]]; then dnf -y install bc >/dev/null 2>&1 || true; else dnf -y remove bc >/dev/null 2>&1 || true; fi; rm -rf /tmp/exam/v10/2.2
}
