#!/bin/bash
# RHCSA v10 objective 7.6: Modify the system bootloader
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_7_6_modify_persistent_kernel_arguments_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Modify persistent kernel arguments"
OBJECTIVE_IDS="7.6"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Modify persistent kernel arguments"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Add audit=1 to every installed kernel entry."
TASK_1_HINT="Use the RHEL bootloader management interface for all kernels."
TASK_1_COMMAND_1="grubby --update-kernel=ALL --args=\"audit=1\""

TASK_2_QUESTION="Write the arguments of the default kernel to /tmp/exam/v10/7.6/args."
TASK_2_HINT="Query the default kernel entry."
TASK_2_COMMAND_1="mkdir -p /tmp/exam/v10/7.6; grubby --info=DEFAULT | sed -n \"s/^args=//p\" > /tmp/exam/v10/7.6/args"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/7.6; mkdir -p /tmp/exam/v10/7.6; grubby --update-kernel=ALL --remove-args="audit=1" >/dev/null 2>&1 || true
}

_check_task_1_live() {
  grubby --info=ALL | grep -q "args=.*audit=1"
}

_check_task_2_live() {
  grep -q audit=1 /tmp/exam/v10/7.6/args
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
  grubby --update-kernel=ALL --remove-args="audit=1" >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/7.6
}
