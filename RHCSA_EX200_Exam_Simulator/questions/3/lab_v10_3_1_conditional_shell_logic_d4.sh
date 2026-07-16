#!/bin/bash
# RHCSA v10 objective 3.1: Conditionally execute code using if, test, and []
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_3_1_conditional_shell_logic_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Conditional shell logic"
OBJECTIVE_IDS="3.1"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Conditional shell logic"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create executable /tmp/exam/v10/3.1/check-size that prints large when its first argument is greater than 100 and small otherwise."
TASK_1_HINT="Use an if statement with a numeric comparison."
TASK_1_COMMAND_1="cat > /tmp/exam/v10/3.1/check-size <<'EOF'
#!/bin/bash
if [[ \$1 -gt 100 ]]; then echo large; else echo small; fi
EOF
chmod +x /tmp/exam/v10/3.1/check-size"

TASK_2_QUESTION="Make /tmp/exam/v10/3.1/check-size exit with status 2 when no argument is supplied."
TASK_2_HINT="Test the argument count before the numeric comparison."
TASK_2_COMMAND_1="sed -i \"2i[[ \\\$# -eq 1 ]] || exit 2\" /tmp/exam/v10/3.1/check-size"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/3.1; mkdir -p /tmp/exam/v10/3.1
}

_check_task_1_live() {
  [[ "$(/tmp/exam/v10/3.1/check-size 101)" == large && "$(/tmp/exam/v10/3.1/check-size 50)" == small ]]
}

_check_task_2_live() {
  /tmp/exam/v10/3.1/check-size >/dev/null 2>&1; [[ $? -eq 2 ]]
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
  rm -rf /tmp/exam/v10/3.1
}
