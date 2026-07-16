#!/bin/bash
# RHCSA v10 objective 1.7: Create and edit text files
# Difficulty: 3/5

IS_LAB=true
LAB_ID="v10_1_7_create_and_edit_text_files_d3"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="3"
OBJECTIVE_TAG="Create and edit text files - practice level 3"
OBJECTIVE_IDS="1.7"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Create and edit text files - practice level 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="In /tmp/exam/v10/1.7/app.conf, change mode=development to mode=production."
TASK_1_HINT="Edit only the matching setting."
TASK_1_COMMAND_1="sed -i \"s/^mode=development\$/mode=production/\" /tmp/exam/v10/1.7/app.conf"

TASK_2_QUESTION="Add enabled=true as the final line of /tmp/exam/v10/1.7/app.conf."
TASK_2_HINT="Append one line without replacing existing content."
TASK_2_COMMAND_1="printf \"enabled=true\\n\" >> /tmp/exam/v10/1.7/app.conf"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/1.7; mkdir -p /tmp/exam/v10/1.7; printf "mode=development\nport=8080\n" > /tmp/exam/v10/1.7/app.conf
}

_check_task_1_live() {
  grep -Fxq mode=production /tmp/exam/v10/1.7/app.conf && ! grep -q development /tmp/exam/v10/1.7/app.conf
}

_check_task_2_live() {
  [[ "$(tail -1 /tmp/exam/v10/1.7/app.conf)" == enabled=true ]]
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
  rm -rf /tmp/exam/v10/1.7
}
