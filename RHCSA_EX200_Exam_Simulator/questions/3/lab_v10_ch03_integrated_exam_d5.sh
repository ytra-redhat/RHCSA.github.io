#!/bin/bash
# RHCSA v10 objective 3.1: Conditionally execute code using if, test, and []
# Difficulty: 5/5

IS_LAB=true
LAB_ID="v10_3_1_ch3_integrated_d5"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="5"
OBJECTIVE_TAG="Integrated RHCSA v10 chapter 3 scenario"
OBJECTIVE_IDS="3.1,3.2,3.3,3.4"
LAB_KIND="integrated-exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="mixed"
QUESTION="Integrated RHCSA v10 chapter 3 scenario"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create executable /tmp/exam/v10/integrated3/classify that prints even or odd for each integer argument."
TASK_1_HINT="Use a loop, arithmetic, and a conditional."
TASK_1_COMMAND_1="mkdir -p /tmp/exam/v10/integrated3; cat > /tmp/exam/v10/integrated3/classify <<'EOF'
#!/bin/bash
for n in \"\$@\"; do if (( n % 2 == 0 )); then echo even; else echo odd; fi; done
EOF
chmod +x /tmp/exam/v10/integrated3/classify"

TASK_2_QUESTION="Make classify reject a nonnumeric argument with exit status 2."
TASK_2_HINT="Validate every argument before arithmetic evaluation."
TASK_2_COMMAND_1="sed -i \"/for n/a\\  [[ \\\$n =~ ^[0-9]+\\\$ ]] || exit 2\" /tmp/exam/v10/integrated3/classify"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/integrated3; mkdir -p /tmp/exam/v10/integrated3
}

_check_task_1_live() {
  [[ "$(/tmp/exam/v10/integrated3/classify 2 3)" == $'even\nodd' ]]
}

_check_task_2_live() {
  /tmp/exam/v10/integrated3/classify x >/dev/null 2>&1; [[ $? -eq 2 ]]
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
  rm -rf /tmp/exam/v10/integrated3
}
