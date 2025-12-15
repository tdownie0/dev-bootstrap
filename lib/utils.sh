log() {
  echo -e "\033[1;32m[+] $*\033[0m"
}

warn() {
  echo -e "\033[1;33m[!] $*\033[0m"
}

error() {
  echo -e "\033[1;31m[✗] $*\033[0m" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

backup_if_exists() {
  local target="$1"

  if [[ -e "$target" ]]; then
    local ts
    ts="$(date +"%Y%m%d-%H%M%S")"
    local backup="${target}.bak.${ts}"

    log "Backing up existing $target → $backup"
    mv "$target" "$backup"
  fi
}
