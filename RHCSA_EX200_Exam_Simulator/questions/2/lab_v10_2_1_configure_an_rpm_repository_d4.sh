#!/bin/bash
# RHCSA v10 objective 2.1: Configure access to RPM repositories
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_2_1_configure_an_rpm_repository_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Configure an RPM repository"
OBJECTIVE_IDS="2.1"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Configure an RPM repository"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create enabled repository rhcsa-v10 in /etc/yum.repos.d/rhcsa-v10.repo using file:///tmp/exam/v10/2.1/repo with GPG checking disabled."
TASK_1_HINT="Create a valid repository section with name, baseurl, enabled, and gpgcheck."
TASK_1_COMMAND_1="printf \"[rhcsa-v10]\\nname=RHCSA v10 local\\nbaseurl=file:///tmp/exam/v10/2.1/repo\\nenabled=1\\ngpgcheck=0\\n\" > /etc/yum.repos.d/rhcsa-v10.repo"

TASK_2_QUESTION="Write the repository definition reported by DNF to /tmp/exam/v10/2.1/repo-info."
TASK_2_HINT="Query only the named repository."
TASK_2_COMMAND_1="dnf repoinfo rhcsa-v10 > /tmp/exam/v10/2.1/repo-info 2>&1"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/2.1; mkdir -p /tmp/exam/v10/2.1/repo; rm -f /etc/yum.repos.d/rhcsa-v10.repo
}

_check_task_1_live() {
  dnf repolist --all 2>/dev/null | grep -q "rhcsa-v10"
}

_check_task_2_live() {
  grep -q "Repo-id.*rhcsa-v10" /tmp/exam/v10/2.1/repo-info
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
  rm -f /etc/yum.repos.d/rhcsa-v10.repo; rm -rf /tmp/exam/v10/2.1
}
