#!/bin/bash
# RHCSA v10 objective 3.4: Process output of shell commands within a script
# Difficulty: 4/5

IS_LAB=true
LAB_ID="v10_3_4_use_command_output_in_a_script_d4"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="4"
OBJECTIVE_TAG="Use command output in a script"
OBJECTIVE_IDS="3.4"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Use command output in a script"
LAB_TASK_COUNT=2

TASK_1_QUESTION="Create executable /tmp/exam/v10/3.4/report that writes the current hostname and kernel release on one line."
TASK_1_HINT="Capture each command result before formatting the line."
TASK_1_COMMAND_1="cat > /tmp/exam/v10/3.4/report <<'EOF'
#!/bin/bash
host=\$(hostname)
kernel=\$(uname -r)
printf \"%s %s\\n\" \"\$host\" \"\$kernel\"
EOF
chmod +x /tmp/exam/v10/3.4/report"

TASK_2_QUESTION="Make report exit with status 1 when hostname returns an empty value."
TASK_2_HINT="Test the captured variable before printing."
TASK_2_COMMAND_1="sed -i \"/kernel=/i[[ -n \\\"\\\$host\\\" ]] || exit 1\" /tmp/exam/v10/3.4/report"

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/3.4; mkdir -p /tmp/exam/v10/3.4
}

_check_task_1_live() {
  [[ "$(/tmp/exam/v10/3.4/report)" == "$(hostname) $(uname -r)" ]]
}

_check_task_2_live() {
  bash -n /tmp/exam/v10/3.4/report && /tmp/exam/v10/3.4/report >/dev/null
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
  rm -rf /tmp/exam/v10/3.4
}
