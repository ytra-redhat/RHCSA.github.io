#!/bin/bash
# RHCSA v10 objective 4.7: Locate and interpret system log files and journals
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_4_7_interpret_journal_entries_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Interpret journal entries"
OBJECTIVE_IDS="4.7"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Interpret journal entries"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create journal message RHCSA_V10_AUDIT and write its current-boot journal entry to /tmp/exam/v10/4.7/journal."
TASK_1_HINT="Use a unique logger tag and filter the journal by that tag."
TASK_1_COMMAND_1="logger -t rhcsa-v10 RHCSA_V10_AUDIT; journalctl -b -t rhcsa-v10 --no-pager > /tmp/exam/v10/4.7/journal"

TASK_2_QUESTION="Write warning-or-higher messages from the current boot to /tmp/exam/v10/4.7/warnings."
TASK_2_HINT="Filter by both boot and priority."
TASK_2_COMMAND_1="journalctl -b -p warning --no-pager > /tmp/exam/v10/4.7/warnings"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/4.7; mkdir -p /tmp/exam/v10/4.7
}

_check_task_1_live() {
  grep -q RHCSA_V10_AUDIT /tmp/exam/v10/4.7/journal
}

_check_task_2_live() {
  [[ -f /tmp/exam/v10/4.7/warnings ]]
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
  rm -rf /tmp/exam/v10/4.7
}
