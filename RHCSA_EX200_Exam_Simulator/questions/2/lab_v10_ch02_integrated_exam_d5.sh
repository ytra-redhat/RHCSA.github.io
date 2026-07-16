#!/bin/bash
# RHCSA v10 objective 2.1: Configure access to RPM repositories
# Difficulty: 5/5

IS_LAB=true
LAB_ID="v10_2_1_ch2_integrated_d5"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="5"
OBJECTIVE_TAG="Integrated RHCSA v10 chapter 2 scenario"
OBJECTIVE_IDS="2.1,2.2,2.3,2.4"
LAB_KIND="integrated-exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="mixed"
QUESTION="Integrated RHCSA v10 chapter 2 scenario"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Configure enabled local repository integrated-v10 at file:///tmp/exam/v10/integrated2/repo."
TASK_1_HINT="Create a valid DNF repository file."
TASK_1_COMMAND_1="mkdir -p /tmp/exam/v10/integrated2/repo; printf \"[integrated-v10]\\nname=Integrated\\nbaseurl=file:///tmp/exam/v10/integrated2/repo\\nenabled=1\\ngpgcheck=0\\n\" > /etc/yum.repos.d/integrated-v10.repo"

TASK_2_QUESTION="Install bc and write its RPM version to /tmp/exam/v10/integrated2/version."
TASK_2_HINT="Use DNF then query the installed RPM."
TASK_2_COMMAND_1="dnf -y install bc; rpm -q --qf \"%{VERSION}\\n\" bc > /tmp/exam/v10/integrated2/version"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/integrated2; mkdir -p /tmp/exam/v10/integrated2/repo; rm -f /etc/yum.repos.d/integrated-v10.repo
}

_check_task_1_live() {
  dnf repolist --all 2>/dev/null | grep -q integrated-v10
}

_check_task_2_live() {
  rpm -q bc >/dev/null && [[ -s /tmp/exam/v10/integrated2/version ]]
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
  rm -f /etc/yum.repos.d/integrated-v10.repo; dnf -y remove bc >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/integrated2
}
