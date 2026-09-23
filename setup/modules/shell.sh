#!/usr/bin/env bash
# fzf, bat, ripgrep, fd, zoxide, ble.sh, bash-completion, lazygit, starship, ~/.bashrc.

_pkg_name_for() {
  local tool="$1"
  if [[ "$OS" == "linux" ]]; then
    case "$tool" in
      bat) echo "bat" ;;
      fd) echo "fd-find" ;;
      *) echo "$tool" ;;
    esac
  else
    echo "$tool"
  fi
}

_bin_name_for() {
  local tool="$1"
  if [[ "$OS" == "linux" ]]; then
    case "$tool" in
      bat) echo "batcat" ;;
      fd) echo "fdfind" ;;
      *) echo "$tool" ;;
    esac
  else
    echo "$tool"
  fi
}

_install_if_missing() {
  local tool="$1"
  local bin
  bin="$(_bin_name_for "$tool")"

  if pkg_installed "$bin" || pkg_installed "$tool"; then
    report_already_installed "$tool"
    return
  fi

  local pkg_name
  pkg_name="$(_pkg_name_for "$tool")"
  if run_step "install $tool" pkg_install "$pkg_name"; then
    report_installed "$tool"
  fi
}

_install_lazygit() {
  if pkg_installed lazygit; then
    report_already_installed "lazygit"
    return
  fi

  if [[ "$OS" == "mac" ]]; then
    if run_step "install lazygit" pkg_install lazygit; then
      report_installed "lazygit"
    fi
    return
  fi

  # No Ubuntu/Debian o lazygit não está nos repos do apt, então instala
  # o binário direto da release mais recente no GitHub.
  local arch
  case "$(uname -m)" in
    x86_64) arch="x86_64" ;;
    aarch64 | arm64) arch="arm64" ;;
    *) arch="x86_64" ;;
  esac

  local lg_tmp
  lg_tmp="$(mktemp -d)"
  if run_step "install lazygit (GitHub release)" bash -c "
    set -e
    version=\$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -m1 '\"tag_name\"' | sed -E 's/.*\"v([^\"]+)\".*/\\1/')
    curl -fsSL -o '$lg_tmp/lazygit.tar.gz' \"https://github.com/jesseduffield/lazygit/releases/download/v\${version}/lazygit_\${version}_Linux_${arch}.tar.gz\"
    tar -xf '$lg_tmp/lazygit.tar.gz' -C '$lg_tmp' lazygit
    sudo install '$lg_tmp/lazygit' /usr/local/bin/lazygit
  "; then
    report_installed "lazygit"
  fi
  rm -rf "$lg_tmp"
}

_install_bash_completion() {
  if [[ "$OS" == "linux" ]]; then
    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
      report_already_installed "bash-completion"
      return
    fi
    if run_step "install bash-completion" pkg_install bash-completion; then
      report_installed "bash-completion"
    fi
  else
    if brew list bash-completion@2 >/dev/null 2>&1; then
      report_already_installed "bash-completion"
      return
    fi
    if run_step "install bash-completion" pkg_install bash-completion@2; then
      report_installed "bash-completion"
    fi
  fi
}

# _replace_marked_block <target> <start marker> <end marker>
# Remove um bloco delimitado por marcadores de qualquer lugar do arquivo,
# se existir. Usado pros dois blocos jb-dev-tools serem idempotentes.
_replace_marked_block() {
  local target="$1" start="$2" end="$3"
  local tmp
  tmp="$(mktemp)"
  awk -v start="$start" -v end="$end" '
    $0 == start { skip = 1; next }
    $0 == end   { skip = 0; next }
    !skip       { print }
  ' "$target" >"$tmp"
  mv -f "$tmp" "$target"
}

# Insere o preload do ble.sh no topo do .bashrc (precisa vir antes de
# tudo, com o attach de verdade só no final do arquivo, pra funcionar
# igual dentro e fora do tmux).
_merge_bashrc_top() {
  local snippet_file="$1"
  local target="$HOME/.bashrc"
  local start="# >>> jb-dev-tools-top >>>"
  local end="# <<< jb-dev-tools-top <<<"

  touch "$target"
  local had_block=false
  grep -qF "$start" "$target" && had_block=true

  _replace_marked_block "$target" "$start" "$end"

  local tmp
  tmp="$(mktemp)"
  cat "$snippet_file" "$target" >"$tmp"
  mv -f "$tmp" "$target"

  if $had_block; then
    report_updated "jb-dev-tools ble.sh preload block (top of ~/.bashrc)"
  else
    report_installed "jb-dev-tools ble.sh preload block (top of ~/.bashrc)"
  fi
}

_merge_bashrc_bottom() {
  local snippet_file="$1"
  local target="$HOME/.bashrc"
  local start="# >>> jb-dev-tools >>>"
  local end="# <<< jb-dev-tools <<<"

  touch "$target"

  if grep -qF "$start" "$target"; then
    _replace_marked_block "$target" "$start" "$end"
    cat "$snippet_file" >>"$target"
    report_updated "jb-dev-tools block in ~/.bashrc"
  else
    cp -f "$target" "$target.bak-$(date +%Y%m%d-%H%M%S)"
    cat "$snippet_file" >>"$target"
    report_installed "jb-dev-tools block in ~/.bashrc (previous file backed up)"
  fi
}

setup_shell() {
  local repo_dir="$1"

  local tool
  for tool in fzf ripgrep bat fd zoxide starship; do
    _install_if_missing "$tool"
  done

  _install_lazygit
  _install_bash_completion

  if [[ -d "$HOME/.local/share/blesh" ]]; then
    report_already_installed "ble.sh"
  else
    local ble_tmp
    ble_tmp="$(mktemp -d)"
    if run_step "clone and build ble.sh" bash -c "
      git clone --recursive https://github.com/akinomyoga/ble.sh.git '$ble_tmp/ble.sh' &&
      make -C '$ble_tmp/ble.sh' install PREFIX=\"\$HOME/.local\"
    "; then
      report_installed "ble.sh"
    fi
    rm -rf "$ble_tmp"
  fi

  cp -f "$repo_dir/files/starship.toml" "$HOME/.config/starship.toml" 2>/dev/null || {
    mkdir -p "$HOME/.config"
    cp -f "$repo_dir/files/starship.toml" "$HOME/.config/starship.toml"
  }
  report_updated "~/.config/starship.toml"

  _merge_bashrc_top "$repo_dir/files/bashrc_top.snippet"
  _merge_bashrc_bottom "$repo_dir/files/bashrc.snippet"
}
