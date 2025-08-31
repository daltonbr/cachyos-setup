#!/usr/bin/env bash
set -euo pipefail

log "Downloading and running the official CachyOS repository setup tool..."

# Create a temporary directory to keep things clean.
TMP_DIR=$(mktemp -d)
# Ensure the temporary directory is cleaned up when the script exits.
trap 'log "Cleaning up temporary files..."; rm -rf -- "$TMP_DIR"' EXIT

# Download the archive into our temp directory.
curl -L -sS "https://mirror.cachyos.org/cachyos-repo.tar.xz" -o "${TMP_DIR}/cachyos-repo.tar.xz"

log "Extracting setup tool..."
tar -xf "${TMP_DIR}/cachyos-repo.tar.xz" -C "${TMP_DIR}"

# The extracted folder is named 'cachyos-repo'.
# We run the script inside it with sudo. It will auto-detect the best repo.
# We pass '--install' to be explicit, although it's the default.
log "Running cachy-repo script with auto-detection..."
sudo bash "${TMP_DIR}/cachyos-repo/cachyos-repo.sh" --install

log "CachyOS repositories have been configured."
# The trap will automatically handle cleanup now.
