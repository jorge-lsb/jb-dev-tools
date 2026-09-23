-- Configurações do Conjure (REPL Clojure). Não cria atalhos custom,
-- só ajusta os defaults do plugin.

return {
  {
    "Olical/conjure",
    init = function()
      -- Pretty-print do resultado avaliado
      vim.g["conjure#client#clojure#nrepl#eval#pretty_print"] = true
      vim.g["conjure#client#clojure#nrepl#eval#print_options#right_margin"] = 120
      vim.g["conjure#client#clojure#nrepl#eval#print_options#length"] = 50
      vim.g["conjure#client#clojure#nrepl#eval#print_options#level"] = 50

      -- Auto-require do namespace do buffer ao abrir
      vim.g["conjure#client#clojure#nrepl#eval#auto_require"] = true

      -- Não sobe um nREPL Babashka temporário quando não acha .nrepl-port.
      -- Conecta manual (\cf) num REPL real depois de subir num pane do tmux.
      vim.g["conjure#client#clojure#nrepl#connection#auto_repl#enabled"] = false

      -- Highlight do form avaliado
      vim.g["conjure#highlight#enabled"] = true
      vim.g["conjure#highlight#timeout"] = 400

      -- Largura do log buffer quando abre vertical (\lv)
      vim.g["conjure#log#split#width"] = 0.4

      -- Pretty print de falhas de teste (runner default: clojure.test)
      vim.g["conjure#client#clojure#nrepl#test#pretty_print_test_failures"] = true
    end,
  },
}
