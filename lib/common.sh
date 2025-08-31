#!/usr/bin/env bash
set -euo pipefail

# Minimal logger
log() { printf '[%s] %s\n' "$(date +'%H:%M:%S')" "$*"; }

# Run a step script from steps/
run_step() {
  local name="$1"
  local path="${SCRIPT_DIR}/steps/${name}.sh"
  if [[ -x "${path}" ]]; then
    log "Running ${name}..."
    "${path}"
  else
    log "Skipping ${name} (not found or not executable)."
  fi
}

# Convenience: install repo packages idempotently
pinstall() { sudo pacman -S --needed --noconfirm "$@"; }

# Convenience: install AUR packages idempotently
yinstall() { "${AUR_HELPER}" -S --needed --noconfirm "$@"; }

# require_cmd() {
#   command -v "$1" >/dev/null 2>&1 || {
#     log "Missing required command:'$1'"
#     exit 1
#   }
# }

require_cmd()
{
    if ! command -v "$1" >/dev/null 2>&1; then
        log "Error: Required command '$1' is not available."
        log "This might be because it is not installed or not in your PATH."
        log "Current PATH is: ${PATH}"
        # Add a specific check for running as root
        if [[ "${EUID}" -eq 0 ]]; then
            log "Warning: You are running this script as root (e.g., with 'sudo ./main.sh')."
            log "It is recommended to run as a regular user with sudo privileges instead."
        fi
        exit 1
    fi
}

# Export all the helper functions so they are available to the step scripts,
# which run in their own subshells.
export -f log
export -f run_step
export -f pinstall
export -f yinstall
export -f require_cmd
