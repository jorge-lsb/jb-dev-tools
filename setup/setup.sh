#!/usr/bin/env bash
# Setup interativo de dev environment: tmux, nvim (LazyVim) e shell (fzf/bat/zoxide/ble.sh/starship).
set -uo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SETUP_DIR/lib/os.sh"
source "$SETUP_DIR/lib/prompt.sh"
source "$SETUP_DIR/lib/report.sh"
source "$SETUP_DIR/modules/tmux.sh"
source "$SETUP_DIR/modules/nvim.sh"
source "$SETUP_DIR/modules/shell.sh"

if [[ "$OS" == "unsupported" ]]; then
  echo "SO não suportado (só macOS e Linux)." >&2
  exit 1
fi

echo "jb-dev-tools setup (SO detectado: $OS)"
echo ""

pkg_update_index

if ask_yes_no "Instalar/configurar tmux (TPM, plugins, tema Catppuccin, binds)?"; then
  setup_tmux "$SETUP_DIR"
fi

if ask_yes_no "Instalar/configurar nvim (LazyVim, build tools, extras)?"; then
  setup_nvim "$SETUP_DIR"
fi

if ask_yes_no "Configurar shell (fzf, bat, ripgrep, fd, zoxide, ble.sh, starship, aliases)?"; then
  setup_shell "$SETUP_DIR"
fi

print_report
