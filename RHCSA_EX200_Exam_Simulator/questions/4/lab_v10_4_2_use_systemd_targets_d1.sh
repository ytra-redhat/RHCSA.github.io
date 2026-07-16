#!/bin/bash
# RHCSA v10 objective 4.2: Boot systems into different targets manually
# Difficulty: 1/5

IS_LAB=true
LAB_ID="v10_4_2_use_systemd_targets_d1"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="1"
OBJECTIVE_TAG="Use systemd targets - practice level 1"
OBJECTIVE_IDS="4.2"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Use systemd targets - practice level 1"
LAB_TASK_COUNT=1

TASK_1_QUESTION="Set multi-user.target as the default boot target."
TASK_1_HINT="Change the persistent default target."
TASK_1_COMMAND_1="systemctl set-default multi-user.target"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam/v10/4.2; systemctl get-default > /tmp/exam/v10/4.2/original
}

_check_task_1_live() {
  [[ "$(systemctl get-default)" == multi-user.target ]]
}

check_tasks() {
  TASK_STATUS[0]="false"
  if _is_done 1; then
    TASK_STATUS[0]="true"
  elif _check_task_1_live; then
    TASK_STATUS[0]="true"
    _mark_done 1
  fi
}

cleanup_lab() {
  orig=$(cat /tmp/exam/v10/4.2/original 2>/dev/null || echo multi-user.target); systemctl set-default "$orig" >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/4.2
}
