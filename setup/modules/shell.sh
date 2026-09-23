#!/usr/bin/env bash
# fzf, bat, ripgrep, fd, zoxide, ble.sh, lazygit, starship, ~/.bashrc.

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
  if run_step "instalar $tool" pkg_install "$pkg_name"; then
    report_installed "$tool"
  fi
}

_install_lazygit() {
  if pkg_installed lazygit; then
    report_already_installed "lazygit"
    return
  fi

  if [[ "$OS" == "mac" ]]; then
    if run_step "instalar lazygit" pkg_install lazygit; then
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
  if run_step "instalar lazygit (release do GitHub)" bash -c "
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

_merge_bashrc_block() {
  local snippet_file="$1"
  local target="$HOME/.bashrc"
  local start="# >>> jb-dev-tools >>>"
  local end="# <<< jb-dev-tools <<<"

  touch "$target"

  if grep -qF "$start" "$target"; then
    local tmp
    tmp="$(mktemp)"
    awk -v start="$start" -v end="$end" '
      $0 == start { skip = 1; next }
      $0 == end   { skip = 0; next }
      !skip       { print }
    ' "$target" >"$tmp"
    mv "$tmp" "$target"
    cat "$snippet_file" >>"$target"
    report_updated "bloco jb-dev-tools em ~/.bashrc"
  else
    cp "$target" "$target.bak-$(date +%Y%m%d-%H%M%S)"
    cat "$snippet_file" >>"$target"
    report_installed "bloco jb-dev-tools em ~/.bashrc (backup do anterior salvo)"
  fi
}

setup_shell() {
  local repo_dir="$1"

  local tool
  for tool in fzf ripgrep bat fd zoxide starship; do
    _install_if_missing "$tool"
  done

  _install_lazygit

  if [[ -d "$HOME/.local/share/blesh" ]]; then
    report_already_installed "ble.sh"
  else
    local ble_tmp
    ble_tmp="$(mktemp -d)"
    if run_step "clonar e compilar ble.sh" bash -c "
      git clone --recursive https://github.com/akinomyoga/ble.sh.git '$ble_tmp/ble.sh' &&
      make -C '$ble_tmp/ble.sh' install PREFIX=\"\$HOME/.local\"
    "; then
      report_installed "ble.sh"
    fi
    rm -rf "$ble_tmp"
  fi

  cp "$repo_dir/files/starship.toml" "$HOME/.config/starship.toml" 2>/dev/null || {
    mkdir -p "$HOME/.config"
    cp "$repo_dir/files/starship.toml" "$HOME/.config/starship.toml"
  }
  report_updated "~/.config/starship.toml"

  _merge_bashrc_block "$repo_dir/files/bashrc.snippet"
}
