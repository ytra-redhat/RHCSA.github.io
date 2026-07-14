#!/bin/bash
# Chapter 11: Bonus RHEL 9 containers with Podman
# Objective: ports
# Difficulty: 5/5

IS_LAB=true
LAB_ID="ch11_045_quadlet_artifact_complexity_5"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="5"
OBJECTIVE_TAG="ports"
QUESTION="Quadlet artifact - complexity 5"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create /tmp/exam/ch11_45.container with an Image line"
TASK_1_HINT="Use [Container] and Image=registry.example.com/app:latest"
TASK_1_COMMAND_1="printf '[Container]\\nImage=registry.example.com/app:latest\\n' > /tmp/exam/ch11_45.container"

TASK_2_QUESTION="Add WantedBy=default.target"
TASK_2_HINT="Append an Install section"
TASK_2_COMMAND_1="printf '[Install]\\nWantedBy=default.target\\n' >> /tmp/exam/ch11_45.container"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch11_45* /tmp/rhcsa_11_45 /var/tmp/rhcsa_11_45.img
}

_check_task_1_live() {
  grep -Fxq "Image=registry.example.com/app:latest" /tmp/exam/ch11_45.container
}

_check_task_2_live() {
  grep -Fxq "WantedBy=default.target" /tmp/exam/ch11_45.container
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
  rm -rf /tmp/exam/ch11_45* /tmp/rhcsa_11_45 /var/tmp/rhcsa_11_45.img
}
