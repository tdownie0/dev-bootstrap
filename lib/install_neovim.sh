#!/usr/bin/env bash
set -euo pipefail

install_neovim() {
  if ! $FORCE_INSTALL && command_exists nvim; then
    log "Neovim already installed: $(nvim --version | head -n1)"
    return
  fi

  case "$OS" in
    linux)
      log "Installing/Updating Neovim and dependencies (Linux)"

      if command_exists apt; then
        sudo apt update
        sudo apt install -y --reinstall ripgrep fd-find

        if ! command_exists fd && command_exists fdfind; then
          sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
        fi

      else
        error "Unsupported Linux package manager"
      fi


      log "Downloading latest Neovim tarball"
      log "Downloading and installing Neovim tarball correctly"
      curl -Lo /tmp/nvim.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz

      # Clean up any old manual attempts
      sudo rm -rf /opt/nvim
      sudo rm -f /usr/local/bin/nvim

      sudo mkdir -p /opt/nvim
      sudo tar -xzvf /tmp/nvim.tar.gz --strip-components=1 -C /opt/nvim

      sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
      log "Neovim binary updated successfully"
      ;;

    macos)
      log "Installing/Updating Neovim (macOS)"
      if $FORCE_INSTALL; then
        brew reinstall neovim ripgrep fd
      else
        brew install neovim ripgrep fd
      fi
      ;;
  esac
}

install_nvim_config() {
  local nvim_config_dir="$HOME/.config/nvim"
  local src="$SCRIPT_DIR/config/nvim/init.lua"

  local dst="$nvim_config_dir/init.lua"

  if $FORCE_INSTALL; then
    log "Force flag detected: Clearing Neovim share/state/cache"
    rm -rf "$HOME/.local/share/nvim"
    rm -rf "$HOME/.local/state/nvim"
    rm -rf "$HOME/.cache/nvim"
  fi

  if [[ -f "$src" ]]; then
    mkdir -p "$nvim_config_dir"

    if $FORCE_INSTALL || [[ ! -f "$dst" ]]; then
      backup_if_exists "$dst"
      cp "$src" "$dst"
      log "Installed custom init.lua"
    fi
  else
    log "No custom init.lua found in $src"
  fi
}

install_neovim
install_nvim_config
