#!/bin/bash
# Chapter 12: Bonus RHEL 9 installation and legacy administration
# Objective: installation media
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch12_005_installation_planning_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="installation media"
QUESTION="Installation planning - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Save block labels in /tmp/exam/ch12_05_labels.txt"
TASK_1_HINT="Use lsblk -o NAME,LABEL,FSTYPE,SIZE"
TASK_1_COMMAND_1="lsblk -o NAME,LABEL,FSTYPE,SIZE > /tmp/exam/ch12_05_labels.txt"

TASK_2_QUESTION="Create installation checklist in /tmp/exam/ch12_05_checklist.txt"
TASK_2_HINT="Include boot media, network, storage, root password"
TASK_2_COMMAND_1="printf 'boot media\\nnetwork\\nstorage\\nroot password\\n' > /tmp/exam/ch12_05_checklist.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch12_05* /tmp/rhcsa_12_05 /var/tmp/rhcsa_12_05.img
}

_check_task_1_live() {
  [[ -s /tmp/exam/ch12_05_labels.txt ]]
}

_check_task_2_live() {
  grep -Fxq storage /tmp/exam/ch12_05_checklist.txt
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
  rm -rf /tmp/exam/ch12_05* /tmp/rhcsa_12_05 /var/tmp/rhcsa_12_05.img
}
