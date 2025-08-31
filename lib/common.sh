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
# Reads a list of packages from stdin via a here document (<<EOF).
pinstall() {
  # Capture the cleaned package list from our helper function.
  local packages
  packages=$(_format_packages_from_stdin)

  if [[ -n "${packages}" ]]; then
    log "Installing pacman packages: ${packages}"
    sudo pacman -S --needed --noconfirm ${packages} | cat
  fi
}
export -f pinstall

# Convenience: install AUR packages idempotently.
# Reads a list of packages from stdin via a here document (<<EOF).
yinstall() {
  # Capture the cleaned package list from our helper function.
  local packages
  packages=$(_format_packages_from_stdin)

  if [[ -n "${packages}" ]]; then
    log "Installing AUR packages: ${packages}"
    # Note: We don't pipe AUR helpers to cat, as their build output is often
    # complex and benefits from direct terminal rendering.
    "${AUR_HELPER}" -S --needed --noconfirm ${packages}
  fi
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
