#!/bin/bash
# RHCSA v10 objective 8.1: Configure IPv4 and IPv6 addresses
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_8_1_configure_ipv4_and_ipv6_addressing_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Configure IPv4 and IPv6 addressing"
OBJECTIVE_IDS="8.1"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Configure IPv4 and IPv6 addressing"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create NetworkManager dummy connection rhcsa-v10-net on interface rhcsa-v10-dummy with IPv4 192.0.2.10/24 and IPv6 2001:db8::10/64."
TASK_1_HINT="Use manual addressing and disable automatic default routes."
TASK_1_COMMAND_1="nmcli con add type dummy ifname rhcsa-v10-dummy con-name rhcsa-v10-net ipv4.method manual ipv4.addresses 192.0.2.10/24 ipv4.never-default yes ipv6.method manual ipv6.addresses 2001:db8::10/64 ipv6.never-default yes"

TASK_2_QUESTION="Activate rhcsa-v10-net."
TASK_2_HINT="Verify the connection, not only the device existence."
TASK_2_COMMAND_1="nmcli con up rhcsa-v10-net"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  nmcli con delete rhcsa-v10-net >/dev/null 2>&1 || true
}

_check_task_1_live() {
  nmcli -g ipv4.addresses,ipv6.addresses con show rhcsa-v10-net | grep -q "192.0.2.10/24" && nmcli -g ipv6.addresses con show rhcsa-v10-net | grep -q "2001:db8::10/64"
}

_check_task_2_live() {
  nmcli -g GENERAL.STATE con show rhcsa-v10-net | grep -q activated
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
  nmcli con delete rhcsa-v10-net >/dev/null 2>&1 || true
}
