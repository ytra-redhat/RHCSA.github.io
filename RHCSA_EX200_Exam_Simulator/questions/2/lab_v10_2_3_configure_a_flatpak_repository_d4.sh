#!/bin/bash
# RHCSA v10 objective 2.3: Configure access to Flatpak repositories
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_2_3_configure_a_flatpak_repository_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Configure a Flatpak repository"
OBJECTIVE_IDS="2.3"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Configure a Flatpak repository"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Add system Flatpak remote rhcsa-v10 using https://dl.flathub.org/repo/flathub.flatpakrepo."
TASK_1_HINT="Add the remote at system scope and do not duplicate an existing definition."
TASK_1_COMMAND_1="flatpak remote-add --system --if-not-exists rhcsa-v10 https://dl.flathub.org/repo/flathub.flatpakrepo"

TASK_2_QUESTION="Disable system Flatpak remote rhcsa-v10."
TASK_2_HINT="Modify the existing remote rather than deleting it."
TASK_2_COMMAND_1="flatpak remote-modify --system --disable rhcsa-v10"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  flatpak remote-delete --system rhcsa-v10 >/dev/null 2>&1 || true
}

_check_task_1_live() {
  flatpak remotes --system --columns=name | grep -Fxq rhcsa-v10
}

_check_task_2_live() {
  flatpak remotes --system --show-disabled --columns=name,options | grep -E "^rhcsa-v10.*disabled"
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
  flatpak remote-delete --system rhcsa-v10 >/dev/null 2>&1 || true
}
