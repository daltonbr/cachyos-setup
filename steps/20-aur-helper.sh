#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# WHAT IS THE AUR AND WHY DO WE NEED A HELPER?
#
# The Arch User Repository (AUR) is a vast, community-driven repository for
# Arch Linux users. It contains package descriptions (PKGBUILDs) that allow
# you to compile and install software not available in the official repos.
#
# The official package manager, `pacman`, does not interact with the AUR.
# The manual process is:
#   1. Find the package on the AUR website.
#   2. `git clone` its source repository.
#   3. `cd` into the directory.
#   4. Run `makepkg -si` to download sources, compile, and install.
#
# An "AUR Helper" (like yay or paru) automates this entire process for you,
# making installing AUR packages as easy as `yay -S <package>`.
#
# THE CHICKEN-AND-EGG PROBLEM:
# Since AUR helpers are themselves in the AUR, we must install our chosen
# helper one time using the manual `makepkg` process. This script does that.
# -----------------------------------------------------------------------------
set -euo pipefail

log "Checking for AUR helper: ${AUR_HELPER}"

# IDEMPOTENCY CHECK: If the command for our chosen helper already exists, we're done.
if command -v "${AUR_HELPER}" &>/dev/null; then
  log_success "AUR helper '${AUR_HELPER}' is already installed."
  exit 0
fi

log "AUR helper not found. Proceeding with manual installation..."

# Determine the correct Git URL based on the choice in config.env
case "${AUR_HELPER}" in
  yay)
    GIT_URL="https://aur.archlinux.org/yay-bin.git"
    log "Selected 'yay-bin' (pre-compiled version for faster install)."
    ;;
  paru)
    GIT_URL="https://aur.archlinux.org/paru.git"
    log "Selected 'paru'."
    ;;
  *)
    log_error "Unsupported AUR_HELPER: '${AUR_HELPER}'. Please choose 'yay' or 'paru' in config.env."
    ;;
esac

# Create a temporary directory for the build process.
TMP_DIR=$(mktemp -d)
# Ensure the temporary directory is cleaned up when the script exits.
trap 'log "Cleaning up temporary build files..."; rm -rf -- "$TMP_DIR"' EXIT

log "Cloning repository from ${GIT_URL}..."
# We must run the build process as the regular user, not root.
# The user running the main script is the correct one.
git clone "${GIT_URL}" "${TMP_DIR}"

# Change into the build directory.
cd "${TMP_DIR}"

log "Building and installing '${AUR_HELPER}'..."
# makepkg is the official tool to build Arch packages from a PKGBUILD.
# -s: Sync (install) dependencies from official repos using pacman.
# -i: Install the package after a successful build.
# --noconfirm: Automatically answer "yes" to prompts.
#
# SECURITY NOTE: makepkg should NEVER be run with sudo. It will refuse to run.
# It will call sudo internally when it needs to install dependencies or the final package.
makepkg -si --noconfirm

log_success "AUR helper '${AUR_HELPER}' has been successfully installed."
# The 'trap' will now automatically clean up the temporary directory.
