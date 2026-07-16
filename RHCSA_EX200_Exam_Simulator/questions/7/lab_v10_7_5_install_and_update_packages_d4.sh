#!/bin/bash
# RHCSA v10 objective 7.5: Install and update packages from CDN, remote repositories, or local files
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_7_5_install_and_update_packages_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Install and update packages"
OBJECTIVE_IDS="7.5"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Install and update packages"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Install the zip package with DNF."
TASK_1_HINT="Use configured repositories and verify the RPM database."
TASK_1_COMMAND_1="dnf -y install zip"

TASK_2_QUESTION="Write available updates for installed packages to /tmp/exam/v10/7.5/updates without applying them."
TASK_2_HINT="Use the DNF update check and retain its output even when updates are available."
TASK_2_COMMAND_1="dnf check-update > /tmp/exam/v10/7.5/updates 2>&1 || [[ \$? -eq 100 ]]"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/7.5; mkdir -p /tmp/exam/v10/7.5; if rpm -q zip >/dev/null 2>&1; then echo present > /tmp/exam/v10/7.5/initial; else echo absent > /tmp/exam/v10/7.5/initial; fi
}

_check_task_1_live() {
  rpm -q zip >/dev/null 2>&1
}

_check_task_2_live() {
  [[ -f /tmp/exam/v10/7.5/updates ]]
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
  [[ "$(cat /tmp/exam/v10/7.5/initial 2>/dev/null)" == present ]] || dnf -y remove zip >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/7.5
}
