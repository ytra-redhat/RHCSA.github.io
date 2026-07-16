#!/bin/bash
# Chapter 12: Bonus RHEL 9 installation and legacy administration
# Objective: installation media
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch12_026_kickstart_artifact_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="installation media"
QUESTION="Kickstart artifact - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create or overwrite /tmp/exam/ch12_26.ks with the following exact line(s): \"text\"; \"reboot\"."
TASK_1_HINT="Suggested command: printf 'text\\nreboot\\n' > /tmp/exam/ch12_26.ks. Explanation: > overwrites the destination with standard output. printf writes deterministic text, including the requested line breaks."
TASK_1_COMMAND_1="printf 'text\\nreboot\\n' > /tmp/exam/ch12_26.ks"

TASK_2_QUESTION="Append the following exact line(s) to /tmp/exam/ch12_26.ks without removing its existing content: \"rootpw --lock\"; \"timezone UTC\"."
TASK_2_HINT="Suggested command: printf 'rootpw --lock\\ntimezone UTC\\n' >> /tmp/exam/ch12_26.ks. Explanation: >> appends and preserves existing file content. printf writes deterministic text, including the requested line breaks."
TASK_2_COMMAND_1="printf 'rootpw --lock\\ntimezone UTC\\n' >> /tmp/exam/ch12_26.ks"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch12_26* /tmp/rhcsa_12_26 /var/tmp/rhcsa_12_26.img
}

_check_task_1_live() {
  grep -Fxq reboot /tmp/exam/ch12_26.ks
}

_check_task_2_live() {
  grep -Fxq "timezone UTC" /tmp/exam/ch12_26.ks
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
  rm -rf /tmp/exam/ch12_26* /tmp/rhcsa_12_26 /var/tmp/rhcsa_12_26.img
}
