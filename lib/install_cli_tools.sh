install_fzf() {
  local fzf_dir="$HOME/.fzf"

  if [[ ! -d "$fzf_dir" ]]; then
    log "Installing fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git "$fzf_dir"
    "$fzf_dir/install" --all
  else
    log "fzf already installed"
  fi
}

install_eza() {
  if ! command -v eza >/dev/null 2>&1; then
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
  else
    log "eza already installed"
  fi
}

install_curlie() {
  if ! command -v curlie >/dev/null 2>&1; then
    log "Installing curlie"
    curl -sS https://webinstall.dev/curlie | bash
  else
    log "curlie already installed"
  fi
}

install_posting() {
  if ! command -v posting >/dev/null 2>&1; then
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

    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.zshrc; then
      echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
      log "Added ~/.local/bin to PATH in .zshrc"
    fi

    pipx install posting
  else
    log "posting already installed"
  fi
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
