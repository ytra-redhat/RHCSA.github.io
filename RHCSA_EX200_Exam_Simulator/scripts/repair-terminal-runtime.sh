#!/usr/bin/env bash
set -Eeuo pipefail

[[ $EUID -eq 0 ]] || exec sudo -- "$0" "$@"

INSTALL_DIR="${RHCSA_INSTALL_DIR:-/usr/local/share/rhcsa}"
TMUX_BIN="$(command -v tmux 2>/dev/null || true)"
TTYD_BIN="$(command -v ttyd 2>/dev/null || true)"

[[ -n "$TMUX_BIN" ]] || { echo "ERROR: tmux not found" >&2; exit 1; }
[[ -n "$TTYD_BIN" ]] || { echo "ERROR: ttyd not found" >&2; exit 1; }

if command -v rpm >/dev/null 2>&1 && rpm -q tmux >/dev/null 2>&1; then
  rpm --setperms tmux || true
  rpm --setugids tmux || true
fi
command -v restorecon >/dev/null 2>&1 && \
  restorecon -v "$TMUX_BIN" "$TTYD_BIN" "$INSTALL_DIR/scripts/rhcsa-terminal-service" || true

[[ -x "$TMUX_BIN" ]] || { echo "ERROR: tmux is not executable: $TMUX_BIN" >&2; exit 1; }
"$TMUX_BIN" -V

"$INSTALL_DIR/scripts/install-systemd-units.sh" --install-only
systemctl reset-failed rhcsa-terminal.service
systemctl enable rhcsa-terminal.service
systemctl restart rhcsa-terminal.service
systemctl --no-pager --full status rhcsa-terminal.service
