#!/usr/bin/env bash
# Interactive dev environment setup: tmux, nvim (LazyVim) and shell (fzf/bat/zoxide/ble.sh/starship).
set -uo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SETUP_DIR/lib/os.sh"
source "$SETUP_DIR/lib/report.sh"
source "$SETUP_DIR/lib/prompt.sh"
source "$SETUP_DIR/modules/tmux.sh"
source "$SETUP_DIR/modules/nvim.sh"
source "$SETUP_DIR/modules/shell.sh"

if [[ "$OS" == "unsupported" ]]; then
  echo "Unsupported OS (only macOS and Linux are supported)." >&2
  exit 1
fi

echo "${C_BOLD}jb-dev-tools setup${C_RESET} (detected OS: ${C_CYAN}${OS}${C_RESET})"
echo ""

pkg_update_index

if ask_yes_no "Install/configure tmux (TPM, plugins, keybindings)?"; then
  setup_tmux "$SETUP_DIR"
fi

if ask_yes_no "Install/configure nvim (LazyVim, build tools, language extras)?"; then
  setup_nvim "$SETUP_DIR"
fi

if ask_yes_no "Configure shell (fzf, bat, ripgrep, fd, zoxide, ble.sh, bash-completion, starship, lazygit, aliases)?"; then
  setup_shell "$SETUP_DIR"
fi

print_report
