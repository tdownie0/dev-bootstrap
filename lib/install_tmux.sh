#!/usr/bin/env bash
set -euo pipefail

install_tmux() {
  log "Installing tmux..."

  case "$OS" in
    linux)
      sudo apt update
      sudo apt install -y tmux
      ;;
    macos)
      brew install tmux
      ;;
    *)
      error "tmux installation not supported on $OS"
      ;;
  esac

  log "tmux installed"
}

setup_tmux_config() {
  local config_dir="$HOME/.config/tmux"
  mkdir -p "$config_dir"

  backup_if_exists "$config_dir/tmux.conf"
  cp "$SCRIPT_DIR/config/tmux/tmux.conf" "$config_dir/tmux.conf"
  log "Tmux config installed"
}

setup_tmux_plugins() {
  local tmux_plugin_dir="$HOME/.tmux/plugins"
  mkdir -p "$tmux_plugin_dir"

  # tpm (Tmux Plugin Manager)
  if [[ ! -d "$tmux_plugin_dir/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm "$tmux_plugin_dir/tpm"
    log "Installed tpm"
  else
    log "tpm already installed"
  fi

  # Other plugins
  declare -A plugins=(
    ["catppuccin"]="https://github.com/catppuccin/tmux"
    ["tmux-online-status"]="https://github.com/tmux-plugins/tmux-online-status"
    ["tmux-battery"]="https://github.com/tmux-plugins/tmux-battery"
  )

  for name in "${!plugins[@]}"; do
    local path="$tmux_plugin_dir/$name"
    if [[ ! -d "$path" ]]; then
      git clone "${plugins[$name]}" "$path"
      log "Installed $name plugin"
    else
      log "$name already installed"
    fi
  done

  # Install TPM-managed plugins
  "$tmux_plugin_dir/tpm/bin/install_plugins"
}

install_tmux
setup_tmux_config
setup_tmux_plugins
