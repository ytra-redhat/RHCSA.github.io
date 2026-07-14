#!/bin/bash
# Chapter 3: Create simple shell scripts
# Objective: idempotency
# Difficulty: 2/5

IS_LAB=true
LAB_ID="ch03_013_positional_parameters_complexity_2"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="2"
OBJECTIVE_TAG="idempotency"
QUESTION="Positional parameters - complexity 2"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create /usr/local/bin/rhcsa_13.sh that prints first=\$1 and second=\$2"
TASK_1_HINT="Use positional parameters"
TASK_1_COMMAND_1="printf '#!/bin/bash\\necho first=\\\$1\\necho second=\\\$2\\n' > /usr/local/bin/rhcsa_13.sh; chmod +x /usr/local/bin/rhcsa_13.sh"

TASK_2_QUESTION="Run /usr/local/bin/rhcsa_13.sh with alpha beta into /tmp/exam/ch03_13_args.txt"
TASK_2_HINT="Use /usr/local/bin/rhcsa_13.sh alpha beta"
TASK_2_COMMAND_1="/usr/local/bin/rhcsa_13.sh alpha beta > /tmp/exam/ch03_13_args.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch03_13* /tmp/rhcsa_3_13 /var/tmp/rhcsa_3_13.img
}

_check_task_1_live() {
  [[ "$(/usr/local/bin/rhcsa_13.sh one two | head -1)" = first=one ]]
}

_check_task_2_live() {
  grep -Fxq second=beta /tmp/exam/ch03_13_args.txt
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
  rm -rf /tmp/exam/ch03_13* /tmp/rhcsa_3_13 /var/tmp/rhcsa_3_13.img; rm -f /usr/local/bin/rhcsa_13.sh
}
