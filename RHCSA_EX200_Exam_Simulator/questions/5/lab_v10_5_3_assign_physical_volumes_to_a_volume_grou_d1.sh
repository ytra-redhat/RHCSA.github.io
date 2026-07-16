#!/bin/bash
# RHCSA v10 objective 5.3: Assign physical volumes to volume groups
# Difficulty: 1/5

IS_LAB=true
LAB_ID="v10_5_3_assign_physical_volumes_to_a_volume_grou_d1"
LAB_VERSION="2026.07.16-v7.0"
DIFFICULTY="1"
OBJECTIVE_TAG="Assign physical volumes to a volume group - practice level 1"
OBJECTIVE_IDS="5.3"
LAB_KIND="exam"
STATE_CHANGING="true"
PERSISTENCE_REQUIRED="false"
QUESTION="Assign physical volumes to a volume group - practice level 1"
LAB_TASK_COUNT=1

TASK_1_QUESTION="Create volume group rhcsa_v10_vg from the device named in /tmp/exam/v10/5.3/device1."
TASK_1_HINT="Initialize the device as a PV before creating the VG."
TASK_1_COMMAND_1="pvcreate -ff -y \"\$(cat /tmp/exam/v10/5.3/device1)\" && vgcreate rhcsa_v10_vg \"\$(cat /tmp/exam/v10/5.3/device1)\""

HINT=$(_build_hint)

_marker_dir() { printf '%s\n' "/tmp/exam/.completed/${LAB_ID}"; }
_task_signature() { printf '%s|%s|%s\n' "$LAB_VERSION" "$LAB_ID" "$1" | sha256sum | awk '{print $1}'; }
_marker_file() { printf '%s/task_%s_%s\n' "$(_marker_dir)" "$1" "$(_task_signature "$1")"; }
_is_done() { [[ -f "$(_marker_file "$1")" ]]; }
_mark_done() { mkdir -p "$(_marker_dir)"; : > "$(_marker_file "$1")"; }

prepare_lab() {
  rm -rf /tmp/exam/v10/5.3; mkdir -p /tmp/exam/v10/5.3; vgremove -ff -y rhcsa_v10_vg >/dev/null 2>&1 || true; for n in 1 2; do truncate -s 128M /tmp/exam/v10/5.3/disk$n.img; losetup --find --show /tmp/exam/v10/5.3/disk$n.img > /tmp/exam/v10/5.3/device$n; done
}

_check_task_1_live() {
  vgs rhcsa_v10_vg >/dev/null 2>&1
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
  vgremove -ff -y rhcsa_v10_vg >/dev/null 2>&1 || true; for f in /tmp/exam/v10/5.3/device?; do dev=$(cat "$f" 2>/dev/null); [[ -n "$dev" ]] && pvremove -ff -y "$dev" >/dev/null 2>&1 || true; [[ -n "$dev" ]] && losetup -d "$dev" >/dev/null 2>&1 || true; done; rm -rf /tmp/exam/v10/5.3
}
