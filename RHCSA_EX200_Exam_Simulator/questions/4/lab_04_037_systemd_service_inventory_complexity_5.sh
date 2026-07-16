#!/bin/bash
# Chapter 4: Operate running systems
# Objective: boot targets
# Difficulty: 5/5

IS_LAB=true
LAB_ID="ch04_037_systemd_service_inventory_complexity_5"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="5"
OBJECTIVE_TAG="boot targets"
QUESTION="Systemd service inventory - complexity 5"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Run systemctl --failed --no-pager and write the complete standard output to /tmp/exam/ch04_37_failed.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_1_HINT="Suggested command: systemctl --failed --no-pager > /tmp/exam/ch04_37_failed.txt. Explanation: > overwrites the destination with standard output. systemctl queries systemd's current unit state."
TASK_1_COMMAND_1="systemctl --failed --no-pager > /tmp/exam/ch04_37_failed.txt"

TASK_2_QUESTION="Run systemctl list-unit-files --type=service --state=enabled --no-pager and write the complete standard output to /tmp/exam/ch04_37_enabled.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_2_HINT="Suggested command: systemctl list-unit-files --type=service --state=enabled --no-pager > /tmp/exam/ch04_37_enabled.txt. Explanation: > overwrites the destination with standard output. systemctl queries systemd's current unit state."
TASK_2_COMMAND_1="systemctl list-unit-files --type=service --state=enabled --no-pager > /tmp/exam/ch04_37_enabled.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch04_37* /tmp/rhcsa_4_37 /var/tmp/rhcsa_4_37.img
}

_check_task_1_live() {
  [[ -f /tmp/exam/ch04_37_failed.txt ]]
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch04_37_enabled.txt ]]
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
  rm -rf /tmp/exam/ch04_37* /tmp/rhcsa_4_37 /var/tmp/rhcsa_4_37.img
}
