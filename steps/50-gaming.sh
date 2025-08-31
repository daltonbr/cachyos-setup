#!/usr/bin/env bash
set -euo pipefail

log "Installing gaming tools and compatibility layers..."

# The 'multilib' repository, which provides 32-bit libraries, was enabled
# in the 00-preflight.sh step. This is essential for Steam and many games.

log "Installing core gaming packages from official repositories..."
pinstall <<EOF
  # --- Core Components ---
  steam           # The main PC gaming platform.
  discord         # The most common voice and text chat application for gaming.

  # --- Performance & Overlay ---
  gamemode        # A daemon that applies performance optimizations when a game is running.
  lib32-gamemode  # 32-bit libraries for GameMode, required by 32-bit games.
  mangohud        # An in-game overlay to display FPS, CPU/GPU usage, temperatures, etc.
  lib32-mangohud  # 32-bit libraries for MangoHud.

  # --- Proton/Wine Dependencies ---
  # These packages provide compatibility for video codecs and graphics APIs used by Windows games.
  gst-plugins-base    # GStreamer plugins for media playback.
  gst-plugins-good    # GStreamer plugins for media playback.
  gst-plugins-bad     # GStreamer plugins for media playback (less common formats).
  gst-plugins-ugly    # GStreamer plugins for media playback (formats with potential legal issues).
  vulkan-icd-loader   # The core loader that finds your GPU's Vulkan driver.
  lib32-vulkan-icd-loader # 32-bit version of the Vulkan loader.
EOF

log "Installing additional gaming tools from the AUR..."
yinstall <<EOF
  # --- Core Components & Helpers ---
  game-devices-udev # Provides comprehensive udev rules for a wide range of controllers (Xbox, PS, etc.).
  lutris            # An open-source game launcher that manages Steam, GOG, Epic, emulators, and more.
  protontricks      # A wrapper for 'winetricks' to easily apply tweaks to specific Steam games.
EOF

log_success "Gaming setup complete."
log_warn "For best compatibility, consider also installing a custom Proton version like 'Proton-GE-Custom' using the AUR or a tool like 'protonup-qt'."
