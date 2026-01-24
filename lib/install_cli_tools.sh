install_fzf() {
  if ! $FORCE_INSTALL && command_exists fzf; then
    log "fzf already installed"
    return
  fi

  local local_share="$HOME/.local/share"
  local local_bin="$HOME/.local/bin"

  if $FORCE_INSTALL && [[ -d "$local_share/fzf" ]]; then
    rm -rf "$local_share/fzf"
  fi

  log "Installing fzf"
  git clone --depth 1 https://github.com/junegunn/fzf.git "$local_share/fzf"
  "$local_share/fzf/install" --bin

  mkdir -p "$local_bin"

  ln -sf "$local_share/fzf/bin/fzf" "$local_bin/fzf"
  ln -sf "$local_share/fzf/bin/fzf-preview.sh" "$local_bin/fzf-preview.sh"
  ln -sf "$local_share/fzf/bin/fzf-tmux" "$local_bin/fzf-tmux"
  ln -sf "$local_share/fzf/shell/key-bindings.zsh" "$HOME/.fzf.zsh"
}

install_eza() {
  if ! $FORCE_INSTALL && command_exists eza; then
    log "eza already installed"
    return
  fi

  log "Installing eza from deb.gierens.de"

  # Ensure gpg is installed
  sudo apt update
  sudo apt install -y --reinstall gpg wget

  # Add keyring
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | \
    sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/gierens.gpg

  # Add repo
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | \
    sudo tee /etc/apt/sources.list.d/gierens.list

  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

  # Update and install
  sudo apt update
  sudo apt install -y --reinstall eza
}

install_curlie() {
  if ! $FORCE_INSTALL && command_exists curlie; then
    log "curlie already installed"
    return
  fi

  log "Installing curlie"
  curl -sS https://webinstall.dev/curlie | bash
}

install_posting() {
  if ! $FORCE_INSTALL && command -v posting >/dev/null 2>&1; then
    log "posting already installed"
    return
  fi

  log "Installing Python prerequisites and posting"

  # Ensure local bin is in the path for the current shell session
  [[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"

  case "$OS" in
    linux)
      sudo apt update
      sudo apt install -y software-properties-common python3-pip python3-venv

      if ! command -v python3.12 >/dev/null 2>&1; then
        log "Python 3.12 not found, adding deadsnakes PPA..."

        sudo add-apt-repository -y ppa:deadsnakes/ppa
        sudo apt update
        sudo apt install -y python3.12 python3.12-venv python3.12-dev
      fi
      TARGET_PYTHON="python3.12"
      ;;

    macos)
      log "Ensuring Python 3.12 and pipx via Homebrew"
      brew install python@3.12 pipx
      # Dynamically find the Homebrew Python path (works for Intel and M-series)
      TARGET_PYTHON=$(brew --prefix python@3.12)/bin/python3.12
      ;;
  esac

  log "Installing posting using $TARGET_PYTHON..."

  if $FORCE_INSTALL; then
    pipx uninstall posting >/dev/null 2>&1
    pipx install --python "$TARGET_PYTHON" posting
  else
    pipx install --python "$TARGET_PYTHON" posting || \
    pipx reinstall --python "$TARGET_PYTHON" posting
  fi
}

install_cli_packages_linux() {
  local pkgs=(build-essential bat btop curl git unzip)

  if $FORCE_INSTALL; then
    log "Force reinstalling core CLI tools..."
    sudo apt install -y --reinstall "${pkgs[@]}"
  else
    log "Ensuring core CLI tools are present..."
    sudo apt install -y "${pkgs[@]}"
  fi
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
