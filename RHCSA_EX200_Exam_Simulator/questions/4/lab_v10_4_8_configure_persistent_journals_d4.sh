#!/bin/bash
# RHCSA v10 objective 4.8: Preserve system journals
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_4_8_configure_persistent_journals_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Configure persistent journals"
OBJECTIVE_IDS="4.8"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Configure persistent journals"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Configure journald to use persistent storage in /etc/systemd/journald.conf.d/rhcsa-v10.conf."
TASK_1_HINT="Use a drop-in with a Journal section."
TASK_1_COMMAND_1="mkdir -p /etc/systemd/journald.conf.d /var/log/journal; printf \"[Journal]\\nStorage=persistent\\n\" > /etc/systemd/journald.conf.d/rhcsa-v10.conf"

TASK_2_QUESTION="Restart systemd-journald and verify it is active."
TASK_2_HINT="Restart the service after writing the drop-in."
TASK_2_COMMAND_1="systemctl restart systemd-journald"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam/v10/4.8; [[ -f /etc/systemd/journald.conf.d/rhcsa-v10.conf ]] && cp -a /etc/systemd/journald.conf.d/rhcsa-v10.conf /tmp/exam/v10/4.8/original || true
}

_check_task_1_live() {
  grep -Fxq Storage=persistent /etc/systemd/journald.conf.d/rhcsa-v10.conf && [[ -d /var/log/journal ]]
}

_check_task_2_live() {
  systemctl is-active --quiet systemd-journald
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
  if [[ -f /tmp/exam/v10/4.8/original ]]; then cp -a /tmp/exam/v10/4.8/original /etc/systemd/journald.conf.d/rhcsa-v10.conf; else rm -f /etc/systemd/journald.conf.d/rhcsa-v10.conf; fi; systemctl restart systemd-journald >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/4.8
}
