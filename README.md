# jb-dev-tools

Kit pessoal de ferramentas de dev: scripts e configs que eu quero ter à mão em qualquer PC novo (macOS ou Linux/WSL), sem precisar copiar tudo manualmente de novo.

## Índice

- [Setup rápido](#setup-rápido)
- [O que o setup configura](#o-que-o-setup-configura)
- [Atalhos e aliases pra lembrar](#atalhos-e-aliases-pra-lembrar)
- [Estrutura do repo](#estrutura-do-repo)

## Setup rápido

```bash
git clone git@github.com:jorge-lsb/jb-dev-tools.git
cd jb-dev-tools
./setup/setup.sh
```

O script detecta o SO automaticamente (macOS via Homebrew, Linux/WSL Ubuntu via apt) e pergunta, um bloco por vez, o que você quer instalar/configurar: tmux, nvim, shell. É seguro rodar de novo: cada módulo é idempotente (pula o que já está instalado, faz backup do que for sobrescrever) e ao final imprime um relatório do que já estava lá, do que foi instalado/atualizado e do que falhou (com um log temporário pra investigar).

## O que o setup configura

| Ferramenta | Pra quê | Repo oficial |
|---|---|---|
| [tmux](https://github.com/tmux/tmux) | multiplexador de terminal | github.com/tmux/tmux |
| [TPM](https://github.com/tmux-plugins/tpm) | gerenciador de plugins do tmux | github.com/tmux-plugins/tpm |
| [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) | defaults sensatos pro tmux | github.com/tmux-plugins/tmux-sensible |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | salva/restaura sessões | github.com/tmux-plugins/tmux-resurrect |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | autosave/autorestore de sessões | github.com/tmux-plugins/tmux-continuum |
| [Neovim](https://github.com/neovim/neovim) | editor | github.com/neovim/neovim |
| [LazyVim](https://github.com/LazyVim/LazyVim) | distro de config do Neovim | github.com/LazyVim/LazyVim |
| [Conjure](https://github.com/Olical/conjure) | REPL interativo (Clojure) | github.com/Olical/conjure |
| [fzf](https://github.com/junegunn/fzf) | fuzzy finder | github.com/junegunn/fzf |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | busca de texto rápida | github.com/BurntSushi/ripgrep |
| [fd](https://github.com/sharkdp/fd) | busca de arquivos rápida | github.com/sharkdp/fd |
| [bat](https://github.com/sharkdp/bat) | `cat` com highlight, usado no preview do fzf | github.com/sharkdp/bat |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `cd` inteligente (aprende os diretórios mais usados) | github.com/ajeetdsouza/zoxide |
| [ble.sh](https://github.com/akinomyoga/ble.sh) | syntax highlight + autosuggestion fantasma no bash | github.com/akinomyoga/ble.sh |
| [bash-completion](https://github.com/scop/bash-completion) | completion de comandos (ex.: nomes de sessão do tmux) | github.com/scop/bash-completion |
| [starship](https://github.com/starship/starship) | prompt | github.com/starship/starship |
| [lazygit](https://github.com/jesseduffield/lazygit) | TUI pra git | github.com/jesseduffield/lazygit |

## Atalhos e aliases pra lembrar

**tmux** (prefix = `Ctrl+a`)
- `prefix + |` / `prefix + -`: split horizontal/vertical (herda o diretório atual)
- `Alt + h/j/k/l`: navega entre panes (sem precisar do prefix)
- `prefix + H/J/K/L`: redimensiona o pane atual
- `prefix + n` / `prefix + p`: próxima/anterior window
- `prefix + g`: abre um popup com uma sessão dedicada do Claude Code pro diretório atual (fechar o popup só faz detach, não mata o processo)
- `prefix + Ctrl+l`: limpa a tela e o scrollback
- `prefix + r`: recarrega o `~/.tmux.conf`

**shell**
- `tls` / `ta <nome>` / `tn <nome>` / `tk <nome>`: listar / anexar / criar / matar sessão tmux
- `lg`: abre o lazygit
- `v` / `vi` / `vim`: abrem o `nvim`
- `z <termo>`: pula pra um diretório frequente (zoxide)

## Estrutura do repo

```
setup/
├── setup.sh          # entrypoint interativo
├── lib/               # detecção de SO, prompts, relatório final
├── modules/           # um módulo por área (tmux, nvim, shell)
└── files/             # dotfiles versionados que os módulos copiam
```

Esse repo é o ponto de partida pra guardar qualquer outro script/ferramenta pessoal de dev: novas seções entram aqui conforme forem surgindo.
