#!/usr/bin/env bash
set -euo pipefail

log "Detecting GPU and checking for drivers..."

# Use lspci to find the VGA/3D controller and grep for the vendor.
# The '|| true' and 'head -n1' make this safe even if no GPU is found.
GPU_VENDOR=$(lspci -k | grep -A 2 -E "(VGA|3D)" | grep -o 'NVIDIA\|AMD\|Intel' || true | head -n1)

case "${GPU_VENDOR}" in
  NVIDIA)
    log "NVIDIA GPU detected."
    # Check if the main driver package is already installed.
    if pacman -Q nvidia-dkms &>/dev/null; then
      log_success "NVIDIA drivers (nvidia-dkms) are already installed."
      exit 0
    fi

    log "Installing NVIDIA drivers..."
    # nvidia-dkms is generally preferred as it survives kernel updates.
    pinstall nvidia-dkms nvidia-utils lib32-nvidia-utils
    log_success "NVIDIA drivers installed."
    ;;

  AMD)
    log "AMD GPU detected."
    if pacman -Q xf86-video-amdgpu &>/dev/null; then
      log_success "AMD drivers (xf86-video-amdgpu) are already installed."
      exit 0
    fi

    log "Installing open-source AMD drivers..."
    pinstall xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon libva-mesa-driver mesa-vdpau
    log_success "AMD drivers installed."
    ;;

  Intel)
    log "Intel integrated graphics detected."
    if pacman -Q xf86-video-intel &>/dev/null; then
      log_success "Intel drivers (xf86-video-intel) are already installed."
      exit 0
    fi

    log "Installing open-source Intel drivers..."
    pinstall xf86-video-intel vulkan-intel lib32-vulkan-intel
    log_success "Intel drivers installed."
    ;;

  *)
    log_warn "Could not detect a primary NVIDIA, AMD, or Intel GPU."
    log_warn "You may need to install video drivers manually."
    ;;
esac
