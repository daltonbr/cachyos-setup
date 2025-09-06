#!/usr/bin/env bash
set -euo pipefail

# --- Phase 1: Ensure Base Setup ---
log "Ensuring base Flatpak setup..."
if command -v flatpak &>/dev/null && flatpak remotes | grep -q "^flathub\s"; then
  log_success "Flatpak and Flathub are already configured."
else
  log "Installing Flatpak and a graphical front-end..."
  pinstall <<-EOF
    flatpak
    gnome-software
	EOF
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi


# --- Phase 2: Optional Flatpak Installations ---
log "Installing recommended Flatpak applications..."

# We now use a single command broken across multiple lines with backslashes (\).
# This is a more direct and robust method that avoids here-document issues.
# To prevent an application from being installed, simply delete its entire line
# (including the backslash).
flatpak install -y --noninteractive \
  com.heroicgameslauncher.hgl \
  com.usebottles.bottles \
  net.davidotek.pupgui2 \
  org.DolphinEmu.dolphin-emu \
  net.rpcs3.RPCS3

log_success "Flatpak step finished."
log_warn "A system reboot may be required for Flatpak applications to appear in your app launcher."
