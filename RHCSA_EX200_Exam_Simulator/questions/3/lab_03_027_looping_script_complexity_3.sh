#!/bin/bash
# Chapter 3: Create simple shell scripts
# Objective: idempotency
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch03_027_looping_script_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="idempotency"
QUESTION="Looping script - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create /usr/local/bin/rhcsa_27.sh that prints each argument"
TASK_1_HINT="Use for item in \"\$@\""
TASK_1_COMMAND_1="printf '#!/bin/bash\\nfor item in \\\"\\\$@\\\"; do echo \\\"\\\$item\\\"; done\\n' > /usr/local/bin/rhcsa_27.sh; chmod +x /usr/local/bin/rhcsa_27.sh"

TASK_2_QUESTION="Run /usr/local/bin/rhcsa_27.sh with red green blue into /tmp/exam/ch03_27_colors.txt"
TASK_2_HINT="Use /usr/local/bin/rhcsa_27.sh red green blue"
TASK_2_COMMAND_1="/usr/local/bin/rhcsa_27.sh red green blue > /tmp/exam/ch03_27_colors.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch03_27* /tmp/rhcsa_3_27 /var/tmp/rhcsa_3_27.img
}

_check_task_1_live() {
  [[ "$(/usr/local/bin/rhcsa_27.sh one two | wc -l)" = 2 ]]
}

_check_task_2_live() {
  grep -Fxq blue /tmp/exam/ch03_27_colors.txt
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
  rm -rf /tmp/exam/ch03_27* /tmp/rhcsa_3_27 /var/tmp/rhcsa_3_27.img; rm -f /usr/local/bin/rhcsa_27.sh
}
