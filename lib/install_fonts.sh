install_fonts() {
  FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"

  if ! fc-list | grep -qi "FiraCode Nerd Font"; then
    log "FiraCode Nerd Font already installed"
    return
  fi

  log "Installing FiraCode Nerd Font"

  local TMP_ZIP="/tmp/firacode.zip"
  curl -L -o "$TMP_ZIP" \
    https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip

  unzip -o "$TMP_ZIP" -d "$FONT_DIR"
  fc-cache -f "$FONT_DIR"  # rebuild font cache
  rm -f "$TMP_ZIP"
}

install_fonts
