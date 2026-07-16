#!/bin/bash
# Chapter 7: Deploy configure and maintain systems
# Objective: cron
# Difficulty: 4/5

IS_LAB=true
LAB_ID="ch07_034_bootloader_and_target_complexity_4"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="4"
OBJECTIVE_TAG="cron"
OBJECTIVE_IDS="7.1,7.3,7.6"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Bootloader and target - complexity 4"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Write the standard output of \`systemctl get-default\` to /tmp/exam/ch07_34_target.txt."
TASK_1_HINT="Review the systemctl manual page and verify the requested final state."
TASK_1_COMMAND_1="systemctl get-default > /tmp/exam/ch07_34_target.txt"

TASK_2_QUESTION="grub2-editenv list and write both standard output and standard error to /tmp/exam/ch07_34_grub.txt."
TASK_2_HINT="Review the grub2-editenv manual page and verify the requested final state."
TASK_2_COMMAND_1="grub2-editenv list > /tmp/exam/ch07_34_grub.txt 2>&1"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch07_34* /tmp/rhcsa_7_34 /var/tmp/rhcsa_7_34.img
}

_check_task_1_live() {
  grep -Eq "\.target$" /tmp/exam/ch07_34_target.txt
}

_check_task_2_live() {
  [[ -f /tmp/exam/ch07_34_grub.txt ]]
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
  rm -rf /tmp/exam/ch07_34* /tmp/rhcsa_7_34 /var/tmp/rhcsa_7_34.img
}
