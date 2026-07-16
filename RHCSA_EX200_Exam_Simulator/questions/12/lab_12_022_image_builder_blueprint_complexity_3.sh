#!/bin/bash
# Chapter 12: Bonus RHEL 9 installation and legacy administration
# Objective: Kickstart
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch12_022_image_builder_blueprint_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="Kickstart"
QUESTION="Image Builder blueprint - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create or overwrite /tmp/exam/ch12_22.toml with the following exact line(s): \"name=rhcsa-22\"; \"version=0.0.1\"."
TASK_1_HINT="Suggested command: printf 'name=rhcsa-22\\nversion=0.0.1\\n' > /tmp/exam/ch12_22.toml. Explanation: > overwrites the destination with standard output. printf writes deterministic text, including the requested line breaks."
TASK_1_COMMAND_1="printf 'name=rhcsa-22\\nversion=0.0.1\\n' > /tmp/exam/ch12_22.toml"

TASK_2_QUESTION="Append the following exact line(s) to /tmp/exam/ch12_22.toml without removing its existing content: \"[[packages]]\"; \"name=bash\"; \"version=*\"."
TASK_2_HINT="Suggested command: printf '[[packages]]\\nname=bash\\nversion=*\\n' >> /tmp/exam/ch12_22.toml. Explanation: >> appends and preserves existing file content. printf writes deterministic text, including the requested line breaks."
TASK_2_COMMAND_1="printf '[[packages]]\\nname=bash\\nversion=*\\n' >> /tmp/exam/ch12_22.toml"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch12_22* /tmp/rhcsa_12_22 /var/tmp/rhcsa_12_22.img
}

_check_task_1_live() {
  [[ -s /tmp/exam/ch12_22.toml ]]
}

_check_task_2_live() {
  grep -q bash /tmp/exam/ch12_22.toml
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
  rm -rf /tmp/exam/ch12_22* /tmp/rhcsa_12_22 /var/tmp/rhcsa_12_22.img
}
