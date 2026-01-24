#!/usr/bin/env bash
INSTALL_FONTS=true
INSTALL_GUI=true
INSTALL_SHELL=true
INSTALL_MULTIPLEXER=true
INSTALL_NVIM=true
INSTALL_CLI=true

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FORCE_INSTALL=false

show_help() {
  cat << EOF
    Usage: $(basename "$0") [OPTIONS]

    Bootstrap your development environment.

    Options:
	-f, --force      Force installation (overwrites existing configs and reinstalls packages)
	-h, --help       Show this help message and exit

    Description:
	This script automates the installation of Fonts, Alacritty, Zsh, Tmux, 
	Neovim, and various CLI tools for both Linux (Ubuntu/Debian) and macOS.
EOF
}

# Parsing arguments
FORCE_INSTALL=false

for arg in "$@"; do
  case $arg in
    -f|--force) FORCE_INSTALL=true ;;
    -h|--help)  show_help; exit 0 ;;
    *)          echo "Unknown option: $arg"; show_help; exit 1 ;;
  esac
done

source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/detect_os.sh"

detect_os
log "Detected OS: $OS"

case "$OS" in
  linux|macos) ;;
  *)
    error "Installation automation not supported on $OS"
    ;;
esac

$INSTALL_FONTS && source "$SCRIPT_DIR/lib/install_fonts.sh" \
  || log "Skipping font installation"

$INSTALL_GUI && source "$SCRIPT_DIR/lib/install_alacritty.sh" \
  || error "Failed to load install_alacritty.sh"

$INSTALL_SHELL && source "$SCRIPT_DIR/lib/install_zsh.sh" \
  || error "Failed to load install_zsh.sh"

$INSTALL_MULTIPLEXER && source "$SCRIPT_DIR/lib/install_tmux.sh" \
  || error "Failed to load install_tmux.sh"

$INSTALL_NVIM && source "$SCRIPT_DIR/lib/install_neovim.sh" \
  || error "Failed to load install_neovim.sh"

$INSTALL_CLI && source "$SCRIPT_DIR/lib/install_cli_tools.sh" \
  || error "Failed to load install_cli_tools.sh"
