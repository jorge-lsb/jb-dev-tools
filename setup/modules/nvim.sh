#!/usr/bin/env bash
# Build tools + LazyVim starter + config custom.

_install_nodejs_linux() {
  set -e
  sudo apt-get install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor \
    | sudo tee /etc/apt/keyrings/nodesource.gpg >/dev/null
  sudo chmod a+r /etc/apt/keyrings/nodesource.gpg

  local architecture
  architecture="$(dpkg --print-architecture)"
  printf 'Types: deb\nURIs: https://deb.nodesource.com/node_24.x\nSuites: nodistro\nComponents: main\nArchitectures: %s\nSigned-By: /etc/apt/keyrings/nodesource.gpg\n' \
    "$architecture" | sudo tee /etc/apt/sources.list.d/nodesource.sources >/dev/null

  sudo apt-get update -y
  sudo apt-get install -y nodejs
}

_ensure_bash_lsp_runtime() {
  local node_major=0 runtime_installed=false
  if command -v node >/dev/null 2>&1; then
    node_major="$(node -p 'Number(process.versions.node.split(".")[0])' 2>/dev/null || printf '0')"
  fi

  if ((node_major < 20)) || ! command -v npm >/dev/null 2>&1; then
    if [[ "$OS" == "mac" ]]; then
      if ! run_step "install Node.js for Bash LSP" brew install node; then
        return
      fi
    else
      if ! run_step "install Node.js 24 for Bash LSP" _install_nodejs_linux; then
        return
      fi
    fi
    runtime_installed=true
    node_major="$(node -p 'Number(process.versions.node.split(".")[0])' 2>/dev/null || printf '0')"
  fi

  if ((node_major >= 20)) && command -v npm >/dev/null 2>&1; then
    if $runtime_installed; then
      report_installed "Node.js 20+ and npm (Bash LSP runtime)"
    else
      report_already_installed "Node.js 20+ and npm (Bash LSP runtime)"
    fi
  else
    report_failed "Node.js 20+ and npm are required to install the Bash language server"
  fi
}

setup_nvim() {
  local repo_dir="$1"

  _ensure_bash_lsp_runtime

  if [[ "$OS" == "linux" ]]; then
    if dpkg -s build-essential >/dev/null 2>&1; then
      report_already_installed "build-essential"
    else
      if run_step "install build-essential" sudo apt-get install -y build-essential; then
        report_installed "build-essential"
      fi
    fi
  else
    if xcode-select -p >/dev/null 2>&1; then
      report_already_installed "Xcode Command Line Tools"
    else
      if run_step "install Xcode Command Line Tools" xcode-select --install; then
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

    if run_step "install $dep" pkg_install "$pkg_name"; then
      report_installed "$dep"
    fi
  done

  local nvim_dir="$HOME/.config/nvim"
  if [[ -d "$nvim_dir" ]]; then
    mv -f "$nvim_dir" "$nvim_dir.bak-$(date +%Y%m%d-%H%M%S)"
    report_updated "~/.config/nvim (previous version backed up)"
  fi

  if ! run_step "clone LazyVim starter" git clone https://github.com/LazyVim/starter.git "$nvim_dir"; then
    return
  fi
  rm -rf "$nvim_dir/.git"
  report_installed "LazyVim starter"

  mkdir -p "$nvim_dir/lua/config" "$nvim_dir/lua/plugins"
  cp -f "$repo_dir/files/nvim/lua/config/options.lua" "$nvim_dir/lua/config/options.lua"
  cp -f "$repo_dir/files/nvim/lua/config/autocmds.lua" "$nvim_dir/lua/config/autocmds.lua"
  cp -f "$repo_dir/files/nvim/lazyvim.json" "$nvim_dir/lazyvim.json"
  cp -f "$repo_dir/files/nvim/lua/plugins/clojure.lua" "$nvim_dir/lua/plugins/clojure.lua"
  cp -f "$repo_dir/files/nvim/lua/plugins/bash.lua" "$nvim_dir/lua/plugins/bash.lua"
  report_updated "custom nvim config (options, autocmds, lazyvim.json, conjure, bash LSP)"

  if run_step "sync nvim plugins (Lazy sync)" nvim --headless "+Lazy! sync" +qa; then
    report_installed "nvim plugins/LSPs (Lazy sync)"
  fi
}
