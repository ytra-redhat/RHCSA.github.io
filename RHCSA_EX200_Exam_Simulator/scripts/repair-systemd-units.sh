#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $EUID -ne 0 ]]; then
  exec sudo bash "$0" "$@"
fi

"${SCRIPT_DIR}/install-systemd-units.sh" --install-only
systemctl enable rhcsa-webui.service
systemctl restart rhcsa-webui.service

# Respect the configured auto-update setting.
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/load_repository.sh"
if [[ "${RHCSA_AUTO_UPDATE:-true}" == "true" ]]; then
  systemctl enable rhcsa-update.timer
  systemctl restart rhcsa-update.timer
else
  systemctl disable --now rhcsa-update.timer >/dev/null 2>&1 || true
fi

printf 'RHCSA systemd units repaired successfully.\n'
systemctl --no-pager --full status rhcsa-webui.service || true
