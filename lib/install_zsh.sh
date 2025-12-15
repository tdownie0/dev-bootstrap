install_zsh() {
  if command_exists zsh; then
    log "zsh already installed"
    return
  fi

  if [[ "$OS" == "linux" ]]; then
    if command_exists apt; then
      sudo apt update
      sudo apt install -y zsh
    elif command_exists dnf; then
      sudo dnf install -y zsh
    else
      error "Unsupported Linux package manager"
    fi
  elif [[ "$OS" == "macos" ]]; then
    brew install zsh
  fi

  log "zsh installed"
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log "oh-my-zsh already installed"
    return
  fi

  log "Installing oh-my-zsh (non-interactive)"

  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_zsh_plugins() {
  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  mkdir -p "$custom_dir/plugins"

  if [[ ! -d "$custom_dir/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
      "$custom_dir/plugins/zsh-autosuggestions"
  else
    log "zsh-autosuggestions already installed"
  fi

  if [[ ! -d "$custom_dir/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting \
      "$custom_dir/plugins/zsh-syntax-highlighting"
  else
    log "zsh-syntax-highlighting already installed"
  fi

  local p10k_dir="$HOME/powerlevel10k"
  if [[ ! -d "$p10k_dir" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
  else
    log "powerlevel10k already installed"
  fi

  local aliases_dir="$custom_dir/plugins/aliases"
  mkdir -p "$aliases_dir"

  local aliases_file="$aliases_dir/aliases.plugin.zsh"
  backup_if_exists "$aliases_file"

  cp "$SCRIPT_DIR/config/zsh/plugins/aliases/aliases.plugin.zsh" "$aliases_dir/"
  log "aliases plugin installed/updated"
}

setup_zshrc() {
  backup_if_exists "$HOME/.zshrc"
  cp "$SCRIPT_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
  log ".zshrc installed"
}

maybe_change_shell() {
  if [[ "$SHELL" != "$(command -v zsh)" ]]; then
    warn "zsh is installed but not your default shell"
    warn "Run this manually if desired:"
    echo "  chsh -s $(command -v zsh)"
  fi
}

install_zsh
install_oh_my_zsh
install_zsh_plugins
setup_zshrc
maybe_change_shell
