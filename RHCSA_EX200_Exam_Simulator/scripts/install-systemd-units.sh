#!/usr/bin/env bash
set -Eeuo pipefail
umask 022

INSTALL_DIR="${RHCSA_INSTALL_DIR:-/usr/local/share/rhcsa}"
SYSTEMD_DIR="${RHCSA_SYSTEMD_DIR:-/etc/systemd/system}"
SKIP_SYSTEMCTL="${RHCSA_SKIP_SYSTEMCTL:-false}"
ENABLE_UNITS=false

for arg in "$@"; do
  case "$arg" in
    --enable) ENABLE_UNITS=true ;;
    --install-only) ENABLE_UNITS=false ;;
    *) echo "Unknown argument: $arg" >&2; exit 2 ;;
  esac
done

install_unit() {
  local source_file="$1"
  local unit_name="$2"
  local destination="${SYSTEMD_DIR}/${unit_name}"

  [[ -f "$source_file" ]] || {
    echo "ERROR: systemd source unit missing: $source_file" >&2
    return 1
  }

  # Earlier installer versions could leave a directory or stale symlink at the
  # destination. Remove any object at the exact unit path before installing.
  rm -rf -- "$destination"
  install -D -m 0644 -- "$source_file" "$destination"

  [[ -f "$destination" && ! -L "$destination" ]] || {
    echo "ERROR: systemd unit was not installed as a regular file: $destination" >&2
    return 1
  }
}

install_unit \
  "${INSTALL_DIR}/webui/rhcsa-webui.service" \
  "rhcsa-webui.service"
install_unit \
  "${INSTALL_DIR}/systemd/rhcsa-update.service" \
  "rhcsa-update.service"
install_unit \
  "${INSTALL_DIR}/systemd/rhcsa-update.timer" \
  "rhcsa-update.timer"

if [[ "$SKIP_SYSTEMCTL" == "true" ]]; then
  printf 'Installed systemd units into %s\n' "$SYSTEMD_DIR"
  exit 0
fi

command -v systemctl >/dev/null 2>&1 || {
  echo "ERROR: systemctl is unavailable." >&2
  exit 1
}

systemctl daemon-reload

for unit in rhcsa-webui.service rhcsa-update.service rhcsa-update.timer; do
  if ! systemctl cat "$unit" >/dev/null 2>&1; then
    echo "ERROR: systemd cannot load installed unit: $unit" >&2
    ls -ld "${SYSTEMD_DIR}/${unit}" >&2 || true
    exit 1
  fi
done

if "$ENABLE_UNITS"; then
  systemctl enable rhcsa-webui.service
  systemctl restart rhcsa-webui.service
  systemctl enable rhcsa-update.timer
  systemctl restart rhcsa-update.timer
fi
