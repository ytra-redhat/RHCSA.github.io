#!/bin/bash
# RHCSA v10 objective 7.4: Configure time service clients
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_7_4_configure_a_time_service_client_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Configure a time-service client"
OBJECTIVE_IDS="7.4"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Configure a time-service client"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Add server time.example.test with iburst to /etc/chrony.d/rhcsa-v10.conf."
TASK_1_HINT="Use a chrony drop-in rather than editing the vendor file."
TASK_1_COMMAND_1="printf \"server time.example.test iburst\\n\" > /etc/chrony.d/rhcsa-v10.conf"

TASK_2_QUESTION="Enable and restart chronyd, then write its sources to /tmp/exam/v10/7.4/sources."
TASK_2_HINT="Verify the service state even if the test name cannot resolve."
TASK_2_COMMAND_1="systemctl enable --now chronyd; chronyc sources > /tmp/exam/v10/7.4/sources 2>&1 || true"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/7.4; mkdir -p /tmp/exam/v10/7.4; rm -f /etc/chrony.d/rhcsa-v10.conf
}

_check_task_1_live() {
  grep -Fxq "server time.example.test iburst" /etc/chrony.d/rhcsa-v10.conf
}

_check_task_2_live() {
  systemctl is-enabled --quiet chronyd && systemctl is-active --quiet chronyd && [[ -f /tmp/exam/v10/7.4/sources ]]
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
  rm -f /etc/chrony.d/rhcsa-v10.conf; systemctl restart chronyd >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/7.4
}
