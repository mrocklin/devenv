# devenv

Personal dev environment bootstrap. Point a fresh mac or linux box at this repo and run `bootstrap.sh` to get a working setup.

## Quick start

```sh
git clone https://github.com/mrocklin/devenv ~/devenv  # or wherever
cd ~/devenv
./bootstrap.sh
```

Then in a new shell:

```sh
cp config/secrets.env.example ~/.config/devenv/secrets.env
$EDITOR ~/.config/devenv/secrets.env   # fill in real values
```

## What it installs

- **Shell**: zsh + starship prompt, vi-mode, `EDITOR=nvim`. On linux, `.bashrc` is patched to `exec zsh -l` (no `chsh` needed).
- **Editor**: neovim with a lazy.nvim-based config (LSP, Telescope, Treesitter, kanagawa)
- **CLI**: git, gh, ripgrep, fd, bat, eza, jq, delta, difftastic, btop, tree, fzf
- **Languages**: rust (via rustup), uv (python), node
- **Claude**: claude code + claudechic, with `~/.claude/{CLAUDE.md, commands, skills, hooks}` symlinked and the bash-permissions / pyright-lsp / rust-analyzer-lsp plugins installed
- **macOS extras**: aerospace tiling WM, ghostty terminal, 1Password CLI

## Layout

```
bootstrap.sh        OS-detecting entry point
Brewfile            macOS packages
config/             dotfiles, symlinked into $HOME
AGENT.md            instructions for a Claude agent driving the setup
```

## Updating

This repo lives at `~/devenv` (or wherever you clone it). Configs are **symlinked**, so editing `~/.zshrc` actually edits `config/zshrc` in this repo. Commit and push to sync across machines.

## Ghostty + ssh to a new box

Ghostty advertises `TERM=xterm-ghostty`, but its terminfo entry lives only on
the machine ghostty is installed on. The first time you ssh from a ghostty
terminal to a new remote, copy the entry over:

```sh
infocmp -x xterm-ghostty | ssh <host> 'tic -x -'
```

Without this, zsh on the remote silently disables features that depend on
terminal capabilities — e.g. the right-side prompt with hostname / git branch.

## See also

- [AGENT.md](./AGENT.md) — how to brief an agent to run the setup on a new box
