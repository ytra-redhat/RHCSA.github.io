#!/bin/bash
# RHCSA v10 objective 4.4: Identify CPU/memory intensive processes and kill processes
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_4_4_identify_and_terminate_a_resource_intensive_proc_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Identify and terminate a resource-intensive process"
OBJECTIVE_IDS="4.4"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Identify and terminate a resource-intensive process"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Identify the PID stored in /tmp/exam/v10/4.4/pid and write its command name to /tmp/exam/v10/4.4/name."
TASK_1_HINT="Query the specific process rather than the whole process list."
TASK_1_COMMAND_1="ps -p \"\$(cat /tmp/exam/v10/4.4/pid)\" -o comm= > /tmp/exam/v10/4.4/name"

TASK_2_QUESTION="Terminate that process."
TASK_2_HINT="Send a normal termination signal first."
TASK_2_COMMAND_1="kill \"\$(cat /tmp/exam/v10/4.4/pid)\""

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/4.4; mkdir -p /tmp/exam/v10/4.4; yes > /dev/null & echo $! > /tmp/exam/v10/4.4/pid
}

_check_task_1_live() {
  grep -Eq "^(yes|bash)$" /tmp/exam/v10/4.4/name
}

_check_task_2_live() {
  ! kill -0 "$(cat /tmp/exam/v10/4.4/pid)" 2>/dev/null
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
  [[ -f /tmp/exam/v10/4.4/pid ]] && kill "$(cat /tmp/exam/v10/4.4/pid)" >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/4.4
}
