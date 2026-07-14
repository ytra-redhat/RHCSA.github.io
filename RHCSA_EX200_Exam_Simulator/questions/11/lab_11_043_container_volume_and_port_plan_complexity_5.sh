#!/bin/bash
# Chapter 11: Bonus RHEL 9 containers with Podman
# Objective: registries
# Difficulty: 5/5

IS_LAB=true
LAB_ID="ch11_043_container_volume_and_port_plan_complexity_5"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="5"
OBJECTIVE_TAG="registries"
QUESTION="Container volume and port plan - complexity 5"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create volume directory /tmp/exam/ch11_43_volume mode 775"
TASK_1_HINT="Use install -d -m 775"
TASK_1_COMMAND_1="install -d -m 775 /tmp/exam/ch11_43_volume"

TASK_2_QUESTION="Create run command artifact /tmp/exam/ch11_43_run.txt"
TASK_2_HINT="Include port 8080:80 and :Z volume"
TASK_2_COMMAND_1="printf 'podman run -d -p 8080:80 -v /tmp/exam/ch11_43_volume:/data:Z IMAGE\\n' > /tmp/exam/ch11_43_run.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch11_43* /tmp/rhcsa_11_43 /var/tmp/rhcsa_11_43.img
}

_check_task_1_live() {
  [[ "$(stat -c %a /tmp/exam/ch11_43_volume)" = 775 ]]
}

_check_task_2_live() {
  grep -q 8080:80 /tmp/exam/ch11_43_run.txt
}

check_tasks() {
  TASK_STATUS[0]="false"
  TASK_STATUS[1]="false"
  if _is_done 1; then
    TASK_STATUS[0]="true"
  elif _check_task_1_live; then
    TASK_STATUS[0]="true"
    _mark_done 1
  fi
  if _is_done 2; then
    TASK_STATUS[1]="true"
  elif _check_task_2_live; then
    TASK_STATUS[1]="true"
    _mark_done 2
  fi
}

cleanup_lab() {
  rm -rf /tmp/exam/ch11_43* /tmp/rhcsa_11_43 /var/tmp/rhcsa_11_43.img
}
