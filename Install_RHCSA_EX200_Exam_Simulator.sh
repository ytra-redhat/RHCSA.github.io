#!/usr/bin/env bash
# RHCSA EX200 Exam Simulator installer.
#
# Supported execution methods:
#   sudo ./Install_RHCSA_EX200_Exam_Simulator.sh
#   curl -fsSL https://raw.githubusercontent.com/ytra-redhat/RHCSA.github.io/main/Install_RHCSA_EX200_Exam_Simulator.sh | sudo bash
#
# The bootstrap source is deliberately locked to the user's own fork.
BOOTSTRAP_REPOSITORY="ytra-redhat/RHCSA.github.io"
BOOTSTRAP_BRANCH="main"

# BASH_SOURCE[0] is empty when the script is streamed into `bash`.
# Determine a local script path only when one actually exists.
SCRIPT_PATH=""
SCRIPT_DIR="$PWD"
if [[ -n "${BASH_SOURCE[0]-}" && -f "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_PATH="$(readlink -f -- "${BASH_SOURCE[0]}")"
  SCRIPT_DIR="$(cd -- "$(dirname -- "$SCRIPT_PATH")" && pwd)"
fi

set -Eeuo pipefail
umask 022

INSTALL_DIR="/usr/local/share/rhcsa"
BIN_LINK="/usr/bin/rhcsa"
SERVICE_FILE="/etc/systemd/system/rhcsa-webui.service"
UPDATE_SERVICE_FILE="/etc/systemd/system/rhcsa-update.service"
UPDATE_TIMER_FILE="/etc/systemd/system/rhcsa-update.timer"
FORCE=false
NON_INTERACTIVE=false
AUTO_UPDATE_RUN=false

for arg in "$@"; do
  case "$arg" in
    --force|-f) FORCE=true ;;
    --non-interactive) NON_INTERACTIVE=true ;;
    --auto-update) AUTO_UPDATE_RUN=true; NON_INTERACTIVE=true; FORCE=true ;;
    *) echo "Unknown argument: $arg" >&2; exit 2 ;;
  esac
done

# Bootstrap defaults allow safe streamed execution. A local or installed
# repository.env may override operational settings, but the repository and
# branch are validated below and may never point outside the own fork.
if [[ -z "${RHCSA_GITHUB_REPOSITORY-}" ]]; then
  printf -v RHCSA_GITHUB_REPOSITORY '%s' "$BOOTSTRAP_REPOSITORY"
fi
if [[ -z "${RHCSA_GITHUB_BRANCH-}" ]]; then
  printf -v RHCSA_GITHUB_BRANCH '%s' "$BOOTSTRAP_BRANCH"
fi
: "${RHCSA_AUTO_UPDATE:=true}"

CONFIG_CANDIDATES=(
  "${SCRIPT_DIR}/config/repository.env"
  "${SCRIPT_DIR}/../config/repository.env"
  "${INSTALL_DIR}/config/repository.env"
)
REPOSITORY_CONFIG=""
for candidate in "${CONFIG_CANDIDATES[@]}"; do
  [[ -f "$candidate" ]] || continue
  REPOSITORY_CONFIG="$candidate"
  break
done

if [[ -n "$REPOSITORY_CONFIG" ]]; then
  # shellcheck disable=SC1090
  source "$REPOSITORY_CONFIG"
fi

: "${RHCSA_GITHUB_REPOSITORY:?Missing RHCSA_GITHUB_REPOSITORY}"
: "${RHCSA_GITHUB_BRANCH:?Missing RHCSA_GITHUB_BRANCH}"
: "${RHCSA_AUTO_UPDATE:=true}"

if [[ "$RHCSA_GITHUB_REPOSITORY" != "ytra-redhat/RHCSA.github.io" ]]; then
  echo "ERROR: this release is locked to ytra-redhat/RHCSA.github.io." >&2
  echo "Configured value: $RHCSA_GITHUB_REPOSITORY" >&2
  exit 1
fi
if [[ "$RHCSA_GITHUB_BRANCH" != "main" ]]; then
  echo "ERROR: this release requires branch main." >&2
  exit 1
fi

