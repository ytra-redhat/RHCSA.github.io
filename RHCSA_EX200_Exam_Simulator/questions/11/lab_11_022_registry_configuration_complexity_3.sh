#!/bin/bash
# Chapter 11: Bonus RHEL 9 containers with Podman
# Objective: environment
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch11_022_registry_configuration_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="environment"
QUESTION="Registry configuration - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create registries config /tmp/exam/ch11_22_registries.conf"
TASK_1_HINT="Add registry.example.com"
TASK_1_COMMAND_1="printf 'registry.example.com\\n' > /tmp/exam/ch11_22_registries.conf"

TASK_2_QUESTION="Create registry notes in /tmp/exam/ch11_22_notes.txt"
TASK_2_HINT="Include search, insecure and blocked"
TASK_2_COMMAND_1="printf 'search\\ninsecure\\nblocked\\n' > /tmp/exam/ch11_22_notes.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch11_22* /tmp/rhcsa_11_22 /var/tmp/rhcsa_11_22.img
}

_check_task_1_live() {
  grep -q registry.example.com /tmp/exam/ch11_22_registries.conf
}

_check_task_2_live() {
  grep -Fxq blocked /tmp/exam/ch11_22_notes.txt
}

check_tasks() {
  TASK_STATUS[0]="false"
  TASK_STATUS[1]="false"
  if _is_done 1; then
    TASK_STATUS[0]="true"
  elif _check_task_1_live; then
    TASK_STATUS[0]="true"
    _mark_done 1
  fi
  if _is_done 2; then
    TASK_STATUS[1]="true"
  elif _check_task_2_live; then
    TASK_STATUS[1]="true"
    _mark_done 2
  fi
}

cleanup_lab() {
  rm -rf /tmp/exam/ch11_22* /tmp/rhcsa_11_22 /var/tmp/rhcsa_11_22.img
}
