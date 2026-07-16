#!/bin/bash
# RHCSA v10 objective 9.4: Configure privileged access
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_9_4_configure_privileged_access_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Configure privileged access"
OBJECTIVE_IDS="9.4"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Configure privileged access"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Allow members of project10 to run /usr/bin/systemctl status sshd as root without a password."
TASK_1_HINT="Create a validated sudoers drop-in with an exact command rule."
TASK_1_COMMAND_1="printf \"%%project10 ALL=(root) NOPASSWD: /usr/bin/systemctl status sshd\\n\" > /etc/sudoers.d/rhcsa-v10; chmod 0440 /etc/sudoers.d/rhcsa-v10"

TASK_2_QUESTION="Verify the configured rule for analyst10 and write the result to /tmp/exam/v10/9.4/sudo-list."
TASK_2_HINT="List the user privileges without executing another command."
TASK_2_COMMAND_1="sudo -l -U analyst10 > /tmp/exam/v10/9.4/sudo-list"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/9.4; mkdir -p /tmp/exam/v10/9.4; id analyst10 >/dev/null 2>&1 || useradd -m analyst10; getent group project10 >/dev/null || groupadd project10; usermod -aG project10 analyst10; rm -f /etc/sudoers.d/rhcsa-v10
}

_check_task_1_live() {
  visudo -cf /etc/sudoers.d/rhcsa-v10 >/dev/null && grep -q "^%project10 .*NOPASSWD: /usr/bin/systemctl status sshd$" /etc/sudoers.d/rhcsa-v10
}

_check_task_2_live() {
  grep -q "/usr/bin/systemctl status sshd" /tmp/exam/v10/9.4/sudo-list
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
  rm -f /etc/sudoers.d/rhcsa-v10; userdel -r analyst10 >/dev/null 2>&1 || true; groupdel project10 >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/9.4
}