GITHUB_WEB_URL="https://github.com/${RHCSA_GITHUB_REPOSITORY}"
GITHUB_API_URL="https://api.github.com/repos/${RHCSA_GITHUB_REPOSITORY}"
GITHUB_ARCHIVE_URL="${GITHUB_WEB_URL}/archive/refs/heads/${RHCSA_GITHUB_BRANCH}.tar.gz"
QUESTIONS_API_URL="${GITHUB_API_URL}/contents/RHCSA_EX200_Exam_Simulator/questions?ref=${RHCSA_GITHUB_BRANCH}"
COMMIT_API_URL="${GITHUB_API_URL}/commits/${RHCSA_GITHUB_BRANCH}"

if [[ $EUID -ne 0 ]]; then
  if [[ -n "$SCRIPT_PATH" && -f "$SCRIPT_PATH" ]]; then
    exec sudo --preserve-env=RHCSA_REPOSITORY_CONFIG bash "$SCRIPT_PATH" "$@"
  fi

  # Streamed without sudo: download the same installer only from the locked
  # own fork and execute that local temporary file with sudo.
  BOOTSTRAP_INSTALLER_URL="https://raw.githubusercontent.com/${RHCSA_GITHUB_REPOSITORY}/${RHCSA_GITHUB_BRANCH}/Install_RHCSA_EX200_Exam_Simulator.sh"
  BOOTSTRAP_TMP="$(mktemp /tmp/rhcsa-installer.XXXXXX.sh)"
  trap 'rm -f "$BOOTSTRAP_TMP"' EXIT
  curl --fail --location --silent --show-error     "$BOOTSTRAP_INSTALLER_URL" -o "$BOOTSTRAP_TMP"
  chmod 0755 "$BOOTSTRAP_TMP"
  exec sudo bash "$BOOTSTRAP_TMP" "$@"
fi

RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
CYAN=$'\033[36m'
RESET=$'\033[0m'
BOLD=$'\033[1m'

TMP_DIR="$(mktemp -d /tmp/rhcsa-install.XXXXXX)"
ARCHIVE_FILE="${TMP_DIR}/repository.tar.gz"
EXTRACT_DIR="${TMP_DIR}/extract"
STAGING_DIR="${INSTALL_DIR}.new.$$"
BACKUP_DIR="${INSTALL_DIR}.previous.$$"
PROGRESS_BACKUP="${TMP_DIR}/progress.json"
LEGACY_PROGRESS_BACKUP="${TMP_DIR}/legacy.progress"
SYSTEMD_BACKUP_DIR="${TMP_DIR}/systemd-backup"
INSTALL_ACTIVATED=false
OLD_INSTALL_MOVED=false

restore_previous_systemd_state() {
  local unit path backup enabled active

  for unit in rhcsa-webui.service rhcsa-terminal.service rhcsa-update.service rhcsa-update.timer; do
    path="/etc/systemd/system/${unit}"
    rm -rf -- "$path"
    backup="${SYSTEMD_BACKUP_DIR}/${unit}"
    if [[ -f "$backup" || -L "$backup" ]]; then
      cp -a -- "$backup" "$path"
    fi
  done

  systemctl daemon-reload >/dev/null 2>&1 || true

  for unit in rhcsa-webui.service rhcsa-terminal.service rhcsa-update.timer; do
    enabled="disabled"
    active="inactive"
    [[ -f "${SYSTEMD_BACKUP_DIR}/${unit}.enabled" ]] &&       enabled="$(cat "${SYSTEMD_BACKUP_DIR}/${unit}.enabled")"
    [[ -f "${SYSTEMD_BACKUP_DIR}/${unit}.active" ]] &&       active="$(cat "${SYSTEMD_BACKUP_DIR}/${unit}.active")"

    if [[ "$enabled" == "enabled" ]]; then
      systemctl enable "$unit" >/dev/null 2>&1 || true
    else
      systemctl disable "$unit" >/dev/null 2>&1 || true
    fi
    if [[ "$active" == "active" ]]; then
      systemctl restart "$unit" >/dev/null 2>&1 || true
    fi
  done
}

