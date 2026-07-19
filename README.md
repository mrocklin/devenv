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
- **Agent CLIs**: claude code (with `~/.claude/{CLAUDE.md, commands, skills, hooks}` symlinked and the pyright-lsp / rust-analyzer-lsp plugins installed) and codex (`~/.codex/AGENTS.md` symlinked). Both `CLAUDE.md` and `AGENTS.md` point at the same source, `config/_AGENTS.md`, so Claude and Codex share one set of instructions.
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

## Eternal terminal on a remote box

`bootstrap.sh` on linux installs `et` and enables the `etserver` systemd unit
(listening on tcp/2022). If the box is behind a cloud firewall (Hetzner, AWS
security group, etc.), open tcp/2022 inbound — the local host has no ufw /
iptables rules to change. Then `et <host>` works the same as ssh.

## Ghostty + ssh to a new box

Ghostty advertises `TERM=xterm-ghostty`, but its terminfo entry lives only on
the machine ghostty is installed on. Without it on a remote, zsh silently
disables features that depend on terminal capabilities (e.g. the right-side
prompt) and keys like backspace misbehave over ssh.

`bootstrap.sh` handles this: the entry is vendored at
`config/terminfo/xterm-ghostty.ti` and compiled with `tic` on every box.
Nothing to do by hand — just reconnect after bootstrap.

If ghostty gains terminfo capabilities (version upgrade), regenerate the
vendored file from a ghostty machine and commit it:

```sh
infocmp -x xterm-ghostty > config/terminfo/xterm-ghostty.ti
```

## See also

- [AGENT.md](./AGENT.md) — how to brief an agent to run the setup on a new box
