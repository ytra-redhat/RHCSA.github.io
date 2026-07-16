#!/bin/bash
# RHCSA v10 objective 3.3: Process script inputs such as $1 and $2
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_3_3_process_script_arguments_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Process script arguments"
OBJECTIVE_IDS="3.3"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Process script arguments"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create executable /tmp/exam/v10/3.3/copy-as that requires source and destination arguments and copies the source to the destination."
TASK_1_HINT="Validate that exactly two arguments were supplied."
TASK_1_COMMAND_1="cat > /tmp/exam/v10/3.3/copy-as <<'EOF'
#!/bin/bash
[[ \$# -eq 2 ]] || exit 2
cp -- \"\$1\" \"\$2\"
EOF
chmod +x /tmp/exam/v10/3.3/copy-as"

TASK_2_QUESTION="Make copy-as print Usage: copy-as SOURCE DEST to standard error when the argument count is wrong."
TASK_2_HINT="Write the message before exiting with status 2."
TASK_2_COMMAND_1="sed -i \"2c[[ \\\$# -eq 2 ]] || { echo 'Usage: copy-as SOURCE DEST' >&2; exit 2; }\" /tmp/exam/v10/3.3/copy-as"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/3.3; mkdir -p /tmp/exam/v10/3.3
}

_check_task_1_live() {
  printf data > /tmp/exam/v10/3.3/source; /tmp/exam/v10/3.3/copy-as /tmp/exam/v10/3.3/source /tmp/exam/v10/3.3/dest; cmp -s /tmp/exam/v10/3.3/source /tmp/exam/v10/3.3/dest
}

_check_task_2_live() {
  msg=$(/tmp/exam/v10/3.3/copy-as 2>&1 >/dev/null || true); [[ "$msg" == "Usage: copy-as SOURCE DEST" ]]
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
  rm -rf /tmp/exam/v10/3.3
}
