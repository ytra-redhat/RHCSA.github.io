#!/bin/bash
# RHCSA v10 objective 7.1: Schedule tasks using at, cron, and systemd timer units
# Difficulty: 5/5

IS_LAB=true
LAB_ID="v10_7_1_ch7_integrated_d5"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="5"
OBJECTIVE_TAG="Integrated RHCSA v10 chapter 7 scenario"
OBJECTIVE_IDS="7.1,7.2,7.3,7.4,7.5,7.6"
LAB_KIND="integrated-exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="mixed"
QUESTION="Integrated RHCSA v10 chapter 7 scenario"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create and enable v10int.timer to run /usr/local/bin/v10int every 10 minutes."
TASK_1_HINT="Create a oneshot service and matching timer."
TASK_1_COMMAND_1="printf \"#!/bin/bash\\ntouch /var/tmp/v10int-ran\\n\" > /usr/local/bin/v10int; chmod +x /usr/local/bin/v10int; printf \"[Service]\\nType=oneshot\\nExecStart=/usr/local/bin/v10int\\n\" > /etc/systemd/system/v10int.service; printf \"[Timer]\\nOnUnitActiveSec=10min\\n[Install]\\nWantedBy=timers.target\\n\" > /etc/systemd/system/v10int.timer; systemctl daemon-reload; systemctl enable --now v10int.timer"

TASK_2_QUESTION="Add systemd.show_status=true to every installed kernel entry."
TASK_2_HINT="Use the RHEL bootloader management interface."
TASK_2_COMMAND_1="grubby --update-kernel=ALL --args=\"systemd.show_status=true\""

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  systemctl disable --now v10int.timer >/dev/null 2>&1 || true; rm -f /etc/systemd/system/v10int.service /etc/systemd/system/v10int.timer /usr/local/bin/v10int; systemctl daemon-reload; grubby --update-kernel=ALL --remove-args="systemd.show_status=true" >/dev/null 2>&1 || true
}

_check_task_1_live() {
  systemctl is-enabled --quiet v10int.timer && systemctl is-active --quiet v10int.timer
}

_check_task_2_live() {
  grubby --info=ALL | grep -q systemd.show_status=true
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
  systemctl disable --now v10int.timer >/dev/null 2>&1 || true; rm -f /etc/systemd/system/v10int.service /etc/systemd/system/v10int.timer /usr/local/bin/v10int; systemctl daemon-reload; grubby --update-kernel=ALL --remove-args="systemd.show_status=true" >/dev/null 2>&1 || true
}
