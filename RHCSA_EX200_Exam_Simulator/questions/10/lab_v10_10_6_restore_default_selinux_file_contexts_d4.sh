#!/bin/bash
# RHCSA v10 objective 10.6: Restore default file contexts
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_10_6_restore_default_selinux_file_contexts_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Restore default SELinux file contexts"
OBJECTIVE_IDS="10.6"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="true"
QUESTION="Restore default SELinux file contexts"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create a persistent httpd_sys_content_t mapping for /srv/rhcsa-v10-web and its contents."
TASK_1_HINT="Use a regular expression that covers the directory tree."
TASK_1_COMMAND_1="semanage fcontext -a -t httpd_sys_content_t \"/srv/rhcsa-v10-web(/.*)?\""

TASK_2_QUESTION="Apply the default mapping recursively to /srv/rhcsa-v10-web."
TASK_2_HINT="Use the policy database rather than a temporary chcon change."
TASK_2_COMMAND_1="restorecon -RF /srv/rhcsa-v10-web"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /srv/rhcsa-v10-web; mkdir -p /srv/rhcsa-v10-web; touch /srv/rhcsa-v10-web/index.html; semanage fcontext -d "/srv/rhcsa-v10-web(/.*)?" >/dev/null 2>&1 || true
}

_check_task_1_live() {
  semanage fcontext -l | grep -q "/srv/rhcsa-v10-web(/.*)?.*httpd_sys_content_t"
}

_check_task_2_live() {
  [[ "$(ls -Zd /srv/rhcsa-v10-web | awk "{print \$1}" | cut -d: -f3)" == httpd_sys_content_t ]]
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
  semanage fcontext -d "/srv/rhcsa-v10-web(/.*)?" >/dev/null 2>&1 || true; restorecon -RF /srv/rhcsa-v10-web >/dev/null 2>&1 || true; rm -rf /srv/rhcsa-v10-web
}
