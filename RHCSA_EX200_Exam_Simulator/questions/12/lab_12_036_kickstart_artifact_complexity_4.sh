#!/bin/bash
# Chapter 12: Bonus RHEL 9 installation and legacy administration
# Objective: Kickstart
# Difficulty: 4/5

IS_LAB=true
LAB_ID="ch12_036_kickstart_artifact_complexity_4"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Kickstart"
OBJECTIVE_IDS="12.0"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Kickstart artifact - complexity 4"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create or overwrite /tmp/exam/ch12_36.ks with the following exact line(s): \"text\"; \"reboot\"."
TASK_1_HINT="Review the printf manual page and verify the requested final state."
TASK_1_COMMAND_1="printf 'text\\nreboot\\n' > /tmp/exam/ch12_36.ks"

TASK_2_QUESTION="Append the standard output of \`printf 'rootpw --lock\\ntimezone UTC\\n'\` to /tmp/exam/ch12_36.ks."
TASK_2_HINT="Review the printf manual page and verify the requested final state."
TASK_2_COMMAND_1="printf 'rootpw --lock\\ntimezone UTC\\n' >> /tmp/exam/ch12_36.ks"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch12_36* /tmp/rhcsa_12_36 /var/tmp/rhcsa_12_36.img
}

_check_task_1_live() {
  grep -Fxq reboot /tmp/exam/ch12_36.ks
}

_check_task_2_live() {
  grep -Fxq "timezone UTC" /tmp/exam/ch12_36.ks
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
  rm -rf /tmp/exam/ch12_36* /tmp/rhcsa_12_36 /var/tmp/rhcsa_12_36.img
}