rollback_activation() {
  systemctl stop rhcsa-webui.service >/dev/null 2>&1 || true
  systemctl stop rhcsa-terminal.service >/dev/null 2>&1 || true
  systemctl stop rhcsa-update.timer >/dev/null 2>&1 || true

  if [[ "$INSTALL_ACTIVATED" == "true" && -d "$INSTALL_DIR" ]]; then
    rm -rf -- "$INSTALL_DIR"
  fi
  if [[ "$OLD_INSTALL_MOVED" == "true" && -d "$BACKUP_DIR" ]]; then
    mv "$BACKUP_DIR" "$INSTALL_DIR" || true
  fi
  restore_previous_systemd_state
}

cleanup() {
  local rc=$?
  trap - EXIT
  if [[ $rc -ne 0 && ( "$INSTALL_ACTIVATED" == "true" || "$OLD_INSTALL_MOVED" == "true" ) ]]; then
    printf '%sRolling back failed activation...%s\n' "$YELLOW" "$RESET" >&2
    rollback_activation || true
  fi
  rm -rf "$TMP_DIR" "$STAGING_DIR" 2>/dev/null || true
  exit "$rc"
}
trap cleanup EXIT

log_step() { printf '%s%s%s\n' "$CYAN" "$1" "$RESET"; }
log_ok() { printf '%s✓ %s%s\n' "$GREEN" "$1" "$RESET"; }
die() { printf '%sERROR: %s%s\n' "$RED" "$1" "$RESET" >&2; exit 1; }

install_packages() {
  local packages=("$@")
  if command -v dnf >/dev/null 2>&1; then
    dnf install -y "${packages[@]}"
  elif command -v yum >/dev/null 2>&1; then
    yum install -y "${packages[@]}"
  else
    die "dnf or yum is required on the RHCSA practice VM."
  fi
}

ensure_dependencies() {
  log_step "Checking installer dependencies..."
  command -v curl >/dev/null 2>&1 || install_packages curl
  command -v python3 >/dev/null 2>&1 || install_packages python3
  command -v tar >/dev/null 2>&1 || install_packages tar
  command -v tmux >/dev/null 2>&1 || install_packages tmux

  if ! command -v ttyd >/dev/null 2>&1; then
    # No download from another GitHub repository is permitted.
    install_packages epel-release >/dev/null 2>&1 || true
    install_packages ttyd >/dev/null 2>&1 || true
  fi
  command -v ttyd >/dev/null 2>&1 || die \
    "ttyd is unavailable from configured RPM repositories. Install ttyd from an approved RPM repository and rerun."
  log_ok "Dependencies available"
}

github_get() {
  local url="$1"
  curl --fail --location --silent --show-error \
    -H 'Accept: application/vnd.github+json' \
    -H 'User-Agent: RHCSA-Exam-Simulator' \
    "$url"
}

discover_remote_chapters() {
  log_step "Discovering chapters from ${RHCSA_GITHUB_REPOSITORY}/${RHCSA_GITHUB_BRANCH}..." >&2
  local response="${TMP_DIR}/questions.json"
  github_get "$QUESTIONS_API_URL" > "$response"
  python3 - "$response" <<'PY'
import json
import sys
from pathlib import Path
data = json.loads(Path(sys.argv[1]).read_text())
chapters = sorted(
    (item["name"] for item in data
     if item.get("type") == "dir" and str(item.get("name", "")).isdigit()),
    key=int,
)
if not chapters:
    raise SystemExit("No numeric question chapters found in configured repository")
print("\n".join(chapters))
PY
}

get_latest_commit() {
  github_get "$COMMIT_API_URL" |
    python3 -c 'import json,sys; print(json.load(sys.stdin).get("sha",""))'
}

