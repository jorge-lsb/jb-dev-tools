#!/usr/bin/env bash
# Instala tmux + TPM + plugins e escreve ~/.tmux.conf.

setup_tmux() {
  local repo_dir="$1"

  if pkg_installed tmux; then
    report_already_installed "tmux"
  else
    if run_step "instalar tmux" pkg_install tmux; then
      report_installed "tmux"
    else
      return
    fi
  fi

  if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
    report_already_installed "TPM (tmux plugin manager)"
  else
    if run_step "clonar TPM" git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"; then
      report_installed "TPM (tmux plugin manager)"
    else
      return
    fi
  fi

  local target="$HOME/.tmux.conf"
  if [[ -f "$target" ]]; then
    cp "$target" "$target.bak-$(date +%Y%m%d-%H%M%S)"
    cp "$repo_dir/files/tmux.conf" "$target"
    report_updated "~/.tmux.conf (backup do anterior salvo)"
  else
    cp "$repo_dir/files/tmux.conf" "$target"
    report_installed "~/.tmux.conf"
  fi

  if run_step "instalar plugins do tmux (TPM)" "$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh"; then
    report_installed "plugins do tmux (sensible, resurrect, continuum, catppuccin)"
  fi
}
