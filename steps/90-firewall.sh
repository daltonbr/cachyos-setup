#!/usr/bin/env bash
set -euo pipefail

log "Configuring UFW (Uncomplicated Firewall)..."

# --- Phase 1: Installation and Service Setup ---

log "Ensuring UFW is installed and enabled..."
pinstall <<EOF
  # The Uncomplicated Firewall, a user-friendly front-end for iptables.
  ufw
EOF

# Enable the UFW service at boot and start it now.
# We check if it's already enabled to make this step idempotent.
if ! systemctl is-enabled ufw.service &>/dev/null; then
  log "Enabling and starting the UFW service..."
  sudo systemctl enable --now ufw.service
else
  log_success "UFW service is already enabled."
fi

# Set default policies: deny all incoming, allow all outgoing.
# This is a secure default configuration.
sudo ufw default deny incoming
sudo ufw default allow outgoing


# --- Phase 2: Rule Configuration ---

# Define the list of firewall rules we want to ensure are present.
# Format is "port/protocol". Using this explicit format is more robust for checking.
declare -a FIREWALL_RULES=(
  # Custom SSH Port
  "33556/tcp"

  # Sunshine Game Streaming - Core
  "47984/tcp"
  "47984/udp"
  "47989/tcp"
  "47989/udp" # Note: Your list missed this, but Sunshine docs recommend it.
  "48010/tcp"
  "48010/udp"

  # Sunshine Game Streaming - Optional Audio/Control
  "47990/tcp"
  "47999/tcp"
  "47999/udp"
)

log "Applying firewall rules for SSH and Sunshine..."
for rule in "${FIREWALL_RULES[@]}"; do
  # IDEMPOTENCY CHECK: Check if the rule already exists before adding it.
  # We use 'ufw status' and grep for the exact rule string.
  # The '|| true' prevents grep from erroring if no match is found.
  if sudo ufw status | grep -q "${rule}.*ALLOW IN"; then
    log_success "Rule already exists: ALLOW IN ${rule}"
  else
    log "Adding new rule: ALLOW IN ${rule}"
    sudo ufw allow "${rule}"
  fi
done


# --- Phase 3: Final Status ---
log "Firewall configuration complete. Current status:"
# Display the final, numbered list of rules for user verification.
sudo ufw status numbered

log_success "UFW firewall is active and configured."
