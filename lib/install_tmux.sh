#!/usr/bin/env bash
set -euo pipefail


install_tmux() {
  if ! $FORCE_INSTALL && command_exists tmux; then
    log "tmux is already installed: $(tmux -V)"
    return
  fi

  log "Installing/Updating tmux..."

  case "$OS" in
    linux)
      if command_exists apt; then
        sudo apt update
        sudo apt install -y --reinstall tmux
      elif command_exists dnf; then
        sudo dnf reinstall -y tmux
      fi
      ;;
    macos)
      if $FORCE_INSTALL; then brew reinstall tmux; else brew install tmux; fi
      ;;
    *)
      error "tmux installation not supported on $OS"
      ;;
  esac

  log "tmux installed"
}

setup_tmux_config() {
  local config_dir="$HOME/.config/tmux"
  local target="$config_dir/tmux.conf"
  mkdir -p "$config_dir"


  if $FORCE_INSTALL || [[ ! -f "$target" ]]; then
    backup_if_exists "$target"
    cp "$SCRIPT_DIR/config/tmux/tmux.conf" "$target"
    log "Tmux config installed/updated"
  else
    log "Tmux config already exists, skipping"
  fi
}

setup_tmux_plugins() {
  local tmux_plugin_dir="$HOME/.tmux/plugins"

  if $FORCE_INSTALL && [[ -d "$tmux_plugin_dir" ]]; then
    log "Force flag detected: Cleaning tmux plugins"
    rm -rf "$tmux_plugin_dir"
  fi

  mkdir -p "$tmux_plugin_dir"

  if [[ ! -d "$tmux_plugin_dir/tpm" ]]; then
    log "Installing tpm..."
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$tmux_plugin_dir/tpm"
  fi

  declare -A plugins=(
    ["catppuccin"]="https://github.com/catppuccin/tmux"
    ["tmux-online-status"]="https://github.com/tmux-plugins/tmux-online-status"
    ["tmux-battery"]="https://github.com/tmux-plugins/tmux-battery"
  )

  for name in "${!plugins[@]}"; do
    local path="$tmux_plugin_dir/$name"
    if [[ ! -d "$path" ]]; then
      git clone --depth 1 "${plugins[$name]}" "$path"

      log "Installed $name plugin"
    fi
  done

  log "Finishing tmux plugin installation..."
  # We use 'env TMUX=' to trick TPM into thinking we are inside a session if we aren't
  env TMUX="" "$tmux_plugin_dir/tpm/bin/install_plugins"
}

install_tmux
setup_tmux_config
setup_tmux_plugins
