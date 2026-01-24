detect_os() {
  case "$(uname -s)" in
    Linux*)
      OS="linux"
      # Detect if this specific Linux is actually WSL
      if grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; then
        IS_WSL=true
      else
        IS_WSL=false
      fi
      ;;
    Darwin*)
      OS="macos"
      ;;
    *)
      OS="unknown"
      ;;
  esac
}
