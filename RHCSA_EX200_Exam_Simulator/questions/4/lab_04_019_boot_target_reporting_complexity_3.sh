#!/bin/bash
# Chapter 4: Operate running systems
# Objective: boot targets
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch04_019_boot_target_reporting_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="boot targets"
QUESTION="Boot target reporting - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Run systemctl get-default and write the complete standard output to /tmp/exam/ch04_19_target.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_1_HINT="Suggested command: systemctl get-default > /tmp/exam/ch04_19_target.txt. Explanation: > overwrites the destination with standard output. systemctl get-default reports the boot target selected as default."
TASK_1_COMMAND_1="systemctl get-default > /tmp/exam/ch04_19_target.txt"

TASK_2_QUESTION="Run systemctl list-unit-files --type=target --no-pager and write the complete standard output to /tmp/exam/ch04_19_targets.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_2_HINT="Suggested command: systemctl list-unit-files --type=target --no-pager > /tmp/exam/ch04_19_targets.txt. Explanation: > overwrites the destination with standard output. systemctl queries systemd's current unit state."
TASK_2_COMMAND_1="systemctl list-unit-files --type=target --no-pager > /tmp/exam/ch04_19_targets.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch04_19* /tmp/rhcsa_4_19 /var/tmp/rhcsa_4_19.img
}

_check_task_1_live() {
  grep -Eq "\.target$" /tmp/exam/ch04_19_target.txt
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch04_19_targets.txt ]]
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
  rm -rf /tmp/exam/ch04_19* /tmp/rhcsa_4_19 /var/tmp/rhcsa_4_19.img
}
