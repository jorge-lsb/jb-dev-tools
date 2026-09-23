#!/usr/bin/env bash
# Tracking de status por passo + log temporário de falhas + relatório final.

REPORT_LOG_FILE="$(mktemp "/tmp/jb-dev-tools-setup-$(date +%Y%m%d-%H%M%S)-XXXX.log")"

if [[ -t 1 ]]; then
  C_BOLD=$'\033[1m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_CYAN=$'\033[36m'
  C_RED=$'\033[31m'
  C_RESET=$'\033[0m'
else
  C_BOLD=""; C_GREEN=""; C_YELLOW=""; C_CYAN=""; C_RED=""; C_RESET=""
fi

declare -a REPORT_ALREADY_INSTALLED=()
declare -a REPORT_INSTALLED=()
declare -a REPORT_UPDATED=()
declare -a REPORT_FAILED=()

report_already_installed() { REPORT_ALREADY_INSTALLED+=("$1"); }
report_installed() { REPORT_INSTALLED+=("$1"); }
report_updated() { REPORT_UPDATED+=("$1"); }

# report_failed <step description>
report_failed() {
  REPORT_FAILED+=("$1")
}

# run_step <description> <command...>
# Runs the command, streaming its output live to the terminal (steps like
# package installs or nvim's Lazy sync can take a while, and without this
# the script looks like it hung). The same output is also appended to the
# temp log, so failures can be investigated afterwards. Tracks the result.
run_step() {
  local desc="$1"
  shift

  echo ""
  echo "${C_CYAN}==>${C_RESET} ${desc}..."
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
  echo "${C_BOLD}============================================================${C_RESET}"
  echo "${C_BOLD} Setup report${C_RESET}"
  echo "${C_BOLD}============================================================${C_RESET}"

  if ((${#REPORT_ALREADY_INSTALLED[@]} > 0)); then
    echo ""
    echo "${C_YELLOW}Already installed:${C_RESET}"
    for item in "${REPORT_ALREADY_INSTALLED[@]}"; do
      echo "  - $item"
    done
  fi

  if ((${#REPORT_INSTALLED[@]} > 0)); then
    echo ""
    echo "${C_GREEN}Installed now:${C_RESET}"
    for item in "${REPORT_INSTALLED[@]}"; do
      echo "  - $item"
    done
  fi

  if ((${#REPORT_UPDATED[@]} > 0)); then
    echo ""
    echo "${C_CYAN}Updated/reconfigured:${C_RESET}"
    for item in "${REPORT_UPDATED[@]}"; do
      echo "  - $item"
    done
  fi

  if ((${#REPORT_FAILED[@]} > 0)); then
    echo ""
    echo "${C_RED}Failed:${C_RESET}"
    for item in "${REPORT_FAILED[@]}"; do
      echo "  - $item"
    done
    echo ""
    echo "Failure details in the log: ${C_BOLD}$REPORT_LOG_FILE${C_RESET}"
  else
    echo ""
    echo "${C_GREEN}No failures. All good.${C_RESET}"
  fi
  echo "${C_BOLD}============================================================${C_RESET}"
}
