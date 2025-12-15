install_fonts() {
  FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"

  if ! fc-list | grep -qi "FiraCode Nerd Font"; then
    log "Installing FiraCode Nerd Font"
    curl -L -o /tmp/firacode.zip \
      https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip
    unzip -o /tmp/firacode.zip -d "$FONT_DIR"
    fc-cache -f
  else
    log "FiraCode Nerd Font already installed"
  fi
}

install_fonts
