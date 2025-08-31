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
log "Installing selected Flatpak applications..."
# THE FIX: Use '<<-' to allow the closing 'EOF' to be indented.
# This makes the script much more readable.
flatpak install -y --noninteractive <<-EOF
	# --- Gaming Launchers & Tools ---
	com.heroicgameslauncher.hgl
	com.usebottles.bottles
	net.davidotek.pupgui2

	# --- Emulators ---
	org.DolphinEmu.dolphin-emu
	# net.rpcs3.RPCS3
	EOF


log_success "Flatpak step finished."
log_warn "A system reboot may be required for Flatpak applications to appear in your app launcher."
