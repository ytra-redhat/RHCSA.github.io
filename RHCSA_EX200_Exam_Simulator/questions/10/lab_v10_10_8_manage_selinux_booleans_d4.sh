#!/bin/bash
# RHCSA v10 objective 10.8: Use booleans to modify SELinux settings
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_10_8_manage_selinux_booleans_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Manage SELinux booleans"
OBJECTIVE_IDS="10.8"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Manage SELinux booleans"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Enable httpd_can_network_connect persistently."
TASK_1_HINT="Use the persistent boolean option."
TASK_1_COMMAND_1="setsebool -P httpd_can_network_connect on"

TASK_2_QUESTION="Write all non-default SELinux booleans to /tmp/exam/v10/10.8/modified."
TASK_2_HINT="Query modified boolean policy values."
TASK_2_COMMAND_1="semanage boolean -l -C > /tmp/exam/v10/10.8/modified"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/10.8; mkdir -p /tmp/exam/v10/10.8; getsebool httpd_can_network_connect | awk "{print \$3}" > /tmp/exam/v10/10.8/original
}

_check_task_1_live() {
  [[ "$(getsebool httpd_can_network_connect | awk "{print \$3}")" == on ]]
}

_check_task_2_live() {
  grep -q httpd_can_network_connect /tmp/exam/v10/10.8/modified
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
  orig=$(cat /tmp/exam/v10/10.8/original 2>/dev/null || echo off); setsebool -P httpd_can_network_connect "$orig" >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/10.8
}
