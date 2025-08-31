#!/usr/bin/env bash
set -euo pipefail

require_cmd sudo
require_cmd sed

# TODO: investigate multilib
# Ensure multilib for Steam 32-bit
# if ! grep -q "^\[multilib\]" /etc/pacman.conf ; then
#   log "Enabling multilib..."
#   sudo sed -i '/#\[multilib\]/{N;s/#\[multilib\]\n#Include/\\[multilib\\]\nInclude/}' /etc/pacman.conf
# fi

log "System update..."
sudo pacman -Syu --noconfirm

log "Base toolchain..."
pinstall base-devel git curl wget unzip zip jq
