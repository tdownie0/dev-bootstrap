install_fzf() {
  if command_exists fzf; then
    log "fzf already installed"
    return
  fi

  local local_share="$HOME/.local/share"
  local local_bin="$HOME/.local/bin"

  log "Installing fzf"
  git clone --depth 1 https://github.com/junegunn/fzf.git "$local_share/fzf"
  "$local_share/fzf/install" --bin

  mkdir -p "$HOME/$local_bin"

  ln -sf "$local_share/fzf/bin/fzf" "$local_bin/fzf"
  ln -sf "$local_share/fzf/bin/fzf-preview.sh" "$local_bin/fzf-preview.sh"
  ln -sf "$local_share/fzf/bin/fzf-tmux" "$local_bin/fzf-tmux"
  ln -sf "$local_share/fzf/shell/key-bindings.zsh" "$HOME/.fzf.zsh"
}

install_eza() {
  if command_exists eza; then
    log "eza already installed"
    return
  fi

  log "Installing eza from deb.gierens.de"

  # Ensure gpg is installed
  sudo apt update
  sudo apt install -y gpg wget

  # Add keyring
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | \
    sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg

  # Add repo
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | \
    sudo tee /etc/apt/sources.list.d/gierens.list

  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

  # Update and install
  sudo apt update
  sudo apt install -y eza
}

install_curlie() {
  if command_exists curlie; then
    log "curlie already installed"
    return
  fi

  log "Installing curlie"
  curl -sS https://webinstall.dev/curlie | bash
}

install_posting() {
  if command_exists posting; then
    log "posting already installed"
    return
  fi

  log "Installing pipx and posting"
  case "$OS" in
    linux)
      sudo apt update
      sudo apt install -y python3-pip python3-venv pipx
      ;;
    macos)
      brew install pipx
      ;;
  esac
  
  pipx install posting
}

install_cli_packages_linux() {
  log "Installing CLI tools (Linux)"
  sudo apt update
  sudo apt install -y bat btop
}

install_cli_packages_macos() {
  log "Installing CLI tools (macOS)"
  brew install eza bat btop fzf
}

install_cli_tools() {
  case "$OS" in
    linux)
      install_cli_packages_linux
      install_fzf
      install_eza
      install_curlie
      install_posting
      ;;
    macos)
      install_cli_packages_macos
      install_curlie
      install_posting
      ;;
    *)
      error "Unsupported OS for CLI tools"
      ;;
  esac
}

install_cli_tools
