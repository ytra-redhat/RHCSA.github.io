#!/usr/bin/env bash
set -euo pipefail

_loader_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_simulator_root="$(cd "${_loader_dir}/.." && pwd)"

_config_candidates=(
  "${RHCSA_REPOSITORY_CONFIG:-}"
  "${_simulator_root}/config/repository.env"
  "${_simulator_root}/../config/repository.env"
  "/usr/local/share/rhcsa/config/repository.env"
)

_repository_config=""
for candidate in "${_config_candidates[@]}"; do
  [[ -n "$candidate" && -f "$candidate" ]] || continue
  _repository_config="$candidate"
  break
done

if [[ -z "$_repository_config" ]]; then
  echo "ERROR: repository configuration not found." >&2
  echo "Expected config/repository.env in the repository or installed simulator." >&2
  return 1 2>/dev/null || exit 1
fi

# shellcheck disable=SC1090
source "$_repository_config"

: "${RHCSA_GITHUB_REPOSITORY:?Missing RHCSA_GITHUB_REPOSITORY}"
: "${RHCSA_GITHUB_BRANCH:?Missing RHCSA_GITHUB_BRANCH}"
: "${RHCSA_AUTO_UPDATE:=true}"

if [[ ! "$RHCSA_GITHUB_REPOSITORY" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
  echo "ERROR: invalid RHCSA_GITHUB_REPOSITORY: $RHCSA_GITHUB_REPOSITORY" >&2
  return 1 2>/dev/null || exit 1
fi

RHCSA_GITHUB_WEB_URL="https://github.com/${RHCSA_GITHUB_REPOSITORY}"
RHCSA_GITHUB_GIT_URL="${RHCSA_GITHUB_WEB_URL}.git"
RHCSA_GITHUB_RAW_URL="https://raw.githubusercontent.com/${RHCSA_GITHUB_REPOSITORY}/${RHCSA_GITHUB_BRANCH}"
RHCSA_GITHUB_API_URL="https://api.github.com/repos/${RHCSA_GITHUB_REPOSITORY}"
RHCSA_GITHUB_ARCHIVE_URL="${RHCSA_GITHUB_WEB_URL}/archive/refs/heads/${RHCSA_GITHUB_BRANCH}.tar.gz"
RHCSA_INSTALLER_URL="${RHCSA_GITHUB_RAW_URL}/Install_RHCSA_EX200_Exam_Simulator.sh"

export RHCSA_GITHUB_REPOSITORY RHCSA_GITHUB_BRANCH RHCSA_AUTO_UPDATE
export RHCSA_GITHUB_WEB_URL RHCSA_GITHUB_GIT_URL RHCSA_GITHUB_RAW_URL
export RHCSA_GITHUB_API_URL RHCSA_GITHUB_ARCHIVE_URL RHCSA_INSTALLER_URL
