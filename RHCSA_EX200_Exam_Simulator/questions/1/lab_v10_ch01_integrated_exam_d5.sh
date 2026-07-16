#!/bin/bash
# RHCSA v10 objective 1.1: Access a shell prompt and issue commands with correct syntax
# Difficulty: 5/5

IS_LAB=true
LAB_ID="v10_1_1_ch1_integrated_d5"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="5"
OBJECTIVE_TAG="Integrated RHCSA v10 chapter 1 scenario"
OBJECTIVE_IDS="1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,1.10,1.11"
LAB_KIND="integrated-exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="mixed"
QUESTION="Integrated RHCSA v10 chapter 1 scenario"
LAB_TASK_COUNT=3

TASK_1_QUESTION="Create /tmp/exam/v10/integrated1/a containing alpha, beta, and gamma on separate lines."
TASK_1_HINT="Choose a noninteractive text-writing method."
TASK_1_COMMAND_1="mkdir -p /tmp/exam/v10/integrated1; printf \"alpha\\nbeta\\ngamma\\n\" > /tmp/exam/v10/integrated1/a"

TASK_2_QUESTION="Create gzip archive /tmp/exam/v10/integrated1/a.tar.gz containing that file."
TASK_2_HINT="Use the archive format indicated by the suffix."
TASK_2_COMMAND_1="tar -czf /tmp/exam/v10/integrated1/a.tar.gz -C /tmp/exam/v10/integrated1 a"

TASK_3_QUESTION="Create hard link a.hard and relative symbolic link a.soft to a."
TASK_3_HINT="Verify inode equality and the symbolic target."
TASK_3_COMMAND_1="ln /tmp/exam/v10/integrated1/a /tmp/exam/v10/integrated1/a.hard; ln -s a /tmp/exam/v10/integrated1/a.soft"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/integrated1; mkdir -p /tmp/exam/v10/integrated1
}

_check_task_1_live() {
  diff -u <(printf "alpha\nbeta\ngamma\n") /tmp/exam/v10/integrated1/a >/dev/null
}

_check_task_2_live() {
  tar -tzf /tmp/exam/v10/integrated1/a.tar.gz | grep -Fxq a
}

_check_task_3_live() {
  [[ "$(stat -c %i /tmp/exam/v10/integrated1/a)" == "$(stat -c %i /tmp/exam/v10/integrated1/a.hard)" && "$(readlink /tmp/exam/v10/integrated1/a.soft)" == a ]]
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
  TASK_STATUS[2]="false"
  if _is_done 3; then
    TASK_STATUS[2]="true"
  elif _check_task_3_live; then
    TASK_STATUS[2]="true"
    _mark_done 3
  fi
}

cleanup_lab() {
  rm -rf /tmp/exam/v10/integrated1
}
