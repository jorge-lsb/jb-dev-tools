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

  # O install_plugins.sh do TPM lê as variáveis @plugin de dentro de uma
  # sessão tmux com o .tmux.conf já carregado — sem isso ele aborta com
  # "Tmux Plugin Manager not configured". Sobe uma sessão só pra isso.
  local bootstrap_session="jb_dev_tools_tpm_bootstrap"
  tmux new-session -d -s "$bootstrap_session" -c "$HOME" >/dev/null 2>&1
  tmux source-file "$target" >/dev/null 2>&1

  if run_step "instalar plugins do tmux (TPM)" "$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh"; then
    report_installed "plugins do tmux (sensible, resurrect, continuum, catppuccin)"
  fi

  tmux kill-session -t "$bootstrap_session" >/dev/null 2>&1
}
