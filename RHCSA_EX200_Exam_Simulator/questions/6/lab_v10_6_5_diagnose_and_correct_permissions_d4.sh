#!/bin/bash
# RHCSA v10 objective 6.5: Diagnose and correct file permission problems
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_6_5_diagnose_and_correct_permissions_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Diagnose and correct permissions"
OBJECTIVE_IDS="6.5"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Diagnose and correct permissions"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Allow user rhcsa_reader to read /srv/rhcsa-v10-secret/data without granting write access."
TASK_1_HINT="Correct directory traversal and file-read permissions; do not make the file world-writable."
TASK_1_COMMAND_1="chmod 0750 /srv/rhcsa-v10-secret; chown root:rhcsa_reader /srv/rhcsa-v10-secret; chmod 0640 /srv/rhcsa-v10-secret/data; chown root:rhcsa_reader /srv/rhcsa-v10-secret/data"

TASK_2_QUESTION="Write the directory and file modes to /tmp/exam/v10/6.5/modes."
TASK_2_HINT="Use stat with numeric modes."
TASK_2_COMMAND_1="stat -c \"%a %n\" /srv/rhcsa-v10-secret /srv/rhcsa-v10-secret/data > /tmp/exam/v10/6.5/modes"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/6.5 /srv/rhcsa-v10-secret; mkdir -p /tmp/exam/v10/6.5 /srv/rhcsa-v10-secret; printf secret > /srv/rhcsa-v10-secret/data; id rhcsa_reader >/dev/null 2>&1 || useradd -M rhcsa_reader; chmod 0700 /srv/rhcsa-v10-secret; chmod 0600 /srv/rhcsa-v10-secret/data
}

_check_task_1_live() {
  su -s /bin/bash rhcsa_reader -c "cat /srv/rhcsa-v10-secret/data" >/dev/null && ! su -s /bin/bash rhcsa_reader -c "echo x >> /srv/rhcsa-v10-secret/data" >/dev/null 2>&1
}

_check_task_2_live() {
  grep -q "750 /srv/rhcsa-v10-secret" /tmp/exam/v10/6.5/modes && grep -q "640 /srv/rhcsa-v10-secret/data" /tmp/exam/v10/6.5/modes
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
  userdel rhcsa_reader >/dev/null 2>&1 || true; rm -rf /tmp/exam/v10/6.5 /srv/rhcsa-v10-secret
}
