#!/bin/bash
# RHCSA v10 objective 4.3: Interrupt the boot process to gain access to a system
# Difficulty: 1/5

IS_LAB=true
LAB_ID="v10_4_3_recover_access_through_the_boot_loader_d1"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="1"
OBJECTIVE_TAG="Recover access through the boot loader - practice level 1"
OBJECTIVE_IDS="4.3"
LAB_KIND="guided-manual"
STATE_CHANGING="false"
PERSISTENCE_REQUIRED="reboot"
QUESTION="Recover access through the boot loader - practice level 1"
LAB_TASK_COUNT=1

LAB_WARNING="Take a VM snapshot. This lab requires a GRUB rd.break boot and cannot be completed only in the browser terminal."

TASK_1_QUESTION="Using a VM snapshot, interrupt GRUB boot with rd.break and create /var/tmp/rhcsa-v10-boot-recovery inside the installed system before continuing boot."
TASK_1_HINT="At the break shell, remount the installed root read-write and work inside its sysroot."
TASK_1_COMMAND_1="touch /var/tmp/rhcsa-v10-boot-recovery"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -f /var/tmp/rhcsa-v10-boot-recovery
}

_check_task_1_live() {
  [[ -f /var/tmp/rhcsa-v10-boot-recovery ]]
}

check_tasks() {
  TASK_STATUS[0]="false"
  if _is_done 1; then
    TASK_STATUS[0]="true"
  elif _check_task_1_live; then
    TASK_STATUS[0]="true"
    _mark_done 1
  fi
}

cleanup_lab() {
  rm -f /var/tmp/rhcsa-v10-boot-recovery
}
