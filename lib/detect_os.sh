detect_os() {
  case "$(uname -s)" in
    Linux*)
      OS="linux"
      ;;
    Darwin*)
      OS="macos"
      ;;
    *)
      OS="unknown"
      ;;
  esac
}
