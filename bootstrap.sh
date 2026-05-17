#!/usr/bin/env bash
# Idempotent bootstrap for Matt's dev environment.
# Tested on macOS (Apple Silicon) and Ubuntu/Debian.

set -euo pipefail

DEVENV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.devenv-backup-$(date +%Y%m%d-%H%M%S)"
OS="$(uname -s)"

# Empty when running as root, "sudo" otherwise.
SUDO="$(command -v sudo 2>/dev/null || true)"
[ "$(id -u)" = "0" ] && SUDO=""

# Hoist user-installer bins onto PATH so commands installed earlier in this
# script are visible to checks ('command -v ...') later in the same run.
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
err()  { printf '\033[1;31mxx\033[0m  %s\n' "$*" >&2; exit 1; }

# ---------- package install ----------

install_macos_packages() {
    if ! command -v brew >/dev/null 2>&1; then
        log "Installing Homebrew"
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    log "Installing Brewfile"
    brew bundle --file="$DEVENV_DIR/Brewfile"
}

install_linux_packages() {
    command -v apt-get >/dev/null 2>&1 || err "apt-get not found; this bootstrap targets Debian/Ubuntu"

    log "apt-get update"
    $SUDO apt-get update

    log "Installing apt packages"
    $SUDO apt-get install -y \
        git curl ca-certificates \
        zsh \
        ripgrep fd-find bat fzf jq tree btop \
        build-essential pkg-config libssl-dev \
        sound-theme-freedesktop

    install_nvim_linux
    install_gh_linux
    install_starship
}

# Ubuntu's apt ships nvim too old for our init.lua (needs ≥ 0.11).
# Install the official prebuilt tarball to /usr/local/nvim.
install_nvim_linux() {
    if command -v nvim >/dev/null 2>&1 && nvim --version | head -1 | awk '{print $2}' | grep -qE 'v(0\.(1[1-9]|[2-9][0-9])|[1-9])'; then
        log "nvim already new enough"; return
    fi
    log "Installing neovim from official release"
    local arch tarball
    case "$(uname -m)" in
        x86_64)  arch="x86_64" ;;
        aarch64) arch="arm64"  ;;
        *) err "unsupported arch for nvim install: $(uname -m)" ;;
    esac
    tarball="nvim-linux-${arch}.tar.gz"
    curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/${tarball}" -o "/tmp/${tarball}"
    $SUDO rm -rf /usr/local/nvim
    $SUDO mkdir -p /usr/local/nvim
    $SUDO tar -xzf "/tmp/${tarball}" -C /usr/local/nvim --strip-components=1
    $SUDO ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim
    rm -f "/tmp/${tarball}"
}

install_gh_linux() {
    command -v gh >/dev/null 2>&1 && { log "gh already installed"; return; }
    log "Installing gh"
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | $SUDO dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    $SUDO chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | $SUDO tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    $SUDO apt-get update && $SUDO apt-get install -y gh
}

install_starship() {
    command -v starship >/dev/null 2>&1 && { log "starship already installed"; return; }
    log "Installing starship"
    curl -sS https://starship.rs/install.sh | sh -s -- -y
}

install_packages() {
    case "$OS" in
        Darwin) install_macos_packages ;;
        Linux)  install_linux_packages ;;
        *)      err "Unsupported OS: $OS" ;;
    esac
}

# ---------- toolchains ----------

install_rust() {
    command -v rustc >/dev/null 2>&1 && { log "rust already installed"; return; }
    log "Installing rustup"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
}

install_uv() {
    command -v uv >/dev/null 2>&1 && { log "uv already installed"; return; }
    log "Installing uv"
    curl -LsSf https://astral.sh/uv/install.sh | sh
}

