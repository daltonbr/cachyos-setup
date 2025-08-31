#!/usr/bin/env bash
set -euo pipefail

# We export all the helper functions so they are available to the step scripts,
# which run in their own subshells.

# --- Advanced Logger with Colors and Levels ---

# Check if stderr is a terminal. If so, setup colors.
if [[ -t 2 ]]; then
  # Use tput to make colors portable
  BOLD="$(tput bold)"
  BLUE="${BOLD}$(tput setaf 4)"
  GREEN="${BOLD}$(tput setaf 2)"
  YELLOW="${BOLD}$(tput setaf 3)"
  RED="${BOLD}$(tput setaf 1)"
  NC="$(tput sgr0)" # No Color
else
  # If not a terminal, all color variables are empty strings
  BOLD=""
  BLUE=""
  GREEN=""
  YELLOW=""
  RED=""
  NC=""
fi
export BOLD BLUE GREEN YELLOW RED NC

# General log for major steps
log() { printf "${BLUE}==>${NC} ${BOLD}%s${NC}\n" "$*" >&2; }
export -f log

# Success messages
log_success() { printf "${GREEN}✔ %s${NC}\n" "$*" >&2; }
export -f log_success

# Warning messages
log_warn() { printf "${YELLOW}⚠ %s${NC}\n" "$*" >&2; }
export -f log_warn

# Error messages that also exit the script
log_error() {
  printf "${RED}✖ ERROR: %s${NC}\n" "$*" >&2
  exit 1
}
export -f log_error

# Minimal logger
#log() { printf '[%s] %s\n' "$(date +'%H:%M:%S')" "$*"; }
#export -f log

# Run a step script from steps/
run_step() {
  local name="$1"
  local path="${SCRIPT_DIR}/steps/${name}.sh"
  if [[ -x "${path}" ]]; then
    log "Running ${name}..."
    "${path}"
  else
    log "Skipping ${name} (not found or not executable)."
  fi
}
export -f run_step

# --- Package Installation Helpers ---

# Internal helper to process a multiline, commented package list from stdin
# into a clean, space-separated string on stdout. Not meant to be called directly.

# 1. Remove comments, 2. Convert newlines to spaces, 3. Squeeze multiple spaces
# 1.  `sed 's/#.*//'`: This is the core of the comment handling. For each line it receives, it removes the `#` character and everything after it.
# 2.  `tr '\n' ' '`: It translates all newline characters into spaces, turning the multiline list into a single long line.
# 3.  `tr -s ' '`: It "squeezes" multiple spaces into a single space, cleaning up the list.
# 4.  `sed 's/^[ \t]*//;s/[ \t]*$//'`: This removes any leading or trailing whitespace from the final string.
_format_packages_from_stdin() {
  sed 's/#.*//' | tr '\n' ' ' | tr -s ' ' | sed 's/^[ \t]*//;s/[ \t]*$//'
}
export -f _format_packages_from_stdin

# Convenience: install repo packages idempotently.
# We install packages one-by-one to prevent a single
# missing package from halting the entire script.
pinstall() {
  local packages
  packages=$(_format_packages_from_stdin)

  if [[ -z "${packages}" ]]; then
    return 0 # Nothing to do
  fi

  log "Installing pacman packages..."
  # Loop through each package and try to install it individually.
  for pkg in ${packages}; do
    # The '|| true' is a critical part. It ensures that if pacman fails
    # (e.g., package not found), the non-zero exit code is ignored,
    # and the 'set -e' command doesn't stop the whole script.
    # We also capture the output to check for errors.
    if output=$(sudo pacman -S --needed --noconfirm "${pkg}" 2>&1); then
      log_success "Installed or verified: ${pkg}"
    else
      # Check if the error was "target not found" and show a warning.
      if echo "${output}" | grep -q "target not found"; then
        log_warn "Package not found in official repos: ${pkg}"
      else
        # For other errors, show a more serious error message.
        log_error "Failed to install '${pkg}':\n${output}"
      fi
    fi
  done
}
export -f pinstall

# Convenience: install AUR packages idempotently.
# Also installs one-by-one for resilience.
yinstall() {
  local packages
  packages=$(_format_packages_from_stdin)

  if [[ -z "${packages}" ]]; then
    return 0 # Nothing to do
  fi

  log "Installing AUR packages..."
  for pkg in ${packages}; do
    # We don't need the '|| true' here because we are capturing the output
    # and checking the exit code of the 'if' statement directly.
    if "${AUR_HELPER}" -S --needed --noconfirm "${pkg}"; then
      log_success "Installed or verified (AUR): ${pkg}"
    else
      log_warn "Failed to build or install AUR package: ${pkg}. Please check logs for errors."
    fi
  done
}
export -f yinstall

require_cmd()
{
    if ! command -v "$1" >/dev/null 2>&1; then
        log "Error: Required command '$1' is not available."
        log "This might be because it is not installed or not in your PATH."
        log "Current PATH is: ${PATH}"
        # Add a specific check for running as root
        if [[ "${EUID}" -eq 0 ]]; then
            log "Warning: You are running this script as root (e.g., with 'sudo ./main.sh')."
            log "It is recommended to run as a regular user with sudo privileges instead."
        fi
        exit 1
    fi
}
export -f require_cmd
