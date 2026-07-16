#!/bin/bash
# Chapter 11: Bonus RHEL 9 containers with Podman
# Objective: rootless containers
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch11_025_quadlet_artifact_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="rootless containers"
QUESTION="Quadlet artifact - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create or overwrite /tmp/exam/ch11_25.container with the following exact line(s): \"[Container]\"; \"Image=registry.example.com/app:latest\"."
TASK_1_HINT="Suggested command: printf '[Container]\\nImage=registry.example.com/app:latest\\n' > /tmp/exam/ch11_25.container. Explanation: > overwrites the destination with standard output. printf writes deterministic text, including the requested line breaks."
TASK_1_COMMAND_1="printf '[Container]\\nImage=registry.example.com/app:latest\\n' > /tmp/exam/ch11_25.container"

TASK_2_QUESTION="Append the following exact line(s) to /tmp/exam/ch11_25.container without removing its existing content: \"[Install]\"; \"WantedBy=default.target\"."
TASK_2_HINT="Suggested command: printf '[Install]\\nWantedBy=default.target\\n' >> /tmp/exam/ch11_25.container. Explanation: >> appends and preserves existing file content. printf writes deterministic text, including the requested line breaks."
TASK_2_COMMAND_1="printf '[Install]\\nWantedBy=default.target\\n' >> /tmp/exam/ch11_25.container"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch11_25* /tmp/rhcsa_11_25 /var/tmp/rhcsa_11_25.img
}

_check_task_1_live() {
  grep -Fxq "Image=registry.example.com/app:latest" /tmp/exam/ch11_25.container
}

_check_task_2_live() {
  grep -Fxq "WantedBy=default.target" /tmp/exam/ch11_25.container
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
  rm -rf /tmp/exam/ch11_25* /tmp/rhcsa_11_25 /var/tmp/rhcsa_11_25.img
}
