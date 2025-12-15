#!/usr/bin/env bash
INSTALL_FONTS=true
INSTALL_GUI=true
INSTALL_SHELL=true
INSTALL_MULTIPLEXER=true
INSTALL_NVIM=true
INSTALL_CLI=true

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
