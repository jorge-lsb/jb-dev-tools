#!/usr/bin/env bash
# Tracking de status por passo + log temporário de falhas + relatório final.

REPORT_LOG_FILE="$(mktemp "/tmp/jb-dev-tools-setup-$(date +%Y%m%d-%H%M%S)-XXXX.log")"

declare -a REPORT_ALREADY_INSTALLED=()
declare -a REPORT_INSTALLED=()
declare -a REPORT_UPDATED=()
declare -a REPORT_FAILED=()

report_already_installed() { REPORT_ALREADY_INSTALLED+=("$1"); }
report_installed() { REPORT_INSTALLED+=("$1"); }
report_updated() { REPORT_UPDATED+=("$1"); }

# report_failed <descrição do passo>
# Espera receber via stdin (heredoc/pipe) ou já ter sido escrito em REPORT_LOG_FILE.
report_failed() {
  REPORT_FAILED+=("$1")
}

# run_step <descrição> <comando...>
# Executa o comando mostrando a saída ao vivo no terminal (passos como
# instalação de pacotes ou "Lazy sync" do nvim podem demorar bastante, e
# sem isso parece que o script travou). A mesma saída também vai pro log
# temp, pra investigar depois em caso de falha. Marca o resultado.
run_step() {
  local desc="$1"
  shift

  echo ""
  echo ">> $desc..."
  {
    echo "=== $desc ($(date +%H:%M:%S)) ==="
  } >>"$REPORT_LOG_FILE"

  "$@" 2>&1 | tee -a "$REPORT_LOG_FILE"
  local status="${PIPESTATUS[0]}"

  if ((status == 0)); then
    return 0
  else
    report_failed "$desc"
    return 1
  fi
}

print_report() {
  echo ""
  echo "===================================================="
  echo " Relatório do setup"
  echo "===================================================="

  if ((${#REPORT_ALREADY_INSTALLED[@]} > 0)); then
    echo ""
    echo "Já estava instalado:"
    for item in "${REPORT_ALREADY_INSTALLED[@]}"; do
      echo "  - $item"
    done
  fi

  if ((${#REPORT_INSTALLED[@]} > 0)); then
    echo ""
    echo "Instalado agora:"
    for item in "${REPORT_INSTALLED[@]}"; do
      echo "  - $item"
    done
  fi

  if ((${#REPORT_UPDATED[@]} > 0)); then
    echo ""
    echo "Atualizado/reconfigurado:"
    for item in "${REPORT_UPDATED[@]}"; do
      echo "  - $item"
    done
  fi

  if ((${#REPORT_FAILED[@]} > 0)); then
    echo ""
    echo "Falhou:"
    for item in "${REPORT_FAILED[@]}"; do
      echo "  - $item"
    done
    echo ""
    echo "Detalhes das falhas no log: $REPORT_LOG_FILE"
  else
    echo ""
    echo "Nenhuma falha. :)"
  fi
  echo "===================================================="
}
