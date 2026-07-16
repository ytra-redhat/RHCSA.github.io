#!/bin/bash
# RHCSA v10 objective 9.1: Create, delete, and modify local user accounts
# Difficulty: 5/5

IS_LAB=true
LAB_ID="v10_9_1_ch9_integrated_d5"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="5"
OBJECTIVE_TAG="Integrated RHCSA v10 chapter 9 scenario"
OBJECTIVE_IDS="9.1,9.2,9.3,9.4"
LAB_KIND="integrated-exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="mixed"
QUESTION="Integrated RHCSA v10 chapter 9 scenario"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create group v10admins and user v10operator with v10admins as a supplementary group."
TASK_1_HINT="Create the group before assigning membership."
TASK_1_COMMAND_1="groupadd v10admins; useradd -m -G v10admins v10operator"

TASK_2_QUESTION="Allow v10admins to run systemctl restart chronyd without a password."
TASK_2_HINT="Use a validated sudoers drop-in."
TASK_2_COMMAND_1="printf \"%%v10admins ALL=(root) NOPASSWD: /usr/bin/systemctl restart chronyd\\n\" > /etc/sudoers.d/v10int; chmod 0440 /etc/sudoers.d/v10int"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -f /etc/sudoers.d/v10int; userdel -r v10operator >/dev/null 2>&1 || true; groupdel v10admins >/dev/null 2>&1 || true
}

_check_task_1_live() {
  id -nG v10operator | tr " " "\n" | grep -Fxq v10admins
}

_check_task_2_live() {
  visudo -cf /etc/sudoers.d/v10int >/dev/null
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
  rm -f /etc/sudoers.d/v10int; userdel -r v10operator >/dev/null 2>&1 || true; groupdel v10admins >/dev/null 2>&1 || true
}
