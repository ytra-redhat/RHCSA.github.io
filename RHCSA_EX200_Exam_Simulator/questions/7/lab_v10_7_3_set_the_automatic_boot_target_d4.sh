#!/bin/bash
# RHCSA v10 objective 7.3: Configure systems to boot into a specific target automatically
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_7_3_set_the_automatic_boot_target_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Set the automatic boot target"
OBJECTIVE_IDS="7.3"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Set the automatic boot target"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Set multi-user.target as the default boot target."
TASK_1_HINT="Change the persistent systemd default target."
TASK_1_COMMAND_1="systemctl set-default multi-user.target"

TASK_2_QUESTION="Write the resolved default.target symlink target to /tmp/exam/v10/7.3/default-target."
TASK_2_HINT="Resolve the systemd target symlink."
TASK_2_COMMAND_1="mkdir -p /tmp/exam/v10/7.3; readlink -f /etc/systemd/system/default.target > /tmp/exam/v10/7.3/default-target"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam/v10/7.3; systemctl get-default > /tmp/exam/v10/7.3/original
}

_check_task_1_live() {
  [[ "$(systemctl get-default)" == multi-user.target ]]
}

_check_task_2_live() {
  grep -q "/multi-user.target$" /tmp/exam/v10/7.3/default-target
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
  orig=$(cat /tmp/exam/v10/7.3/original 2>/dev/null || echo multi-user.target); systemctl set-default "$orig" >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/7.3
}
