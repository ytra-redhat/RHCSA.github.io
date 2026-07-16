#!/bin/bash
# Chapter 3: Create simple shell scripts
# Objective: text processing
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch03_005_idempotent_automation_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="text processing"
OBJECTIVE_IDS="3.4"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Idempotent automation - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create /usr/local/bin/rhcsa_05.sh that ensures /tmp/rhcsa_05 exists. Make /usr/local/bin/rhcsa_05.sh executable."
TASK_1_HINT="Use standard-output redirection to the requested path."
TASK_1_COMMAND_1="printf '#!/bin/bash\\nmkdir -p /tmp/rhcsa_05\\necho ready\\n' > /usr/local/bin/rhcsa_05.sh; chmod +x /usr/local/bin/rhcsa_05.sh"

TASK_2_QUESTION="Write the standard output of \`/usr/local/bin/rhcsa_05.sh >/dev/null; /usr/local/bin/rhcsa_05.sh\` to /tmp/exam/ch03_05_second.txt."
TASK_2_HINT="Use standard-output redirection to the requested path."
TASK_2_COMMAND_1="/usr/local/bin/rhcsa_05.sh >/dev/null; /usr/local/bin/rhcsa_05.sh > /tmp/exam/ch03_05_second.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch03_05* /tmp/rhcsa_3_05 /var/tmp/rhcsa_3_05.img
}

_check_task_1_live() {
  /usr/local/bin/rhcsa_05.sh >/dev/null && /usr/local/bin/rhcsa_05.sh >/dev/null && [[ -d /tmp/rhcsa_05 ]]
}

_check_task_2_live() {
  grep -Fxq ready /tmp/exam/ch03_05_second.txt
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
  rm -rf /tmp/exam/ch03_05* /tmp/rhcsa_3_05 /var/tmp/rhcsa_3_05.img; rm -f /usr/local/bin/rhcsa_05.sh
}
