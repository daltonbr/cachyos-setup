#!/usr/bin/env bash
set -euo pipefail

echo "CachyOs setup starting."
echo "The PATH variable is: ${PATH}"

# Load config and shared helpers
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.env"
source "${SCRIPT_DIR}/lib/common.sh"

# --- Single-step runner logic ---
if [[ "$#" -gt 0 ]]; then
  STEP_NAME="$1"
  log "Attempting to run single step: S${STEP_NAME}"
  run_step "${STEP_NAME}"
  log "Single step ${STEP_NAME} finished."
  exit 0
fi
# ---

run_step "00-preflight"
run_step "05-user-config"
run_step "10-optimized-repos"

// TODO: implement all planned steps
#run_step "20-aur-helper"
run_step "30-gpu"
#run_step "40-dev"
#run_step "50-gaming"
#[[ "${INSTALL_FLATPAK}" == "yes" ]] && run_step "60-flatpak" || true
#run_step "70-pacman-core.sh"
#run_step "80-services"

log "All steps completed."
