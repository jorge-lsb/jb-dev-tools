#!/usr/bin/env bash
# Detecção de SO e wrapper de package manager (brew/apt).

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "mac" ;;
    Linux) echo "linux" ;;
    *) echo "unsupported" ;;
  esac
}

OS="$(detect_os)"

pkg_install() {
  local pkg="$1"
  if [[ "$OS" == "mac" ]]; then
    brew install "$pkg"
  else
    sudo apt-get install -y "$pkg"
  fi
}

pkg_update_index() {
  if [[ "$OS" == "linux" ]]; then
    sudo apt-get update -y
  fi
}

pkg_installed() {
  command -v "$1" >/dev/null 2>&1
}
