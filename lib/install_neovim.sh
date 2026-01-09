#!/usr/bin/env bash
set -euo pipefail

install_neovim() {
  case "$OS" in
    linux)
      log "Installing latest stable Neovim and dependencies (Linux)"

      # Install dependencies
      if command -v apt >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y ripgrep fd-find

        # fd is called fd-find on Debian/Parrot; create fd symlink if missing
        if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
          sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
        fi
      else
        error "Unsupported Linux package manager"
      fi

      # Install latest Neovim (tarball method)
      if ! command -v nvim >/dev/null 2>&1; then
        log "Downloading latest Neovim tarball"
        curl -Lo /tmp/nvim.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
        tar xzvf /tmp/nvim.tar.gz -C /tmp
        sudo mv /tmp/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
        log "Neovim installed successfully"
      else
        log "Neovim already installed: $(nvim --version | head -n1)"
      fi
      ;;
    macos)
      log "Installing Neovim and dependencies (macOS)"
      brew install neovim ripgrep fd
      ;;
    *)
      error "Unsupported OS for Neovim install"
      ;;
  esac
}

install_nvim_config() {
  local src="$SCRIPT_DIR/config/nvim/init.lua"
  local dst="$HOME/.config/nvim/init.lua"

  if [[ -f "$src" ]]; then
    mkdir -p "$(dirname "$dst")"
    backup_if_exists "$dst"
    cp "$src" "$dst"
    log "Installed custom init.lua"
  else
    log "No custom init.lua found, using Kickstart default"
  fi
}

if command_exists nvim; then
  log "neovim is already installed"
  return
fi

install_neovim
install_nvim_config
