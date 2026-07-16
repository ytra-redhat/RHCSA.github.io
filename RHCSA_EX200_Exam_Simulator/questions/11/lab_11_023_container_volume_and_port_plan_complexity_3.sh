#!/bin/bash
# Chapter 11: Bonus RHEL 9 containers with Podman
# Objective: systemd integration
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch11_023_container_volume_and_port_plan_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="systemd integration"
OBJECTIVE_IDS="11.0"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Container volume and port plan - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create directory /tmp/exam/ch11_23_volume, including missing parent directories, and set its numeric mode to exactly 775."
TASK_1_HINT="Review the install manual page and verify the requested final state."
TASK_1_COMMAND_1="install -d -m 775 /tmp/exam/ch11_23_volume"

TASK_2_QUESTION="Create or overwrite /tmp/exam/ch11_23_run.txt with the following exact line(s): \"podman run -d -p 8080:80 -v /tmp/exam/ch11_23_volume:/data:Z IMAGE\"."
TASK_2_HINT="Use standard-output redirection to the requested path."
TASK_2_COMMAND_1="printf 'podman run -d -p 8080:80 -v /tmp/exam/ch11_23_volume:/data:Z IMAGE\\n' > /tmp/exam/ch11_23_run.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch11_23* /tmp/rhcsa_11_23 /var/tmp/rhcsa_11_23.img
}

_check_task_1_live() {
  [[ "$(stat -c %a /tmp/exam/ch11_23_volume)" = 775 ]]
}

_check_task_2_live() {
  grep -q 8080:80 /tmp/exam/ch11_23_run.txt
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
  rm -rf /tmp/exam/ch11_23* /tmp/rhcsa_11_23 /var/tmp/rhcsa_11_23.img
}