download_and_validate() {
  mapfile -t REMOTE_CHAPTERS < <(discover_remote_chapters)
  [[ ${#REMOTE_CHAPTERS[@]} -gt 0 ]] || die "No remote chapters discovered."
  printf '  Remote chapters: %s\n' "${REMOTE_CHAPTERS[*]}"

  LATEST_COMMIT="$(get_latest_commit)"
  [[ "$LATEST_COMMIT" =~ ^[0-9a-fA-F]{40}$ ]] || die "Could not determine latest commit."

  if [[ -f "${INSTALL_DIR}/.version" && "$FORCE" == "false" ]]; then
    local installed
    installed="$(tr -d '[:space:]' < "${INSTALL_DIR}/.version")"
    if [[ "$installed" == "$LATEST_COMMIT" ]]; then
      if "$NON_INTERACTIVE"; then
        log_ok "Already up to date (${LATEST_COMMIT:0:7})"
        exit 0
      fi
      read -r -p "Already up to date. Reinstall anyway? [y/N] " reply
      [[ "$reply" =~ ^[Yy]$ ]] || exit 0
    fi
  fi

  log_step "Downloading complete main branch archive from ${RHCSA_GITHUB_REPOSITORY}..."
  curl --fail --location --silent --show-error "$GITHUB_ARCHIVE_URL" -o "$ARCHIVE_FILE"
  mkdir -p "$EXTRACT_DIR"
  tar -xzf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

  SOURCE_REPOSITORY="$(
    find "$EXTRACT_DIR" -mindepth 1 -maxdepth 1 -type d -print -quit
  )"
  [[ -n "$SOURCE_REPOSITORY" ]] || die "Downloaded archive has no repository root."
  SOURCE_SIMULATOR="${SOURCE_REPOSITORY}/RHCSA_EX200_Exam_Simulator"
  SOURCE_CONFIG="${SOURCE_REPOSITORY}/config/repository.env"
  SOURCE_INSTALLER="${SOURCE_REPOSITORY}/Install_RHCSA_EX200_Exam_Simulator.sh"
  [[ -d "$SOURCE_SIMULATOR" ]] || die "Simulator directory missing in downloaded archive."
  [[ -f "$SOURCE_CONFIG" ]] || die "Central repository config missing in downloaded archive."
  [[ -f "$SOURCE_INSTALLER" ]] || die "Installer missing in downloaded archive."

  mapfile -t LOCAL_CHAPTERS < <(
    find "${SOURCE_SIMULATOR}/questions" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' |
      awk '/^[0-9]+$/' |
      sort -n
  )
  [[ "${REMOTE_CHAPTERS[*]}" == "${LOCAL_CHAPTERS[*]}" ]] || die \
    "Remote chapter discovery and downloaded archive differ."

  for chapter in "${LOCAL_CHAPTERS[@]}"; do
    find "${SOURCE_SIMULATOR}/questions/${chapter}" -maxdepth 1 \
      -type f -name 'lab_*.sh' -print -quit | grep -q . ||
      die "Chapter ${chapter} contains no active lab_*.sh files."
  done

  log_step "Running complete release validation..."
  if ! python3 "${SOURCE_SIMULATOR}/scripts/validate_release.py" "$SOURCE_REPOSITORY" \
      > "${TMP_DIR}/validation.json"; then
    printf '\nRelease validation failed:\n' >&2
    cat "${TMP_DIR}/validation.json" >&2
    die "Downloaded release did not pass validation."
  fi
  log_ok "Release validation passed"

  SOURCE_REPOSITORY="$SOURCE_REPOSITORY"
  SOURCE_SIMULATOR="$SOURCE_SIMULATOR"
  SOURCE_CONFIG="$SOURCE_CONFIG"
  SOURCE_INSTALLER="$SOURCE_INSTALLER"
}

preserve_state() {
  if [[ -f "${INSTALL_DIR}/progress.json" ]]; then
    cp -a "${INSTALL_DIR}/progress.json" "$PROGRESS_BACKUP"
  fi
  if [[ -f "${INSTALL_DIR}/.progress" ]]; then
    cp -a "${INSTALL_DIR}/.progress" "$LEGACY_PROGRESS_BACKUP"
  fi
  return 0
}

backup_systemd_state() {
  local unit path
  mkdir -p "$SYSTEMD_BACKUP_DIR"

  for unit in rhcsa-webui.service rhcsa-terminal.service rhcsa-update.service rhcsa-update.timer; do
    path="/etc/systemd/system/${unit}"
    if [[ -f "$path" || -L "$path" ]]; then
      cp -a -- "$path" "${SYSTEMD_BACKUP_DIR}/${unit}"
    fi
  done

  for unit in rhcsa-webui.service rhcsa-terminal.service rhcsa-update.timer; do
    systemctl is-enabled "$unit" 2>/dev/null       > "${SYSTEMD_BACKUP_DIR}/${unit}.enabled" ||       printf 'disabled\n' > "${SYSTEMD_BACKUP_DIR}/${unit}.enabled"
    systemctl is-active "$unit" 2>/dev/null       > "${SYSTEMD_BACKUP_DIR}/${unit}.active" ||       printf 'inactive\n' > "${SYSTEMD_BACKUP_DIR}/${unit}.active"
  done
}

stage_installation() {
  log_step "Staging validated installation..."
  rm -rf "$STAGING_DIR"
  mkdir -p "$STAGING_DIR"
  cp -a "${SOURCE_SIMULATOR}/." "$STAGING_DIR/"
  mkdir -p "${STAGING_DIR}/config" "${STAGING_DIR}/installer"
  cp -a "$SOURCE_CONFIG" "${STAGING_DIR}/config/repository.env"
  cp -a "$SOURCE_INSTALLER" "${STAGING_DIR}/installer/Install_RHCSA_EX200_Exam_Simulator.sh"
  printf '%s\n' "$LATEST_COMMIT" > "${STAGING_DIR}/.version"

  if [[ -f "$PROGRESS_BACKUP" ]]; then
    cp -a "$PROGRESS_BACKUP" "${STAGING_DIR}/progress.json"
  fi
  if [[ -f "$LEGACY_PROGRESS_BACKUP" ]]; then
    cp -a "$LEGACY_PROGRESS_BACKUP" "${STAGING_DIR}/.progress"
  fi

  find "$STAGING_DIR" -type f -name '*.sh' -exec sed -i 's/\r$//' {} +
  sed -i 's/\r$//' "${STAGING_DIR}/rhcsa"
  chmod 0755 "${STAGING_DIR}/rhcsa"
  chmod 0755 "${STAGING_DIR}/installer/Install_RHCSA_EX200_Exam_Simulator.sh"
  find "${STAGING_DIR}/scripts" -maxdepth 1 -type f -exec chmod 0755 {} +
  find "${STAGING_DIR}/webui" -maxdepth 1 -type f -name '*.sh' -exec chmod 0755 {} +
  find "${STAGING_DIR}/questions" -type f -name 'lab_*.sh' -exec chmod 0755 {} +

  python3 "${STAGING_DIR}/scripts/progressctl.py" migrate \
    --legacy "${STAGING_DIR}/.progress" >/dev/null
  log_ok "Staging complete"
}

activate_installation() {
  log_step "Activating installation..."
  backup_systemd_state
  systemctl stop rhcsa-webui.service >/dev/null 2>&1 || true
  systemctl stop rhcsa-terminal.service >/dev/null 2>&1 || true
  systemctl stop rhcsa-update.timer >/dev/null 2>&1 || true

  rm -rf "$BACKUP_DIR"
  if [[ -d "$INSTALL_DIR" ]]; then
    mv "$INSTALL_DIR" "$BACKUP_DIR"
    OLD_INSTALL_MOVED=true
  fi
  mv "$STAGING_DIR" "$INSTALL_DIR"
  INSTALL_ACTIVATED=true

  ln -sfn "${INSTALL_DIR}/rhcsa" "$BIN_LINK"
  ln -sfn "${INSTALL_DIR}/scripts/rhcsa-diagnostics" /usr/bin/rhcsa-status

  # Install systemd units as regular files. The helper explicitly removes stale
  # files, symlinks and directories left by earlier installer versions.
  "${INSTALL_DIR}/scripts/install-systemd-units.sh" --install-only

  systemctl enable rhcsa-terminal.service rhcsa-webui.service
  if ! systemctl restart rhcsa-terminal.service; then
    systemctl --no-pager --full status rhcsa-terminal.service >&2 || true
    journalctl -u rhcsa-terminal.service -n 80 --no-pager >&2 || true
    die "rhcsa-terminal.service could not be started."
  fi
  if ! systemctl restart rhcsa-webui.service; then
    systemctl --no-pager --full status rhcsa-webui.service >&2 || true
    journalctl -u rhcsa-webui.service -n 80 --no-pager >&2 || true
    die "rhcsa-webui.service could not be started."
  fi
  wait_for_runtime

  if [[ "$RHCSA_AUTO_UPDATE" == "true" ]]; then
    systemctl enable rhcsa-update.timer
    systemctl restart rhcsa-update.timer
  else
    systemctl disable --now rhcsa-update.timer >/dev/null 2>&1 || true
  fi

  rm -rf "$BACKUP_DIR" "$SYSTEMD_BACKUP_DIR"
  OLD_INSTALL_MOVED=false
  INSTALL_ACTIVATED=false
  log_ok "Installation activated"
}


get_server_ips() {
  ip -4 -o addr show scope global 2>/dev/null | awk '{split($4,a,"/"); print a[1]}' | awk '!seen[$0]++'
}
show_access_urls() {
  local ip found=false
  printf 'Local Web UI: http://127.0.0.1:8080\n'
  while IFS= read -r ip; do
    [[ -n "$ip" ]] || continue
    printf 'Web UI:       http://%s:8080\n' "$ip"
    found=true
  done < <(get_server_ips)
  [[ "$found" == true ]] || printf 'Web UI: no non-loopback IPv4 address detected; check `ip -4 addr`.\n'
}
wait_for_runtime() {
  local attempt objectives actual_chapters
  for attempt in $(seq 1 30); do
    if systemctl is-active --quiet rhcsa-webui.service &&
       systemctl is-active --quiet rhcsa-terminal.service &&
       tmux has-session -t rhcsa-terminal 2>/dev/null &&
       objectives="$(curl -fsS --max-time 2 http://127.0.0.1:8080/api/objectives 2>/dev/null)" &&
       actual_chapters="$(python3 -c 'import json,sys; print(" ".join(str(x["id"]) for x in json.load(sys.stdin)))' <<<"$objectives" 2>/dev/null)" &&
       [[ "$actual_chapters" == "${LOCAL_CHAPTERS[*]}" ]] &&
       ss -ltn 2>/dev/null | grep -q ':7682[[:space:]]'; then
      log_ok "Web UI, all ${#LOCAL_CHAPTERS[@]} chapters and terminal are reachable"
      return 0
    fi
    sleep 1
  done
  systemctl --no-pager --full status rhcsa-webui.service rhcsa-terminal.service >&2 || true
  journalctl -u rhcsa-webui.service -u rhcsa-terminal.service -n 120 --no-pager >&2 || true
  ss -ltnp >&2 || true
  die "Runtime health check failed; Web UI or terminal is not reachable."
}

configure_host() {
  local web_port=8080 terminal_port=7682
  if command -v firewall-cmd >/dev/null 2>&1 &&
     systemctl is-active --quiet firewalld; then
    firewall-cmd --permanent --add-port="${web_port}/tcp" >/dev/null
    firewall-cmd --permanent --add-port="${terminal_port}/tcp" >/dev/null
    firewall-cmd --reload >/dev/null
  fi
  if ! command -v semanage >/dev/null 2>&1; then
    install_packages policycoreutils-python-utils >/dev/null 2>&1 || true
  fi
  if command -v semanage >/dev/null 2>&1; then
    semanage port -a -t http_port_t -p tcp "$web_port" 2>/dev/null ||
      semanage port -m -t http_port_t -p tcp "$web_port" 2>/dev/null || true
    semanage port -a -t http_port_t -p tcp "$terminal_port" 2>/dev/null ||
      semanage port -m -t http_port_t -p tcp "$terminal_port" 2>/dev/null || true
  fi
}

main() {
  printf '\n%s%sRHCSA EX200 Exam Simulator installer%s\n\n' "$YELLOW" "$BOLD" "$RESET"
  printf 'Repository: %s\nBranch: %s\n\n' "$RHCSA_GITHUB_REPOSITORY" "$RHCSA_GITHUB_BRANCH"
  ensure_dependencies
  download_and_validate
  preserve_state
  stage_installation
  configure_host
  activate_installation

  printf '\n%sInstallation complete%s\n' "$GREEN" "$RESET"
  printf 'Installed commit: %s\n' "${LATEST_COMMIT:0:7}"
  printf 'Chapters installed: %s\n' "${LOCAL_CHAPTERS[*]}"
  printf 'CLI: rhcsa\nDiagnostics: rhcsa-status\n'
  show_access_urls
}

main "$@"
