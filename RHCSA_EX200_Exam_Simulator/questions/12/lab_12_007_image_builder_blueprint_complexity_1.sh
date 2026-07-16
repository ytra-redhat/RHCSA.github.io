#!/bin/bash
# Chapter 12: Bonus RHEL 9 installation and legacy administration
# Objective: legacy networking
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch12_007_image_builder_blueprint_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="legacy networking"
OBJECTIVE_IDS="12.0"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Image Builder blueprint - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create or overwrite /tmp/exam/ch12_07.toml with the following exact line(s): \"name=rhcsa-07\"; \"version=0.0.1\"."
TASK_1_HINT="Use standard-output redirection to the requested path."
TASK_1_COMMAND_1="printf 'name=rhcsa-07\\nversion=0.0.1\\n' > /tmp/exam/ch12_07.toml"

TASK_2_QUESTION="Append the standard output of \`printf '[[packages]]\\nname=bash\\nversion=*\\n'\` to /tmp/exam/ch12_07.toml."
TASK_2_HINT="Use append redirection so existing content is retained."
TASK_2_COMMAND_1="printf '[[packages]]\\nname=bash\\nversion=*\\n' >> /tmp/exam/ch12_07.toml"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch12_07* /tmp/rhcsa_12_07 /var/tmp/rhcsa_12_07.img
}

_check_task_1_live() {
  [[ -s /tmp/exam/ch12_07.toml ]]
}

_check_task_2_live() {
  grep -q bash /tmp/exam/ch12_07.toml
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
  rm -rf /tmp/exam/ch12_07* /tmp/rhcsa_12_07 /var/tmp/rhcsa_12_07.img
}
