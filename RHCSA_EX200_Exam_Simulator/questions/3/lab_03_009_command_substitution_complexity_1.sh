#!/bin/bash
# Chapter 3: Create simple shell scripts
# Objective: loops
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch03_009_command_substitution_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="loops"
QUESTION="Command substitution - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create /usr/local/bin/rhcsa_09.sh that prints hostname=<short-hostname>"
TASK_1_HINT="Use hostname -s in command substitution"
TASK_1_COMMAND_1="printf '#!/bin/bash\\necho hostname=\\\$(hostname -s)\\n' > /usr/local/bin/rhcsa_09.sh; chmod +x /usr/local/bin/rhcsa_09.sh"

TASK_2_QUESTION="Save script output in /tmp/exam/ch03_09_host.txt"
TASK_2_HINT="Run the script with redirection"
TASK_2_COMMAND_1="/usr/local/bin/rhcsa_09.sh > /tmp/exam/ch03_09_host.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch03_09* /tmp/rhcsa_3_09 /var/tmp/rhcsa_3_09.img
}

_check_task_1_live() {
  [[ "$(/usr/local/bin/rhcsa_09.sh)" = "hostname=$(hostname -s)" ]]
}

_check_task_2_live() {
  grep -Fxq "hostname=$(hostname -s)" /tmp/exam/ch03_09_host.txt
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
  rm -rf /tmp/exam/ch03_09* /tmp/rhcsa_3_09 /var/tmp/rhcsa_3_09.img; rm -f /usr/local/bin/rhcsa_09.sh
}
