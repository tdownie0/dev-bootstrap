install_zsh() {
  if ! $FORCE_INSTALL && command_exists zsh; then
    log "zsh already installed"
    return
  fi

  if [[ "$OS" == "linux" ]]; then
    if command_exists apt; then
      sudo apt update
      sudo apt install -y --reinstall zsh
    elif command_exists dnf; then
      sudo dnf install -y zsh
    else
      error "Unsupported Linux package manager"
    fi
  elif [[ "$OS" == "macos" ]]; then
    if $FORCE_INSTALL; then brew reinstall zsh; else brew install zsh; fi
  fi

  log "zsh installed"
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    if $FORCE_INSTALL; then
      log "Force flag detected: Removing existing oh-my-zsh"
      rm -rf "$HOME/.oh-my-zsh"
    else
      log "oh-my-zsh already installed"
      return
    fi
  fi

  log "Installing oh-my-zsh (non-interactive)"

  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_zsh_plugins() {
  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  mkdir -p "$custom_dir/plugins"

  # Helper function to handle git-based plugins with force logic
  install_git_plugin() {
    local repo_url="$1"
    local dest_dir="$2"
    if [[ -d "$dest_dir" ]]; then
      if $FORCE_INSTALL; then
        log "Force updating plugin: $(basename "$dest_dir")"
        rm -rf "$dest_dir"
      else
        log "Plugin $(basename "$dest_dir") already exists"
        return
      fi
    fi
    git clone --depth=1 "$repo_url" "$dest_dir"
  }

  install_git_plugin "https://github.com/zsh-users/zsh-autosuggestions" "$custom_dir/plugins/zsh-autosuggestions"
  install_git_plugin "https://github.com/zsh-users/zsh-syntax-highlighting" "$custom_dir/plugins/zsh-syntax-highlighting"
  install_git_plugin "https://github.com/romkatv/powerlevel10k.git" "$HOME/powerlevel10k"

  # Custom Aliases
  local aliases_dir="$custom_dir/plugins/aliases"
  local aliases_file="$aliases_dir/aliases.plugin.zsh"
  mkdir -p "$aliases_dir"

  if $FORCE_INSTALL || [[ ! -f "$aliases_file" ]]; then
    backup_if_exists "$aliases_file"
    cp "$SCRIPT_DIR/config/zsh/plugins/aliases/aliases.plugin.zsh" "$aliases_dir/"
    log "aliases plugin installed/updated"
  fi
}

setup_zshrc() {
  local target="$HOME/.zshrc"
  if [[ -f "$target" ]] && ! $FORCE_INSTALL; then
    log ".zshrc already exists, skipping (use -f to overwrite)"
    return
  fi

  backup_if_exists "$target"
  cp "$SCRIPT_DIR/config/zsh/.zshrc" "$target"
  log ".zshrc installed"
}

maybe_change_shell() {
  local zsh_path
  zsh_path=$(command -v zsh)

  if [[ "$SHELL" != "$zsh_path" ]]; then
    if $FORCE_INSTALL && [[ "$OS" == "linux" ]]; then
        log "Attempting to change shell to zsh automatically..."
        sudo chsh -s "$zsh_path" "$USER"
    else
        warn "zsh is not your default shell. Run: chsh -s $zsh_path"
    fi
  fi
}

install_zsh
install_oh_my_zsh
install_zsh_plugins
setup_zshrc
maybe_change_shell
