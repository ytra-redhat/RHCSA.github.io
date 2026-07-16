#!/usr/bin/env bash
set -Eeuo pipefail
WEBUI_PORT="${RHCSA_WEBUI_PORT:-8080}"
get_server_ips() {
  ip -4 -o addr show scope global 2>/dev/null | awk '{split($4,a,"/"); print a[1]}' | awk '!seen[$0]++'
}
show_urls() {
  local ip found=false
  echo "Access URLs:"
  echo "  http://127.0.0.1:${WEBUI_PORT}"
  while IFS= read -r ip; do
    [[ -n "$ip" ]] || continue
    echo "  http://${ip}:${WEBUI_PORT}"
    found=true
  done < <(get_server_ips)
  [[ "$found" == true ]] || echo "  No non-loopback IPv4 address detected."
}
require_root() { [[ $EUID -eq 0 ]] || exec sudo -- "$0" "$@"; }
case "${1:-status}" in
  start) require_root "$@"; systemctl enable --now rhcsa-terminal.service rhcsa-webui.service; systemctl --no-pager --full status rhcsa-terminal.service rhcsa-webui.service || true; show_urls ;;
  stop) require_root "$@"; systemctl stop rhcsa-webui.service rhcsa-terminal.service ;;
  restart) require_root "$@"; systemctl restart rhcsa-terminal.service rhcsa-webui.service; systemctl --no-pager --full status rhcsa-terminal.service rhcsa-webui.service || true; show_urls ;;
  status) systemctl --no-pager --full status rhcsa-terminal.service rhcsa-webui.service || true; show_urls ;;
  *) echo "Usage: $0 {start|stop|restart|status}" >&2; exit 2 ;;
esac
