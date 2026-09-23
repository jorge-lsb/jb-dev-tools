#!/usr/bin/env bash
# Build tools + LazyVim starter + config custom.

setup_nvim() {
  local repo_dir="$1"

  if [[ "$OS" == "linux" ]]; then
    if dpkg -s build-essential >/dev/null 2>&1; then
      report_already_installed "build-essential"
    else
      if run_step "instalar build-essential" sudo apt-get install -y build-essential; then
        report_installed "build-essential"
      fi
    fi
  else
    if xcode-select -p >/dev/null 2>&1; then
      report_already_installed "Xcode Command Line Tools"
    else
      if run_step "instalar Xcode Command Line Tools" xcode-select --install; then
        report_installed "Xcode Command Line Tools"
      fi
    fi
  fi

  local dep
  for dep in nvim git ripgrep fd; do
    local bin="$dep"
    [[ "$dep" == "ripgrep" ]] && bin="rg"
    [[ "$dep" == "fd" && "$OS" == "linux" ]] && bin="fdfind"

    if pkg_installed "$bin"; then
      report_already_installed "$dep"
      continue
    fi

    local pkg_name="$dep"
    [[ "$dep" == "fd" && "$OS" == "linux" ]] && pkg_name="fd-find"

    if run_step "instalar $dep" pkg_install "$pkg_name"; then
      report_installed "$dep"
    fi
  done

  local nvim_dir="$HOME/.config/nvim"
  if [[ -d "$nvim_dir" ]]; then
    mv "$nvim_dir" "$nvim_dir.bak-$(date +%Y%m%d-%H%M%S)"
    report_updated "~/.config/nvim (backup do anterior salvo)"
  fi

  if ! run_step "clonar LazyVim starter" git clone https://github.com/LazyVim/starter.git "$nvim_dir"; then
    return
  fi
  rm -rf "$nvim_dir/.git"
  report_installed "LazyVim starter"

  mkdir -p "$nvim_dir/lua/config" "$nvim_dir/lua/plugins"
  cp "$repo_dir/files/nvim/lua/config/options.lua" "$nvim_dir/lua/config/options.lua"
  cp "$repo_dir/files/nvim/lua/config/autocmds.lua" "$nvim_dir/lua/config/autocmds.lua"
  cp "$repo_dir/files/nvim/lazyvim.json" "$nvim_dir/lazyvim.json"
  cp "$repo_dir/files/nvim/lua/plugins/clojure.lua" "$nvim_dir/lua/plugins/clojure.lua"
  report_updated "config custom do nvim (options, autocmds, lazyvim.json, conjure)"

  if run_step "sincronizar plugins do nvim (Lazy sync)" nvim --headless "+Lazy! sync" +qa; then
    report_installed "plugins/LSPs do nvim (Lazy sync)"
  fi
}
