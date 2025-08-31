#!/usr/bin/env bash
set -euo pipefail

log "Installing core development tools from official repositories..."

# We use a "here document" (<<EOF) to pass a multiline, commented list
# of packages to our pinstall function.
pinstall <<EOF
  # --- CLI Power Tools ---
  bat         # A cat clone with syntax highlighting and Git integration.
  btop        # Modern and beautiful resource monitor.
  eza         # A modern replacement for 'ls'.
  fd          # A simple, fast and user-friendly alternative to 'find'.
  fzf         # A command-line fuzzy finder for searching and opening files.
  lsd         # The next gen 'ls' with lots of pretty colors and icons.
  mc          # Midnight Commander: a classic two-pane file manager.
  ncdu        # NCurses Disk Usage: an excellent, fast disk usage analyzer.
  ripgrep     # An extremely fast text search tool that respects your .gitignore.
  tealdeer    # Simplified and community-driven man pages. alternative: tldr
  tree        # A classic tool to display directory structures as a tree.
  zoxide      # A smarter 'cd' command that learns your habits.

  # --- Version Control ---
  git         # The essential distributed version control system. (Likely already installed).
  git-delta   # A syntax-highlighting pager for git, diff, and grep output.
  git-lfs     # Git extension for versioning large files.
  github-cli  # The official GitHub CLI tool (command is 'gh').
  jj          # A Git-compatible VCS that is simple, fast, and powerful.
  lazygit     # A simple terminal UI for git commands.

  # --- Editors & Multiplexers ---
  neovim      # An extended Vim text editor, focused on extensibility and usability.
  tmux        # A terminal multiplexer to manage multiple terminal sessions.

  # --- Runtimes & Compilers ---
  # base-devel includes gcc, make, etc. (Installed in 00-preflight).
  lua            # A powerful, efficient, lightweight, embeddable scripting language.
  luarocks       # The package manager for Lua modules.
  openssl        # Core library for cryptography (TLS/SSL).
  rbenv          # A simple Ruby version management tool.
  readline       # A library for command-line editing.
  sqlite         # A C-language library that implements a small, fast, self-contained SQL database engine (command is 'sqlite3').
  tcl            # The Tool Command Language.
  tk             # A graphical user interface toolkit, often used with Tcl and Python.
  zlib-ng-compat # faster, modern replacement for `zlib`.

  # --- Networking & Web ---
  curl        # A command-line tool for transferring data with URL syntax. (Likely already installed).
  docker      # A platform for developing, shipping, and running applications in containers.
  wget        # A tool for retrieving files using HTTP, HTTPS, FTP and FTPS. (Likely already installed).
  xh          # A friendly and fast tool for sending HTTP requests (curl replacement).

  # --- Utilities ---
  unzip       # A utility to extract files from a ZIP archive. (Likely already installed).
  xz          # A general-purpose data compression utility.
EOF


log "Installing additional development tools from the AUR..."

# Now we do the same for packages found in the Arch User Repository.
yinstall <<EOF
  # --- CLI Power Tools ---
  curlie      # A modern curl replacement with the ease of use of httpie.
  lf          # A terminal file manager written in Go, with a focus on simplicity.

  # --- Version Control ---
  gitmux      # A tool to display Git status in your tmux status bar.

  # --- Runtimes & Compilers ---
  goreleaser-bin  # A tool to deliver Go projects by automating the build, release, and publish steps. (-bin is faster to install).
  pyenv           # Simple Python version management.
  pyenv-virtualenv # A pyenv plugin to manage virtualenvs.
  uv-bin          # An extremely fast Python package and project manager, written in Rust. (-bin is faster to install).

  # --- Containers & Databases ---
  lazydocker  # A terminal UI for managing Docker and docker-compose.
  pgcli       # A command line interface for PostgreSQL with auto-completion and syntax highlighting.
EOF

log_success "Development tools installation complete."
log_warn "Note: Some tools like 'nodeenv' and 'yaml-language-server' are best installed via language-specific package managers (e.g., 'uv' or 'npm') after this setup."
