#!/bin/bash
# RHCSA v10 objective 8.4: Restrict network access using firewalld and firewall-cmd
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_8_4_restrict_access_with_firewalld_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Restrict access with firewalld"
OBJECTIVE_IDS="8.4"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Restrict access with firewalld"
LAB_TASK_COUNT=2

TASK_1_QUESTION="In the public zone, permanently allow SSH only from 192.0.2.0/24 using a rich rule."
TASK_1_HINT="Specify the source network and service in one rule."
TASK_1_COMMAND_1="firewall-cmd --permanent --zone=public --add-rich-rule=\"rule family=ipv4 source address=192.0.2.0/24 service name=ssh accept\""

TASK_2_QUESTION="Reload firewalld and verify the same rule at runtime."
TASK_2_HINT="Permanent changes require a reload before appearing at runtime."
TASK_2_COMMAND_1="firewall-cmd --reload"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  systemctl start firewalld; firewall-cmd --permanent --zone=public --remove-rich-rule="rule family=ipv4 source address=192.0.2.0/24 service name=ssh accept" >/dev/null 2>&1 || true; firewall-cmd --reload >/dev/null 2>&1 || true
}

_check_task_1_live() {
  firewall-cmd --permanent --zone=public --list-rich-rules | grep -q "source address=192.0.2.0/24.*service name=ssh.*accept"
}

_check_task_2_live() {
  firewall-cmd --zone=public --list-rich-rules | grep -q "source address=192.0.2.0/24.*service name=ssh.*accept"
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
  firewall-cmd --permanent --zone=public --remove-rich-rule="rule family=ipv4 source address=192.0.2.0/24 service name=ssh accept" >/dev/null 2>&1 || true; firewall-cmd --reload >/dev/null 2>&1 || true
}
