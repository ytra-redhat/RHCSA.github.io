#!/bin/bash
# RHCSA v10 objective 7.1: Schedule tasks using at, cron, and systemd timer units
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_7_1_schedule_recurring_work_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Schedule recurring work"
OBJECTIVE_IDS="7.1"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Schedule recurring work"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create /etc/cron.d/rhcsa-v10 to append the date to /var/tmp/rhcsa-v10-cron every day at 02:15 as root."
TASK_1_HINT="Use system cron format including the user field."
TASK_1_COMMAND_1="printf \"15 2 * * * root date >> /var/tmp/rhcsa-v10-cron\\n\" > /etc/cron.d/rhcsa-v10; chmod 0644 /etc/cron.d/rhcsa-v10"

TASK_2_QUESTION="Create and enable rhcsa-v10.timer to run rhcsa-v10.service five minutes after boot and every hour."
TASK_2_HINT="Define matching service and timer units, reload systemd, and enable the timer."
TASK_2_COMMAND_1="printf \"[Unit]\\nDescription=RHCSA v10 task\\n[Service]\\nType=oneshot\\nExecStart=/usr/bin/touch /var/tmp/rhcsa-v10-timer\\n\" > /etc/systemd/system/rhcsa-v10.service; printf \"[Unit]\\nDescription=RHCSA v10 timer\\n[Timer]\\nOnBootSec=5min\\nOnUnitActiveSec=1h\\n[Install]\\nWantedBy=timers.target\\n\" > /etc/systemd/system/rhcsa-v10.timer; systemctl daemon-reload; systemctl enable --now rhcsa-v10.timer"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -f /etc/cron.d/rhcsa-v10 /etc/systemd/system/rhcsa-v10.service /etc/systemd/system/rhcsa-v10.timer; systemctl daemon-reload
}

_check_task_1_live() {
  grep -Fxq "15 2 * * * root date >> /var/tmp/rhcsa-v10-cron" /etc/cron.d/rhcsa-v10 && [[ "$(stat -c %a /etc/cron.d/rhcsa-v10)" == 644 ]]
}

_check_task_2_live() {
  systemctl is-enabled --quiet rhcsa-v10.timer && systemctl is-active --quiet rhcsa-v10.timer
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
  systemctl disable --now rhcsa-v10.timer >/dev/null 2>&1 || true; rm -f /etc/cron.d/rhcsa-v10 /etc/systemd/system/rhcsa-v10.service /etc/systemd/system/rhcsa-v10.timer /var/tmp/rhcsa-v10-cron /var/tmp/rhcsa-v10-timer; systemctl daemon-reload
}
