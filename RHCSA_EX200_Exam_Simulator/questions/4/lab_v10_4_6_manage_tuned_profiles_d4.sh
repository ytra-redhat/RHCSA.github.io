#!/bin/bash
# RHCSA v10 objective 4.6: Manage tuning profiles
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_4_6_manage_tuned_profiles_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Manage TuneD profiles"
OBJECTIVE_IDS="4.6"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Manage TuneD profiles"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Activate the virtual-guest TuneD profile."
TASK_1_HINT="Select the named profile and verify the active profile."
TASK_1_COMMAND_1="tuned-adm profile virtual-guest"

TASK_2_QUESTION="Write the active TuneD profile to /tmp/exam/v10/4.6/active."
TASK_2_HINT="Save only the profile status output."
TASK_2_COMMAND_1="tuned-adm active > /tmp/exam/v10/4.6/active"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/4.6; mkdir -p /tmp/exam/v10/4.6; tuned-adm active 2>/dev/null | sed -n "s/.*: //p" > /tmp/exam/v10/4.6/original || true
}

_check_task_1_live() {
  tuned-adm active 2>/dev/null | grep -q "virtual-guest"
}

_check_task_2_live() {
  grep -q "virtual-guest" /tmp/exam/v10/4.6/active
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
  orig=$(cat /tmp/exam/v10/4.6/original 2>/dev/null); [[ -n "$orig" ]] && tuned-adm profile "$orig" >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/4.6
}
