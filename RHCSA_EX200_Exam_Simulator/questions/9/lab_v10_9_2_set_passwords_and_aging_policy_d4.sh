#!/bin/bash
# RHCSA v10 objective 9.2: Change passwords and adjust password aging
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_9_2_set_passwords_and_aging_policy_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Set passwords and aging policy"
OBJECTIVE_IDS="9.2"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Set passwords and aging policy"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Set analyst10 password to RedHat10!."
TASK_1_HINT="Use a noninteractive password-setting method."
TASK_1_COMMAND_1="printf \"analyst10:RedHat10!\\n\" | chpasswd"

TASK_2_QUESTION="Set minimum password age to 2 days, maximum age to 45 days, and warning period to 7 days."
TASK_2_HINT="Apply all three aging values to the account."
TASK_2_COMMAND_1="chage -m 2 -M 45 -W 7 analyst10"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  id analyst10 >/dev/null 2>&1 || useradd -m analyst10
}

_check_task_1_live() {
  passwd -S analyst10 | grep -q " PS "
}

_check_task_2_live() {
  [[ "$(chage -l analyst10 | awk -F: "/Minimum/{gsub(/ /,"",\$2);print \$2}")" == 2 && "$(chage -l analyst10 | awk -F: "/Maximum/{gsub(/ /,"",\$2);print \$2}")" == 45 ]]
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
  userdel -r analyst10 >/dev/null 2>&1 || true
}
