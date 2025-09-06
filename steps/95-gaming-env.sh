#!/usr/bin/env bash
set -euo pipefail

log "Setting up gaming environment variables..."

# Path to environment file
ENV_FILE="/etc/environment"

# Create the file if it doesn't exist
if [ ! -f "$ENV_FILE" ]; then
  sudo touch "$ENV_FILE"
fi

log "Adding CachyOS gaming environment variables to $ENV_FILE..."

# Create temporary file with all gaming environment variables
cat << 'EOF' | sudo tee /tmp/gaming-env > /dev/null
#==============================================================================
# CachyOS Gaming Environment Variables
#==============================================================================

# GPU-Specific Shader Cache Settings
#------------------------------------------------------------------------------
# Increase Nvidia's shader cache size to 12GB
#__GL_SHADER_DISK_CACHE_SIZE=12000000000

# Enforce RADV Vulkan implementation for AMD GPUs
#AMD_VULKAN_ICD=RADV

# Increase AMD Mesa shader cache size to 12GB
#MESA_SHADER_CACHE_MAX_SIZE=12G

# Prevent shader cache cleanup on Nvidia
#__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1

# Proton DLSS Settings
#------------------------------------------------------------------------------
# Automatically upgrade DLSS to the latest version
#PROTON_DLSS_UPGRADE=1

# Enable DLSS indicator
#PROTON_DLSS_INDICATOR=1

# Proton FSR Settings
#------------------------------------------------------------------------------
# Automatically upgrade FSR4 to the latest version
#PROTON_FSR4_UPGRADE=1

# Use AMD's RDNA3 compatible FSR4 DLL
#PROTON_FSR4_RDNA3_UPGRADE=1

# Proton HDR/Wayland Support
#------------------------------------------------------------------------------
# Enable native Wayland support (may improve latency, breaks Steam overlay)
#PROTON_ENABLE_WAYLAND=1

# Enable HDR output support (requires Gamescope with --hdr-enabled or Wayland)
#PROTON_ENABLE_HDR=1

# Enable HDR WSI for Nvidia with KWin (required for HDR without Gamescope)
#ENABLE_HDR_WSI=1

# Proton Nvidia Settings
#------------------------------------------------------------------------------
# Enable Nvidia-specific libraries for PhysX, CUDA, etc. (Nvidia GPUs only)
#PROTON_NVIDIA_LIBS=1

# Individual Nvidia library toggles (alternatives to PROTON_NVIDIA_LIBS)
#PROTON_NVIDIA_NVCUDA=1
#PROTON_NVIDIA_NVENC=1
#PROTON_NVIDIA_NVML=1
#PROTON_NVIDIA_NVOPTIX=1

# Disable Nvidia libraries for 32-bit games on RTX 4000+ series
#PROTON_NVIDIA_LIBS_NO_32BIT=1

# Proton Performance and Compatibility
#------------------------------------------------------------------------------
# Enable NTSync (helps with CPU-bound games, experimental)
#PROTON_USE_NTSYNC=1

# Disable per-game shader cache
#PROTON_LOCAL_SHADER_CACHE=0

# Disable window decorations (fixes some borderless fullscreen issues)
#PROTON_NO_WM_DECORATION=1

# Disable Steam Input (fixes Wayland controller issues)
#PROTON_NO_STEAMINPUT=1

# May help with controller detection
#PROTON_PREFER_SDL=1

# Enable media converter (testing only)
#PROTON_ENABLE_MEDIACONV=1

# Automatically upgrade XESS library
#PROTON_XESS_UPGRADE=1

# Wine-specific settings
#------------------------------------------------------------------------------
# Set WM_CLASS for window manager rules
#WINE_WMCLASS="value"

# Disable symlinks from Wine user folders to home directory
#WINEUSERSANDBOX=1

# Disable window decorations (similar to Proton setting)
#WINE_NO_WM_DECORATION=1

# Help with controller detection
#WINE_PREFER_SDL_INPUT=1

# Fix for Steam overlay causing stuttering
#LD_PRELOAD=""
EOF

# Check if variables already exist in environment file
if grep -q "CachyOS Gaming Environment Variables" "$ENV_FILE"; then
  log_warn "Gaming environment variables already exist in $ENV_FILE. Skipping..."
else
  # Append to environment file
  log "Adding gaming environment variables to $ENV_FILE..."
  sudo tee -a "$ENV_FILE" < /tmp/gaming-env > /dev/null
  log_success "Added gaming environment variables to $ENV_FILE"
fi

# Cleanup
sudo rm -f /tmp/gaming-env

log_success "Gaming environment setup complete."
log_warn "To activate these variables, edit $ENV_FILE and uncomment the ones you need."
log_warn "Changes to $ENV_FILE require a logout/login or reboot to take effect."
