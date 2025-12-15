install_alacritty() {
  if command_exists alacritty; then
    log "Alacritty already installed"
    return
  fi

  if [[ "$OS" == "macos" ]]; then
    if ! command_exists brew; then
      error "Homebrew not found. Install Homebrew first."
    fi
    brew install alacritty

  elif [[ "$OS" == "linux" ]]; then
    if command_exists apt; then
      sudo apt update
      sudo apt install -y alacritty
    elif command_exists dnf; then
      sudo dnf install -y alacritty
    else
      error "Unsupported Linux package manager"
    fi
  fi
}


setup_alacritty_config() {
  local config_dir="$HOME/.config/alacritty"
  mkdir -p "$config_dir"


  backup_if_exists "$config_dir/alacritty.yml"
  cp "$SCRIPT_DIR/config/alacritty/alacritty.yml" \
     "$config_dir/alacritty.yml"

  log "Alacritty config installed"
}

verify_alacritty_installed() {
  if command_exists alacritty; then
    log "Alacritty binary found"
  else
    error "Alacritty not found after installation"
  fi
}

verify_alacritty_runs() {
  if alacritty --version >/dev/null 2>&1; then
    log "Alacritty executes correctly"
  else
    error "Alacritty failed to execute"
  fi
}

install_alacritty
setup_alacritty_config
verify_alacritty_installed
verify_alacritty_runs
