#!/bin/bash
# RHCSA v10 objective 10.1: Configure firewall settings using firewall-cmd and firewalld
# Difficulty: 5/5

IS_LAB=true
LAB_ID="v10_10_1_ch10_integrated_d5"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="5"
OBJECTIVE_TAG="Integrated RHCSA v10 chapter 10 scenario"
OBJECTIVE_IDS="10.1,10.2,10.3,10.4,10.5,10.6,10.7,10.8"
LAB_KIND="integrated-exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="mixed"
QUESTION="Integrated RHCSA v10 chapter 10 scenario"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Label /srv/v10int-web and its contents httpd_sys_content_t persistently, then apply the label."
TASK_1_HINT="Use semanage fcontext and restorecon."
TASK_1_COMMAND_1="mkdir -p /srv/v10int-web; semanage fcontext -a -t httpd_sys_content_t \"/srv/v10int-web(/.*)?\"; restorecon -RF /srv/v10int-web"

TASK_2_QUESTION="Permanently enable httpd_can_network_connect and allow TCP 8443 in firewalld."
TASK_2_HINT="Persist both SELinux and firewall changes."
TASK_2_COMMAND_1="setsebool -P httpd_can_network_connect on; firewall-cmd --permanent --zone=public --add-port=8443/tcp; firewall-cmd --reload"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  semanage fcontext -d "/srv/v10int-web(/.*)?" >/dev/null 2>&1 || true; rm -rf /srv/v10int-web; systemctl start firewalld; firewall-cmd --permanent --zone=public --remove-port=8443/tcp >/dev/null 2>&1 || true; firewall-cmd --reload >/dev/null 2>&1 || true; getsebool httpd_can_network_connect | awk "{print \$3}" > /tmp/rhcsa-v10-bool-original
}

_check_task_1_live() {
  [[ "$(ls -Zd /srv/v10int-web | awk "{print \$1}" | cut -d: -f3)" == httpd_sys_content_t ]]
}

_check_task_2_live() {
  [[ "$(getsebool httpd_can_network_connect | awk "{print \$3}")" == on ]] && firewall-cmd --zone=public --query-port=8443/tcp >/dev/null
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
  semanage fcontext -d "/srv/v10int-web(/.*)?" >/dev/null 2>&1 || true; rm -rf /srv/v10int-web; setsebool -P httpd_can_network_connect off >/dev/null 2>&1 || true; firewall-cmd --permanent --zone=public --remove-port=8443/tcp >/dev/null 2>&1 || true; firewall-cmd --reload >/dev/null 2>&1 || true
}
