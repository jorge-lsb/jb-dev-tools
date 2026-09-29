#!/usr/bin/env bash
# Instala tmux + TPM + plugins e escreve ~/.tmux.conf.

_select_tmux_ai_cli() {
  local answer
  while true; do
    read -r -p "Which CLI should open in the tmux popup? [1] Claude [2] Codex [3] Generic shell [3]: " answer
    case "${answer:-3}" in
      1 | claude | Claude | CLAUDE) printf 'claude'; return 0 ;;
      2 | codex | Codex | CODEX) printf 'codex'; return 0 ;;
      3 | generic | Generic | shell | Shell) printf ''; return 0 ;;
      *) echo "Please choose 1 (Claude), 2 (Codex), or 3 (generic shell)." >&2 ;;
    esac
  done
}

_configure_tmux_ai_cli() {
  local target="$1" ai_cli="$2" tmp
  tmp="$(mktemp)"
  awk -v cli="$ai_cli" '
    /^set -g @ai_cli / {
      printf "set -g @ai_cli \047%s\047\n", cli
      next
    }
    { print }
  ' "$target" >"$tmp"
  mv -f "$tmp" "$target"
}

setup_tmux() {
  local repo_dir="$1"
  local target="$HOME/.tmux.conf"

  if pkg_installed tmux; then
    report_already_installed "tmux"
  else
    if run_step "install tmux" pkg_install tmux; then
      report_installed "tmux"
    else
      return
    fi
  fi

  if [[ -f "$target" ]] && ask_yes_no "Existing ~/.tmux.conf detected. Skip tmux setup and preserve it?"; then
    report_already_installed "~/.tmux.conf (preserved; tmux setup skipped)"
    return
  fi

  if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
    report_already_installed "TPM (tmux plugin manager)"
  else
    if run_step "clone TPM" git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"; then
      report_installed "TPM (tmux plugin manager)"
    else
      return
    fi
  fi

  local ai_cli
  ai_cli="$(_select_tmux_ai_cli)"

  if [[ -f "$target" ]]; then
    cp -f "$target" "$target.bak-$(date +%Y%m%d-%H%M%S)"
    cp -f "$repo_dir/files/tmux.conf" "$target"
    report_updated "~/.tmux.conf (previous version backed up)"
  else
    cp -f "$repo_dir/files/tmux.conf" "$target"
    report_installed "~/.tmux.conf"
  fi
  _configure_tmux_ai_cli "$target" "$ai_cli"
  if [[ -n "$ai_cli" ]]; then
    report_updated "tmux popup CLI: $ai_cli"
  else
    report_updated "tmux popup CLI: generic shell"
  fi

  # O install_plugins.sh do TPM lê as variáveis @plugin de dentro de uma
  # sessão tmux com o .tmux.conf já carregado — sem isso ele aborta com
  # "Tmux Plugin Manager not configured". Sobe uma sessão só pra isso.
  local bootstrap_session="jb_dev_tools_tpm_bootstrap"
  tmux new-session -d -s "$bootstrap_session" -c "$HOME" >/dev/null 2>&1
  tmux source-file "$target" >/dev/null 2>&1

  if run_step "install tmux plugins (TPM)" "$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh"; then
    report_installed "tmux plugins (sensible, resurrect, continuum)"
  fi

  tmux kill-session -t "$bootstrap_session" >/dev/null 2>&1
}
