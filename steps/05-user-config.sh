#!/usr/bin/env bash
set -euo pipefail

# This script is called by main.sh, which has already sourced common.sh

log "Checking Git user configuration..."

# Check if git user.name is already set.
# 'git config --get' exits with 1 if the value is not found.
# We use '|| true' to prevent 'set -e' from exiting the script if the config is missing.
# The output of the command is captured. If it's empty, the config is not set.
CURRENT_NAME=$(git config --global --get user.name || true)
CURRENT_EMAIL=$(git config --global --get user.email || true)

if [[ -z "${CURRENT_NAME}" ]]; then
  log "Git user.name is not set."
  read -rp "Enter your full name for Git commits: " GIT_USER_NAME
  if [[ -n "${GIT_USER_NAME}" ]]; then
    git config --global user.name "${GIT_USER_NAME}"
    log "Git user.name has been set to '${GIT_USER_NAME}'."
  fi
else
  log "Git user.name is already set: ${CURRENT_NAME}"
fi

if [[ -z "${CURRENT_EMAIL}" ]]; then
  log "Git user.email is not set."
  read -rp "Enter your email for Git commits: " GIT_USER_EMAIL
  if [[ -n "${GIT_USER_EMAIL}" ]]; then
    git config --global user.email "${GIT_USER_EMAIL}"
    log "Git user.email has been set to '${GIT_USER_EMAIL}'."
  fi
else
  log "Git user.email is already set: ${CURRENT_EMAIL}"
fi
