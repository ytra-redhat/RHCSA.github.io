#!/bin/bash
# RHCSA v10 objective 4.1: Boot, reboot, and shut down a system normally
# Difficulty: 5/5

IS_LAB=true
LAB_ID="v10_4_1_ch4_integrated_d5"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="5"
OBJECTIVE_TAG="Integrated RHCSA v10 chapter 4 scenario"
OBJECTIVE_IDS="4.1,4.2,4.3,4.4,4.5,4.6,4.7,4.8,4.9,4.10"
LAB_KIND="integrated-exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="mixed"
QUESTION="Integrated RHCSA v10 chapter 4 scenario"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Enable sshd and preserve the journal across reboot."
TASK_1_HINT="Use service enablement and a journald drop-in."
TASK_1_COMMAND_1="systemctl enable --now sshd; mkdir -p /etc/systemd/journald.conf.d /var/log/journal; printf \"[Journal]\\nStorage=persistent\\n\" > /etc/systemd/journald.conf.d/integrated-v10.conf; systemctl restart systemd-journald"

TASK_2_QUESTION="Start a sleep process at nice value 12 and write its PID and nice value to /tmp/exam/v10/integrated4/process."
TASK_2_HINT="Launch it with the requested initial priority."
TASK_2_COMMAND_1="mkdir -p /tmp/exam/v10/integrated4; nice -n 12 sleep 600 & echo \$! > /tmp/exam/v10/integrated4/pid; ps -p \$! -o pid=,ni= > /tmp/exam/v10/integrated4/process"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/integrated4; mkdir -p /tmp/exam/v10/integrated4; rm -f /etc/systemd/journald.conf.d/integrated-v10.conf
}

_check_task_1_live() {
  systemctl is-enabled --quiet sshd && systemctl is-active --quiet sshd && grep -Fxq Storage=persistent /etc/systemd/journald.conf.d/integrated-v10.conf
}

_check_task_2_live() {
  grep -Eq "[[:space:]]12$" /tmp/exam/v10/integrated4/process
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
  [[ -f /tmp/exam/v10/integrated4/pid ]] && kill "$(cat /tmp/exam/v10/integrated4/pid)" >/dev/null 2>&1 || true; rm -f /etc/systemd/journald.conf.d/integrated-v10.conf; systemctl restart systemd-journald >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/integrated4
}
