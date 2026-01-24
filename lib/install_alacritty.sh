install_alacritty() {
  if ! $FORCE_INSTALL && command_exists alacritty; then
    log "Alacritty already installed"
    return
  fi

  if $IS_WSL; then
    log "WSL detected: Skipping Alacritty Linux install (using Windows-native host)"
    return
  fi

  if [[ "$OS" == "macos" ]]; then
    if ! command_exists brew; then
      error "Homebrew not found. Install Homebrew first."
    fi

    if $FORCE_INSTALL; then
        brew reinstall --cask alacritty
    else
        brew install --cask alacritty
    fi

  elif [[ "$OS" == "linux" ]]; then
    if command_exists apt; then
      sudo apt update
      sudo apt install -y --reinstall alacritty
    elif command_exists dnf; then
      sudo dnf install -y alacritty
    else
      error "Unsupported Linux package manager"
    fi
  fi
}


setup_alacritty_config() {
  local config_dir="$HOME/.config/alacritty"
  local target="$config_dir/alacritty.yml"

  mkdir -p "$config_dir"

  if [[ -f "$target" ]]; then
    if $FORCE_INSTALL; then
      log "Force flag detected: Overwriting Alacritty config"
    else
      log "Alacritty config exists, skipping (use -f to overwrite)"
      return
    fi
  fi

  backup_if_exists "$target"
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
