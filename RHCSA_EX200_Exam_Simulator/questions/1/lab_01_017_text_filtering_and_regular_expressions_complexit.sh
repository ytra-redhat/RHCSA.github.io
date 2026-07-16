#!/bin/bash
# Chapter 1: Understand and use essential tools
# Objective: permissions
# Difficulty: 2/5

IS_LAB=true
LAB_ID="ch01_017_text_filtering_and_regular_expressions_complexit"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="2"
OBJECTIVE_TAG="permissions"
OBJECTIVE_IDS="1.3,1.10"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Text filtering and regular expressions - complexity 2"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Write the standard output of \`grep '^root:' /etc/passwd\` to /tmp/exam/ch01_17_root.txt."
TASK_1_HINT="Use standard-output redirection to the requested path."
TASK_1_COMMAND_1="grep '^root:' /etc/passwd > /tmp/exam/ch01_17_root.txt"

TASK_2_QUESTION="Write the standard output of \`grep -E ':/(bin/)?bash\$' /etc/passwd\` to /tmp/exam/ch01_17_bash.txt."
TASK_2_HINT="Use standard-output redirection to the requested path."
TASK_2_COMMAND_1="grep -E ':/(bin/)?bash\$' /etc/passwd > /tmp/exam/ch01_17_bash.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch01_17* /tmp/rhcsa_1_17 /var/tmp/rhcsa_1_17.img
}

_check_task_1_live() {
  grep -Eq "^root:" /tmp/exam/ch01_17_root.txt
}

_check_task_2_live() {
  [[ -s /tmp/exam/ch01_17_bash.txt ]]
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
  rm -rf /tmp/exam/ch01_17* /tmp/rhcsa_1_17 /var/tmp/rhcsa_1_17.img
}
