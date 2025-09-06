#!/usr/bin/env bash
set -euo pipefail

# Set SCRIPT_DIR to the directory where this script is located
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

log "Installing gaming utility scripts..."

# Create target directory if it doesn't exist
if [ ! -d "/usr/local/bin" ]; then
  log "Creating /usr/local/bin directory..."
  sudo mkdir -p "/usr/local/bin"
fi

# Download and install game-performance script from CachyOS repository
log "Downloading game-performance from CachyOS repository..."
if curl -s "https://raw.githubusercontent.com/CachyOS/CachyOS-Settings/master/usr/bin/game-performance" | sudo tee "/usr/local/bin/game-performance" > /dev/null; then
  sudo chmod +x "/usr/local/bin/game-performance"
  log_success "Downloaded and installed game-performance script."
else
  log_error "Failed to download game-performance script."
fi

# Check if power-profiles-daemon is installed
if ! command -v powerprofilesctl &> /dev/null; then
  log_warn "power-profiles-daemon is not installed, which is required for game-performance."
  log "Installing power-profiles-daemon..."
  pinstall <<EOF
    power-profiles-daemon
EOF
fi

# Test the game-performance script
if command -v powerprofilesctl &> /dev/null; then
  log "Testing game-performance script..."
  if game-performance true &> /dev/null; then
    log_success "game-performance script works correctly."
  else
    log_warn "game-performance script test failed. It may not work properly."
  fi
else
  log_warn "power-profiles-daemon is not installed. game-performance will not work until it's installed."
fi

log_success "Gaming utility scripts setup complete."
