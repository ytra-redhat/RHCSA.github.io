#!/bin/bash
# RHCSA v10 objective 4.9: Start, stop, and check the status of network services
# Difficulty: 3/5

IS_LAB=true
LAB_ID="v10_4_9_manage_a_network_service_d3"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="3"
OBJECTIVE_TAG="Manage a network service - practice level 3"
OBJECTIVE_IDS="4.9"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Manage a network service - practice level 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Enable and start sshd."
TASK_1_HINT="The service must be active now and enabled for boot."
TASK_1_COMMAND_1="systemctl enable --now sshd"

TASK_2_QUESTION="Write the full sshd service status to /tmp/exam/v10/4.9/status."
TASK_2_HINT="Request status without a pager."
TASK_2_COMMAND_1="systemctl --no-pager --full status sshd > /tmp/exam/v10/4.9/status"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/4.9; mkdir -p /tmp/exam/v10/4.9; systemctl is-enabled sshd > /tmp/exam/v10/4.9/enabled 2>/dev/null || true; systemctl is-active sshd > /tmp/exam/v10/4.9/active 2>/dev/null || true
}

_check_task_1_live() {
  systemctl is-active --quiet sshd && systemctl is-enabled --quiet sshd
}

_check_task_2_live() {
  grep -q "Active: active" /tmp/exam/v10/4.9/status
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
  [[ "$(cat /tmp/exam/v10/4.9/enabled 2>/dev/null)" == enabled ]] || systemctl disable sshd >/dev/null 2>&1 || true; [[ "$(cat /tmp/exam/v10/4.9/active 2>/dev/null)" == active ]] || systemctl stop sshd >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/4.9
}
