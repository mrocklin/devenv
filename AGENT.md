# Agent instructions

You are setting up Matt's dev environment on a fresh machine. Read this whole file first, then execute.

## Goal

Run `./bootstrap.sh` and verify it succeeded. Get the shell, editor, and core CLI tools working so Matt can start working immediately.

## Context you should know

- **OS**: macOS (Apple Silicon) or Debian/Ubuntu Linux. Other distros aren't supported by this bootstrap — fall back to manual install and tell Matt.
- **Shell**: zsh on both. On linux we don't `chsh` — `.bashrc` is set up to `exec zsh -l` when an interactive shell starts. If you `ssh` in and find yourself in bash, just type `zsh`.
- **Sudo**: bootstrap uses `sudo` on linux for apt and a couple of `/usr/local` writes. If you're running as root, it auto-skips sudo. If you're a non-root user without sudo rights, package install will fail — tell Matt and stop.
- **Backup**: existing dotfiles get moved into `~/.devenv-backup-<timestamp>/` (not deleted). On a previously-configured machine this can be substantial. Mention the backup path to Matt after running.
- **Style preferences** (these are in `config/claude/CLAUDE.md` which gets symlinked to `~/.claude/CLAUDE.md`):
  - Be concise.
  - Prefer modern tooling (uv, ripgrep, fd, bat, eza, neovim, starship).
  - Avoid unnecessary abstraction.
  - Don't commit to git without asking.
  - Use uv for python.
- **Secrets**: there are NO secrets in this repo. The shell sources `~/.config/devenv/secrets.env` if it exists. After bootstrap, prompt Matt to populate it (template at `config/secrets.env.example`).

## Steps

1. **Run `./bootstrap.sh`**. It is idempotent — safe to re-run if it fails partway. Read its output; if it errors, fix the specific failure and re-run rather than starting over.

2. **Start a fresh shell before verifying** — the bootstrap script appends to PATH but those exports don't survive into a new tool invocation by you. Either `source ~/.zshrc` or open a fresh `zsh -l`.

3. **Verify**:
   - `which nvim git starship uv cargo gh claude` — all should resolve
   - `nvim --version | head -1` — must be ≥ v0.11 (init.lua uses `vim.lsp.config` / `vim.lsp.enable`)
   - `zsh -ic 'echo $PROMPT'` — starship should be active
   - `ls -la ~/.zshrc ~/.gitconfig ~/.config/nvim/init.lua ~/.claude/CLAUDE.md` — should be symlinks pointing into the devenv repo
   - `claude plugin list` — should show `claude-bash-permissions`, `pyright-lsp`, `rust-analyzer-lsp`
   - Launch `nvim` once; lazy.nvim will bootstrap and install plugins. Wait for `:Lazy` to finish, then `:q`.

4. **Prompt Matt** to fill in `~/.config/devenv/secrets.env` (don't touch it yourself — secrets are his).

5. **Authenticate tools that need it** (ask before doing each):
   - `gh auth login` — github
   - `claude` — Matt logs into claude code himself; don't attempt it as the agent

## When things go wrong

- **Homebrew not on PATH after install on macOS**: `eval "$(/opt/homebrew/bin/brew shellenv)"`
- **Non-Debian linux**: bootstrap targets apt-get. On other distros, install the equivalents manually (zsh, neovim ≥0.11 from official release, ripgrep, fd, bat, fzf, jq, tree, btop, build-essential, pkg-config, libssl-dev, gh, starship) and then re-run from `install_rust` onward.
- **nvim plugins fail**: open nvim, run `:Lazy sync`, then `:Mason` to install LSP servers. If you see Lua errors about `vim.lsp.config`, your nvim is too old — re-run bootstrap (it fetches a fresh binary on linux) or upgrade on mac.
- **Symlink conflicts**: bootstrap moves existing files to `~/.devenv-backup-<timestamp>/`. If you see one of those, the old config is preserved there.
- **`claude plugin install` fails**: usually means the marketplace add didn't take. Re-run `claude plugin marketplace add <repo>` manually, then retry the install. Plugin list lives in `~/.claude/plugins/installed_plugins.json`.
- **Sound hooks**: `~/.claude/settings.json` runs `afplay` (mac) or `paplay` (linux) on Stop/Notification. Both fall back to `|| true` so missing audio is silent, not an error.

## Don't

- Don't commit anything to this repo without asking Matt.
- Don't put secrets in any tracked file. If you need to test that a secret works, source `secrets.env` and test, then make sure it's not in shell history.
- Don't auto-`brew install` random extra packages because they seem useful — keep `Brewfile` as the source of truth and ask before adding.

## Report back

When you're done, give a short summary:
- OS detected and what was installed
- Anything that failed and what you did about it
- What Matt needs to do next (fill secrets, `gh auth login`, etc.)
