#!/usr/bin/env bash
# Helper de pergunta sim/não reutilizável.

ask_yes_no() {
  local question="$1"
  local answer
  while true; do
    read -r -p "$question [s/N] " answer
    case "$answer" in
      [sS]|[sS][iI][mM]) return 0 ;;
      ""|[nN]|[nN][aA][oO]) return 1 ;;
      *) echo "Responda com s ou n." ;;
    esac
  done
}
