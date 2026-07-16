#!/bin/bash
# RHCSA v10 objective 1.3: Use grep and regular expressions to analyze text
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_1_3_regular_expression_text_analysis_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Regular-expression text analysis"
OBJECTIVE_IDS="1.3"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Regular-expression text analysis"
LAB_TASK_COUNT=2

TASK_1_QUESTION="From /tmp/exam/v10/1.3/accounts, write lines that start with a lowercase letter and end in a digit to /tmp/exam/v10/1.3/matches."
TASK_1_HINT="Use anchors and character classes."
TASK_1_COMMAND_1="grep -E \"^[[:lower:]].*[[:digit:]]\$\" /tmp/exam/v10/1.3/accounts > /tmp/exam/v10/1.3/matches"

TASK_2_QUESTION="Write all lines that do not contain disabled to /tmp/exam/v10/1.3/enabled."
TASK_2_HINT="Use inverted matching."
TASK_2_COMMAND_1="grep -v \"disabled\" /tmp/exam/v10/1.3/accounts > /tmp/exam/v10/1.3/enabled"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/1.3; mkdir -p /tmp/exam/v10/1.3; printf "alpha1\nBeta2\ndisabled\ngamma3\n" > /tmp/exam/v10/1.3/accounts
}

_check_task_1_live() {
  diff -u <(printf "alpha1\ngamma3\n") /tmp/exam/v10/1.3/matches >/dev/null
}

_check_task_2_live() {
  ! grep -q disabled /tmp/exam/v10/1.3/enabled
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
  rm -rf /tmp/exam/v10/1.3
}
