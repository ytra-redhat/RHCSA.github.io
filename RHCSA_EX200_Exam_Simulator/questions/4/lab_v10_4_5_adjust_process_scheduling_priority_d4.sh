#!/bin/bash
# RHCSA v10 objective 4.5: Adjust process scheduling
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_4_5_adjust_process_scheduling_priority_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Adjust process scheduling priority"
OBJECTIVE_IDS="4.5"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Adjust process scheduling priority"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Set the process in /tmp/exam/v10/4.5/pid to nice value 10."
TASK_1_HINT="Change the priority of the existing process."
TASK_1_COMMAND_1="renice 10 -p \"\$(cat /tmp/exam/v10/4.5/pid)\""

TASK_2_QUESTION="Write its PID, nice value, and command to /tmp/exam/v10/4.5/report."
TASK_2_HINT="Select only the requested process columns."
TASK_2_COMMAND_1="ps -p \"\$(cat /tmp/exam/v10/4.5/pid)\" -o pid=,ni=,comm= > /tmp/exam/v10/4.5/report"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/4.5; mkdir -p /tmp/exam/v10/4.5; sleep 600 & echo $! > /tmp/exam/v10/4.5/pid
}

_check_task_1_live() {
  [[ "$(ps -o ni= -p "$(cat /tmp/exam/v10/4.5/pid)" | tr -d " ")" == 10 ]]
}

_check_task_2_live() {
  grep -Eq "[[:space:]]10[[:space:]]+sleep" /tmp/exam/v10/4.5/report
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
  [[ -f /tmp/exam/v10/4.5/pid ]] && kill "$(cat /tmp/exam/v10/4.5/pid)" >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/4.5
}
