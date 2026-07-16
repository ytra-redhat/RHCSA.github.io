#!/bin/bash
# RHCSA v10 objective 3.2: Use looping constructs to process file or command-line input
# Difficulty: 1/5

IS_LAB=true
LAB_ID="v10_3_2_loop_over_input_d1"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="1"
OBJECTIVE_TAG="Loop over input - practice level 1"
OBJECTIVE_IDS="3.2"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Loop over input - practice level 1"
LAB_TASK_COUNT=1

TASK_1_QUESTION="Create executable /tmp/exam/v10/3.2/make-files that creates one empty file in /tmp/exam/v10/3.2/output for every command-line argument."
TASK_1_HINT="Use a for loop over all positional parameters."
TASK_1_COMMAND_1="cat > /tmp/exam/v10/3.2/make-files <<'EOF'
#!/bin/bash
mkdir -p /tmp/exam/v10/3.2/output
for name in \"\$@\"; do touch \"/tmp/exam/v10/3.2/output/\$name\"; done
EOF
chmod +x /tmp/exam/v10/3.2/make-files"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/3.2; mkdir -p /tmp/exam/v10/3.2
}

_check_task_1_live() {
  rm -rf /tmp/exam/v10/3.2/output; /tmp/exam/v10/3.2/make-files one two; [[ -f /tmp/exam/v10/3.2/output/one && -f /tmp/exam/v10/3.2/output/two ]]
}

check_tasks() {
  TASK_STATUS[0]="false"
  if _is_done 1; then
    TASK_STATUS[0]="true"
  elif _check_task_1_live; then
    TASK_STATUS[0]="true"
    _mark_done 1
  fi
}

cleanup_lab() {
  rm -rf /tmp/exam/v10/3.2
}
