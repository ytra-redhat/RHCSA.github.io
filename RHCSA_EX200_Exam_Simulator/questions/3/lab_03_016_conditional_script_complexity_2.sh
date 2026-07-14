#!/bin/bash
# Chapter 3: Create simple shell scripts
# Objective: loops
# Difficulty: 2/5

IS_LAB=true
LAB_ID="ch03_016_conditional_script_complexity_2"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="2"
OBJECTIVE_TAG="loops"
QUESTION="Conditional script - complexity 2"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create executable /usr/local/bin/rhcsa_16.sh that prints present if /etc/passwd exists"
TASK_1_HINT="Use an if test and chmod +x"
TASK_1_COMMAND_1="printf '#!/bin/bash\\nif [ -f /etc/passwd ]; then echo present; else echo missing; fi\\n' > /usr/local/bin/rhcsa_16.sh; chmod +x /usr/local/bin/rhcsa_16.sh"

TASK_2_QUESTION="Run /usr/local/bin/rhcsa_16.sh and save output in /tmp/exam/ch03_16_run.txt"
TASK_2_HINT="Use /usr/local/bin/rhcsa_16.sh > /tmp/exam/ch03_16_run.txt"
TASK_2_COMMAND_1="/usr/local/bin/rhcsa_16.sh > /tmp/exam/ch03_16_run.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch03_16* /tmp/rhcsa_3_16 /var/tmp/rhcsa_3_16.img
}

_check_task_1_live() {
  [[ -x /usr/local/bin/rhcsa_16.sh ]] && [[ "$(/usr/local/bin/rhcsa_16.sh)" = present ]]
}

_check_task_2_live() {
  grep -Fxq present /tmp/exam/ch03_16_run.txt
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
  rm -rf /tmp/exam/ch03_16* /tmp/rhcsa_3_16 /var/tmp/rhcsa_3_16.img; rm -f /usr/local/bin/rhcsa_16.sh
}
