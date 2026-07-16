#!/bin/bash
# RHCSA v10 objective 10.1: Configure firewall settings using firewall-cmd and firewalld
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_10_1_configure_persistent_firewall_access_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Configure persistent firewall access"
OBJECTIVE_IDS="10.1"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Configure persistent firewall access"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Permanently allow TCP port 8443 in the public zone."
TASK_1_HINT="Apply the port and protocol to the persistent zone configuration."
TASK_1_COMMAND_1="firewall-cmd --permanent --zone=public --add-port=8443/tcp"

TASK_2_QUESTION="Reload firewalld and verify TCP port 8443 is allowed at runtime."
TASK_2_HINT="Reload after changing permanent configuration."
TASK_2_COMMAND_1="firewall-cmd --reload"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  systemctl start firewalld; firewall-cmd --permanent --zone=public --remove-port=8443/tcp >/dev/null 2>&1 || true; firewall-cmd --reload >/dev/null 2>&1 || true
}

_check_task_1_live() {
  firewall-cmd --permanent --zone=public --query-port=8443/tcp >/dev/null
}

_check_task_2_live() {
  firewall-cmd --zone=public --query-port=8443/tcp >/dev/null
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
  firewall-cmd --permanent --zone=public --remove-port=8443/tcp >/dev/null 2>&1 || true; firewall-cmd --reload >/dev/null 2>&1 || true
}
