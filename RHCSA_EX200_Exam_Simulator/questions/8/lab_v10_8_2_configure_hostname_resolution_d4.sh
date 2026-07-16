#!/bin/bash
# RHCSA v10 objective 8.2: Configure hostname resolution
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_8_2_configure_hostname_resolution_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Configure hostname resolution"
OBJECTIVE_IDS="8.2"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Configure hostname resolution"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Set the static hostname to rhcsa-v10.example.test."
TASK_1_HINT="Use the system hostname interface."
TASK_1_COMMAND_1="hostnamectl set-hostname rhcsa-v10.example.test"

TASK_2_QUESTION="Add 192.0.2.20 server-v10.example.test server-v10 to /etc/hosts."
TASK_2_HINT="Keep the canonical name before the alias."
TASK_2_COMMAND_1="printf \"192.0.2.20 server-v10.example.test server-v10\\n\" >> /etc/hosts"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/8.2; mkdir -p /tmp/exam/v10/8.2; hostnamectl --static > /tmp/exam/v10/8.2/original; sed -i "/server-v10.example.test/d" /etc/hosts
}

_check_task_1_live() {
  [[ "$(hostnamectl --static)" == rhcsa-v10.example.test ]]
}

_check_task_2_live() {
  getent hosts server-v10 | grep -q "192.0.2.20"
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
  hostnamectl set-hostname "$(cat /tmp/exam/v10/8.2/original)" >/dev/null 2>&1 || true; sed -i "/server-v10.example.test/d" /etc/hosts; rm -rf /tmp/exam/v10/8.2
}
