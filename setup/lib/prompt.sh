#!/usr/bin/env bash
# Helper de pergunta sim/não reutilizável.

ask_yes_no() {
  local question="$1"
  local answer
  while true; do
    read -r -p "${C_BOLD}?${C_RESET} ${question} ${C_CYAN}[y/N]${C_RESET} " answer
    case "$answer" in
      [yY]|[yY][eE][sS]) return 0 ;;
      ""|[nN]|[nN][oO]) return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}
