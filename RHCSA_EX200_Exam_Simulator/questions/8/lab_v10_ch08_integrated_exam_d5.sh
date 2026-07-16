#!/bin/bash
# RHCSA v10 objective 8.1: Configure IPv4 and IPv6 addresses
# Difficulty: 5/5

IS_LAB=true
LAB_ID="v10_8_1_ch8_integrated_d5"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="5"
OBJECTIVE_TAG="Integrated RHCSA v10 chapter 8 scenario"
OBJECTIVE_IDS="8.1,8.2,8.3,8.4"
LAB_KIND="integrated-exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="mixed"
QUESTION="Integrated RHCSA v10 chapter 8 scenario"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create and activate dummy connection v10int with IPv4 198.51.100.10/24."
TASK_1_HINT="Use a persistent NetworkManager profile."
TASK_1_COMMAND_1="nmcli con add type dummy ifname v10int0 con-name v10int ipv4.method manual ipv4.addresses 198.51.100.10/24 ipv6.method disabled; nmcli con up v10int"

TASK_2_QUESTION="Permanently allow TCP 9443 in the public zone and reload firewalld."
TASK_2_HINT="Apply the change to persistent and runtime configuration."
TASK_2_COMMAND_1="firewall-cmd --permanent --zone=public --add-port=9443/tcp; firewall-cmd --reload"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  nmcli con delete v10int >/dev/null 2>&1 || true; systemctl start firewalld; firewall-cmd --permanent --zone=public --remove-port=9443/tcp >/dev/null 2>&1 || true; firewall-cmd --reload >/dev/null 2>&1 || true
}

_check_task_1_live() {
  nmcli -g GENERAL.STATE con show v10int | grep -q activated
}

_check_task_2_live() {
  firewall-cmd --zone=public --query-port=9443/tcp >/dev/null
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
  nmcli con delete v10int >/dev/null 2>&1 || true; firewall-cmd --permanent --zone=public --remove-port=9443/tcp >/dev/null 2>&1 || true; firewall-cmd --reload >/dev/null 2>&1 || true
}
