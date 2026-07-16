#!/bin/bash
# RHCSA v10 objective 2.4: Install and remove Flatpak software packages
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_2_4_install_and_remove_a_flatpak_application_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Install and remove a Flatpak application"
OBJECTIVE_IDS="2.4"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Install and remove a Flatpak application"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Install org.gnome.Calculator from the flathub system remote."
TASK_1_HINT="Use noninteractive system scope and verify the application ID."
TASK_1_COMMAND_1="flatpak install --system -y flathub org.gnome.Calculator"

TASK_2_QUESTION="Remove org.gnome.Calculator from the system installation."
TASK_2_HINT="Complete task 1 before uninstalling it."
TASK_2_COMMAND_1="flatpak uninstall --system -y org.gnome.Calculator"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam/v10/2.4; if flatpak list --system --app --columns=application 2>/dev/null | grep -Fxq org.gnome.Calculator; then echo present > /tmp/exam/v10/2.4/initial; else echo absent > /tmp/exam/v10/2.4/initial; fi
}

_check_task_1_live() {
  flatpak list --system --app --columns=application | grep -Fxq org.gnome.Calculator
}

_check_task_2_live() {
  ! flatpak list --system --app --columns=application | grep -Fxq org.gnome.Calculator
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
  if [[ -f /tmp/exam/v10/2.4/initial && "$(cat /tmp/exam/v10/2.4/initial)" == present ]]; then :; else flatpak uninstall --system -y org.gnome.Calculator >/dev/null 2>&1 || true; fi; rm -rf /tmp/exam/v10/2.4
}
