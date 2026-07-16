#!/bin/bash
# RHCSA v10 objective 7.2: Start and stop services and configure them to start at boot
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_7_2_deploy_and_enable_a_service_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Deploy and enable a service"
OBJECTIVE_IDS="7.2"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Deploy and enable a service"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create rhcsa-v10.service that runs /usr/local/bin/rhcsa-v10-service as a simple service."
TASK_1_HINT="The script should remain running and the unit should restart on failure."
TASK_1_COMMAND_1="printf \"#!/bin/bash\\nwhile :; do sleep 60; done\\n\" > /usr/local/bin/rhcsa-v10-service; chmod +x /usr/local/bin/rhcsa-v10-service; printf \"[Unit]\\nDescription=RHCSA v10 service\\n[Service]\\nExecStart=/usr/local/bin/rhcsa-v10-service\\nRestart=on-failure\\n[Install]\\nWantedBy=multi-user.target\\n\" > /etc/systemd/system/rhcsa-v10.service"

TASK_2_QUESTION="Enable and start rhcsa-v10.service."
TASK_2_HINT="Reload systemd after creating the unit."
TASK_2_COMMAND_1="systemctl daemon-reload; systemctl enable --now rhcsa-v10.service"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  systemctl disable --now rhcsa-v10.service >/dev/null 2>&1 || true; rm -f /etc/systemd/system/rhcsa-v10.service /usr/local/bin/rhcsa-v10-service; systemctl daemon-reload
}

_check_task_1_live() {
  systemd-analyze verify /etc/systemd/system/rhcsa-v10.service >/dev/null 2>&1
}

_check_task_2_live() {
  systemctl is-enabled --quiet rhcsa-v10.service && systemctl is-active --quiet rhcsa-v10.service
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
  systemctl disable --now rhcsa-v10.service >/dev/null 2>&1 || true; rm -f /etc/systemd/system/rhcsa-v10.service /usr/local/bin/rhcsa-v10-service; systemctl daemon-reload
}
