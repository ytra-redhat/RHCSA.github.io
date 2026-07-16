#!/bin/bash
# RHCSA v10 objective 10.7: Manage SELinux port labels
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_10_7_manage_selinux_port_labels_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Manage SELinux port labels"
OBJECTIVE_IDS="10.7"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Manage SELinux port labels"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Associate TCP port 8443 with http_port_t persistently."
TASK_1_HINT="Add a port mapping only if the port is not already assigned."
TASK_1_COMMAND_1="semanage port -a -t http_port_t -p tcp 8443"

TASK_2_QUESTION="Write the http_port_t port list to /tmp/exam/v10/10.7/ports."
TASK_2_HINT="Query the SELinux port policy."
TASK_2_COMMAND_1="semanage port -l | grep \"^http_port_t\" > /tmp/exam/v10/10.7/ports"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/10.7; mkdir -p /tmp/exam/v10/10.7; semanage port -d -p tcp 8443 >/dev/null 2>&1 || true
}

_check_task_1_live() {
  semanage port -l | awk "$1=="http_port_t" && $2=="tcp" {print $0}" | grep -qw 8443
}

_check_task_2_live() {
  grep -qw 8443 /tmp/exam/v10/10.7/ports
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
  semanage port -d -p tcp 8443 >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/10.7
}
