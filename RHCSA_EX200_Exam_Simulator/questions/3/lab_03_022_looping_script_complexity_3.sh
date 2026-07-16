#!/bin/bash
# Chapter 3: Create simple shell scripts
# Objective: conditionals
# Difficulty: 3/5

IS_LAB=true
LAB_ID="ch03_022_looping_script_complexity_3"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="3"
OBJECTIVE_TAG="conditionals"
QUESTION="Looping script - complexity 3"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create /usr/local/bin/rhcsa_22.sh that prints each argument. Make /usr/local/bin/rhcsa_22.sh executable. The task is complete only when running that exact script produces the behavior and output stated above."
TASK_1_HINT="Suggested command: printf '#!/bin/bash\\nfor item in \\\"\\\$@\\\"; do echo \\\"\\\$item\\\"; done\\n' > /usr/local/bin/rhcsa_22.sh; chmod +x /usr/local/bin/rhcsa_22.sh. Explanation: > overwrites the destination with standard output. printf writes deterministic text, including the requested line breaks."
TASK_1_COMMAND_1="printf '#!/bin/bash\\nfor item in \\\"\\\$@\\\"; do echo \\\"\\\$item\\\"; done\\n' > /usr/local/bin/rhcsa_22.sh; chmod +x /usr/local/bin/rhcsa_22.sh"

TASK_2_QUESTION="Run /usr/local/bin/rhcsa_22.sh red green blue and write the complete standard output to /tmp/exam/ch03_22_colors.txt. Overwrite the destination if it already exists. The task is complete when the destination file exists and contains the requested command output."
TASK_2_HINT="Suggested command: /usr/local/bin/rhcsa_22.sh red green blue > /tmp/exam/ch03_22_colors.txt. Explanation: > overwrites the destination with standard output."
TASK_2_COMMAND_1="/usr/local/bin/rhcsa_22.sh red green blue > /tmp/exam/ch03_22_colors.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch03_22* /tmp/rhcsa_3_22 /var/tmp/rhcsa_3_22.img
}

_check_task_1_live() {
  [[ "$(/usr/local/bin/rhcsa_22.sh one two | wc -l)" = 2 ]]
}

_check_task_2_live() {
  grep -Fxq blue /tmp/exam/ch03_22_colors.txt
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
  rm -rf /tmp/exam/ch03_22* /tmp/rhcsa_3_22 /var/tmp/rhcsa_3_22.img; rm -f /usr/local/bin/rhcsa_22.sh
}
