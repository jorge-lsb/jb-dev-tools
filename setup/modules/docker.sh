#!/usr/bin/env bash
# Docker runtime + Compose and a local API/database/observability lab.

_docker_install_linux() {
  set -e
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc >/dev/null
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  local codename architecture
  . /etc/os-release
  codename="${UBUNTU_CODENAME:-$VERSION_CODENAME}"
  architecture="$(dpkg --print-architecture)"
  printf 'Types: deb\nURIs: https://download.docker.com/linux/ubuntu\nSuites: %s\nComponents: stable\nArchitectures: %s\nSigned-By: /etc/apt/keyrings/docker.asc\n' \
    "$codename" "$architecture" | sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null

  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  if command -v systemctl >/dev/null 2>&1 && systemctl list-unit-files docker.service >/dev/null 2>&1; then
    sudo systemctl enable --now docker
  else
    sudo service docker start
  fi
}

setup_docker() {
  local repo_dir="$1"
  local docker_ready=false

  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    report_already_installed "Docker CLI + Compose"
    docker_ready=true
  fi

  if ! $docker_ready; then
    if [[ "$OS" == "mac" ]]; then
      if [[ -d /Applications/Docker.app ]] || brew list --cask docker >/dev/null 2>&1; then
        report_already_installed "Docker Desktop"
      elif run_step "install Docker Desktop" brew install --cask docker; then
        report_installed "Docker Desktop (launch Docker.app to start the engine)"
      fi
    else
      if run_step "install Docker Engine + Compose" _docker_install_linux; then
        report_installed "Docker Engine, Buildx and Compose"
      fi
    fi
  fi

  local lab_dir="$HOME/docker-lab"
  if [[ -e "$lab_dir/compose.yaml" ]]; then
    report_already_installed "Docker lab compose file ($lab_dir/compose.yaml; preserved existing file)"
  else
    mkdir -p "$lab_dir"
    cp -f "$repo_dir/files/docker/compose.yaml" "$lab_dir/compose.yaml"
    report_installed "Docker lab compose file ($lab_dir/compose.yaml)"
  fi

  if [[ ! -e "$lab_dir/prometheus.yml" ]]; then
    cp -f "$repo_dir/files/docker/prometheus.yml" "$lab_dir/prometheus.yml"
  fi
  if [[ ! -e "$lab_dir/grafana/provisioning/datasources/datasources.yml" ]]; then
    mkdir -p "$lab_dir/grafana/provisioning/datasources"
    cp -f "$repo_dir/files/docker/grafana-datasources.yml" "$lab_dir/grafana/provisioning/datasources/datasources.yml"
  fi
}
