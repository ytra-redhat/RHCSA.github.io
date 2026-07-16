#!/bin/bash
# Chapter 3: Create simple shell scripts
# Objective: positional parameters
# Difficulty: 1/5

IS_LAB=true
LAB_ID="ch03_003_positional_parameters_complexity_1"
LAB_VERSION="2026.07.12-v2.0"
DIFFICULTY="1"
OBJECTIVE_TAG="positional parameters"
OBJECTIVE_IDS="3.1,3.3,3.4"
LAB_KIND="drill"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Positional parameters - complexity 1"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create /usr/local/bin/rhcsa_03.sh that prints first=\$1 and second=\$2. Make /usr/local/bin/rhcsa_03.sh executable."
TASK_1_HINT="Use standard-output redirection to the requested path."
TASK_1_COMMAND_1="printf '#!/bin/bash\\necho first=\\\$1\\necho second=\\\$2\\n' > /usr/local/bin/rhcsa_03.sh; chmod +x /usr/local/bin/rhcsa_03.sh"

TASK_2_QUESTION="Write the standard output of \`/usr/local/bin/rhcsa_03.sh alpha beta\` to /tmp/exam/ch03_03_args.txt."
TASK_2_HINT="Use standard-output redirection to the requested path."
TASK_2_COMMAND_1="/usr/local/bin/rhcsa_03.sh alpha beta > /tmp/exam/ch03_03_args.txt"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  mkdir -p /tmp/exam
  rm -rf /tmp/exam/ch03_03* /tmp/rhcsa_3_03 /var/tmp/rhcsa_3_03.img
}

_check_task_1_live() {
  [[ "$(/usr/local/bin/rhcsa_03.sh one two | head -1)" = first=one ]]
}

_check_task_2_live() {
  grep -Fxq second=beta /tmp/exam/ch03_03_args.txt
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
  rm -rf /tmp/exam/ch03_03* /tmp/rhcsa_3_03 /var/tmp/rhcsa_3_03.img; rm -f /usr/local/bin/rhcsa_03.sh
}
