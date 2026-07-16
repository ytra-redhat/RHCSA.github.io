#!/bin/bash
# RHCSA v10 objective 4.1: Boot, reboot, and shut down a system normally
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_4_1_normal_reboot_and_shutdown_workflow_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Normal reboot and shutdown workflow"
OBJECTIVE_IDS="4.1"
LAB_KIND="guided-manual"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="reboot"
QUESTION="Normal reboot and shutdown workflow"
LAB_TASK_COUNT=2

LAB_WARNING="This lab reboots the practice VM. Save other work first."

TASK_1_QUESTION="Write the current boot ID to /var/tmp/rhcsa-v10-4.1-before, then reboot the VM normally."
TASK_1_HINT="Use the systemd boot identifier and a normal reboot command."
TASK_1_COMMAND_1="cat /proc/sys/kernel/random/boot_id > /var/tmp/rhcsa-v10-4.1-before && systemctl reboot"

TASK_2_QUESTION="After the VM returns, write the new boot ID to /var/tmp/rhcsa-v10-4.1-after."
TASK_2_HINT="The two boot IDs must differ."
TASK_2_COMMAND_1="cat /proc/sys/kernel/random/boot_id > /var/tmp/rhcsa-v10-4.1-after"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -f /var/tmp/rhcsa-v10-4.1-before /var/tmp/rhcsa-v10-4.1-after
}

_check_task_1_live() {
  [[ -s /var/tmp/rhcsa-v10-4.1-before ]]
}

_check_task_2_live() {
  [[ -s /var/tmp/rhcsa-v10-4.1-after && "$(cat /var/tmp/rhcsa-v10-4.1-before)" != "$(cat /var/tmp/rhcsa-v10-4.1-after)" ]]
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
  rm -f /var/tmp/rhcsa-v10-4.1-before /var/tmp/rhcsa-v10-4.1-after
}
