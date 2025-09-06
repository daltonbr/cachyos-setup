#!/usr/bin/env bash
set -euo pipefail

log "Installing gaming tools and compatibility layers..."

# The 'multilib' repository, which provides 32-bit libraries, was enabled
# in the 00-preflight.sh step. This is essential for Steam and many games.

log "Installing CachyOS gaming meta packages..."
pinstall <<EOF
  # --- CachyOS Gaming Meta Packages ---
  cachyos-gaming-meta        # Meta package that includes core gaming components
  cachyos-gaming-applications # Additional gaming applications
EOF

log "Installing additional gaming packages from official repositories..."
pinstall <<EOF
  # --- Core Components ---
  discord         # The most common voice and text chat application for gaming.
  proton-cachyos  # CachyOS optimized Proton with additional patches
  proton-cachyos-slr # CachyOS Proton with Steam Linux Runtime (for Anti-Cheat games)

  # Use wine-cachyos-opt instead of wine-cachyos to avoid conflicts
  # wine-cachyos-opt is installed alongside regular wine without conflicts
  wine-cachyos-opt # CachyOS optimized Wine (optional install without conflicts)

  # --- Performance & Utilities ---
  game-performance # Script to temporarily switch to performance power profile
  dlss-swapper    # Script to use the latest DLSS preset for compatible games
  umu-launcher    # Allows protonfixes to work with corresponding GAMEID

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
  protontricks      # A wrapper for 'winetricks' to easily apply tweaks to specific Steam games.
  protonup-qt       # A tool to install and manage custom Proton builds
EOF

log "Configuring system for gaming optimizations..."

# Create directory for environment settings if it doesn't exist
if [ ! -f "/etc/environment" ]; then
  sudo touch /etc/environment
fi

# Increase shader cache size
if grep -q "GL_SHADER_DISK_CACHE_SIZE" /etc/environment; then
  log "Shader cache size already configured."
else
  log "Setting increased shader cache size..."
  # Check GPU vendor and set appropriate environment variables
  if lspci | grep -i nvidia > /dev/null; then
    echo "# Increase Nvidia's shader cache size to 12GB" | sudo tee -a /etc/environment
    echo "__GL_SHADER_DISK_CACHE_SIZE=12000000000" | sudo tee -a /etc/environment
  fi

  if lspci | grep -i amd > /dev/null; then
    echo "# Enforces RADV Vulkan implementation" | sudo tee -a /etc/environment
    echo "AMD_VULKAN_ICD=RADV" | sudo tee -a /etc/environment
    echo "# Increase AMD's shader cache size to 12GB" | sudo tee -a /etc/environment
    echo "MESA_SHADER_CACHE_MAX_SIZE=12G" | sudo tee -a /etc/environment
  fi
fi

log_success "Gaming setup complete."
log_success "CachyOS gaming packages and optimizations installed."

log_warn "Remember these useful environment variables for Steam games:"
log_warn "- For HDR support: PROTON_ENABLE_HDR=1"
log_warn "- For Wayland support: PROTON_ENABLE_WAYLAND=1"
log_warn "- For NVIDIA-specific features: PROTON_NVIDIA_LIBS=1"
log_warn "- For FSR4 support: PROTON_FSR4_UPGRADE=1"
log_warn "- For DLSS support: PROTON_DLSS_UPGRADE=1"
log_warn "- Performance wrapper: game-performance %command%"

# Provide instructions for using wine-cachyos-opt
log_warn ""
log_warn "To use wine-cachyos-opt (instead of system wine):"
log_warn "- Run: /opt/wine-cachyos/bin/wine your_program.exe"
log_warn "- Or with winetricks: WINE=/opt/wine-cachyos/bin/wine WINEPREFIX=/path/to/prefix winetricks verb"