# Linux-only: cargo-managed tools not in Ubuntu apt with up-to-date versions.
install_cargo_tools_linux() {
    [ "$OS" = "Linux" ] || return 0
    local to_build=()
    command -v eza   >/dev/null 2>&1 || to_build+=(eza)
    command -v delta >/dev/null 2>&1 || to_build+=(git-delta)
    command -v difft >/dev/null 2>&1 || to_build+=(difftastic)
    [ ${#to_build[@]} -eq 0 ] && { log "cargo tools already installed"; return; }
    log "Building ${to_build[*]} from source (this can take several minutes)"
    for tool in "${to_build[@]}"; do
        cargo install "$tool" --locked
    done
}

# ---------- claude tooling ----------

install_claude_code() {
    command -v claude >/dev/null 2>&1 && { log "claude already installed"; return; }
    log "Installing claude code"
    curl -fsSL https://claude.ai/install.sh | bash
}

install_claudechic() {
    command -v claudechic >/dev/null 2>&1 && { log "claudechic already installed"; return; }
    log "Installing claudechic"
    uv tool install claudechic
}

install_claude_plugins() {
    command -v claude >/dev/null 2>&1 || { warn "claude not on PATH, skipping plugin install"; return; }

    log "Adding claude plugin marketplaces"
    claude plugin marketplace add anthropics/claude-plugins-official >/dev/null 2>&1 || true
    claude plugin marketplace add mrocklin/claude-bash-permissions   >/dev/null 2>&1 || true

    log "Installing claude plugins"
    claude plugin install claude-bash-permissions@mrocklin          >/dev/null 2>&1 || warn "claude-bash-permissions install failed"
    claude plugin install pyright-lsp@claude-plugins-official       >/dev/null 2>&1 || warn "pyright-lsp install failed"
    claude plugin install rust-analyzer-lsp@claude-plugins-official >/dev/null 2>&1 || warn "rust-analyzer-lsp install failed"
}

# ---------- symlinks ----------

link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ]; then
        [ "$(readlink "$dst")" = "$src" ] && return 0
        rm "$dst"
    elif [ -e "$dst" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "$BACKUP_DIR/"
        warn "Backed up existing $dst to $BACKUP_DIR"
    fi
    ln -s "$src" "$dst"
    log "linked $dst -> $src"
}

# Copy-once: seed a file if it doesn't exist. Used for files Claude mutates.
seed() {
    local src="$1" dst="$2"
    if [ -e "$dst" ]; then return 0; fi
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    log "seeded $dst (copy, not symlink — claude may rewrite this)"
}

symlink_configs() {
    # Shell
    link "$DEVENV_DIR/config/zshrc"          "$HOME/.zshrc"
    link "$DEVENV_DIR/config/zshenv"         "$HOME/.zshenv"
    link "$DEVENV_DIR/config/starship.toml"  "$HOME/.config/starship.toml"

    # Git
    link "$DEVENV_DIR/config/gitconfig"      "$HOME/.gitconfig"
    link "$DEVENV_DIR/config/git-ignore"     "$HOME/.config/git/ignore"

    # Editors / tools
    link "$DEVENV_DIR/config/nvim"           "$HOME/.config/nvim"
    link "$DEVENV_DIR/config/gh/config.yml"  "$HOME/.config/gh/config.yml"

    # Claude — static content is symlinked; settings.json is seeded (claude mutates it)
    link "$DEVENV_DIR/config/claude/CLAUDE.md"        "$HOME/.claude/CLAUDE.md"
    link "$DEVENV_DIR/config/claude/commands"         "$HOME/.claude/commands"
    link "$DEVENV_DIR/config/claude/skills"           "$HOME/.claude/skills"
    link "$DEVENV_DIR/config/claude/claudechic.yaml"  "$HOME/.claude/.claudechic.yaml"
    seed "$DEVENV_DIR/config/claude/settings.json"    "$HOME/.claude/settings.json"

    if [ "$OS" = "Darwin" ]; then
        link "$DEVENV_DIR/config/aerospace.toml" "$HOME/.aerospace.toml"
        link "$DEVENV_DIR/config/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
    fi

    # Secrets file scaffolding (never overwritten)
    mkdir -p "$HOME/.config/devenv"
    if [ ! -e "$HOME/.config/devenv/secrets.env" ]; then
        cp "$DEVENV_DIR/config/secrets.env.example" "$HOME/.config/devenv/secrets.env"
        chmod 600 "$HOME/.config/devenv/secrets.env"
        log "created ~/.config/devenv/secrets.env (fill in real values)"
    fi
}

# ---------- shell selection ----------

setup_shell() {
    command -v zsh >/dev/null 2>&1 || { warn "zsh not installed, skipping shell setup"; return; }
    [ "$OS" = "Darwin" ] && return   # macOS default is already zsh

    # Linux: drop a trampoline into .bashrc that execs zsh for interactive shells.
    # Avoids needing chsh (no sudo, no re-login).
    local marker='# devenv: exec into zsh'
    local bashrc="$HOME/.bashrc"
    touch "$bashrc"
    if ! grep -qF "$marker" "$bashrc"; then
        log "adding zsh exec trampoline to ~/.bashrc"
        cat >> "$bashrc" <<EOF

$marker
if [ -n "\$PS1" ] && [ -z "\$ZSH_VERSION" ] && command -v zsh >/dev/null 2>&1; then
    exec zsh -l
fi
EOF
    fi
}

# ---------- main ----------

main() {
    log "devenv bootstrap on $OS"
    log "repo: $DEVENV_DIR"

    install_packages
    install_rust
    install_uv
    install_cargo_tools_linux
    install_claude_code
    install_claudechic
    symlink_configs
    install_claude_plugins
    setup_shell

    log "Done. Open a new shell."
    log "Next: fill in ~/.config/devenv/secrets.env, then run 'nvim' once to install plugins."
}

main "$@"
