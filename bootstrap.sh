#!/usr/bin/env bash
# Idempotent bootstrap for Matt's dev environment.
# Tested on macOS (Apple Silicon), Ubuntu/Debian, and Amazon Linux 2023.

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

install_debian_packages() {
    log "apt-get update"
    $SUDO apt-get update

    log "Installing apt packages"
    $SUDO apt-get install -y \
        git curl ca-certificates \
        zsh \
        ripgrep fd-find bat fzf jq tree btop \
        build-essential pkg-config libssl-dev \
        nodejs npm \
        software-properties-common \
        sound-theme-freedesktop

    install_nvim_linux
    install_gh_linux
    install_starship
    install_et_linux
}

# Amazon Linux 2023 (dnf). Its repos carry the basics (zsh, toolchain) but none
# of the modern CLI tools — ripgrep/fd/bat/eza/delta/difftastic come from cargo
# (see install_cargo_tools_linux), fzf/btop from upstream release binaries.
install_amazonlinux_packages() {
    log "dnf install base packages"
    # Note: no 'curl' — AL2023 ships curl-minimal (provides /usr/bin/curl), and
    # asking for full curl forces a conflicting erase.
    $SUDO dnf install -y \
        git ca-certificates zsh jq tree \
        gcc gcc-c++ make pkgconf-pkg-config openssl-devel
    # Don't disturb an existing node (box may manage it outside dnf).
    command -v node >/dev/null 2>&1 || $SUDO dnf install -y nodejs npm

    install_nvim_linux        # official tarball — AL2023's glibc 2.34 is new enough
    install_starship
    install_fzf_linux
    install_btop_linux

    # gh/et aren't in AL2023's default repos; they ship preinstalled on our box.
    command -v gh >/dev/null 2>&1 || warn "gh missing — add the cli.github.com dnf repo and 'dnf install gh'"
    command -v et >/dev/null 2>&1 || warn "et missing — no AL2023 package; build eternal-terminal from source if wanted"
}

# fzf's own installer fetches the right prebuilt binary for the platform.
install_fzf_linux() {
    command -v fzf >/dev/null 2>&1 && { log "fzf already installed"; return; }
    log "Installing fzf"
    rm -rf "$HOME/.fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" \
        && "$HOME/.fzf/install" --bin >/dev/null \
        && $SUDO ln -sf "$HOME/.fzf/bin/fzf" /usr/local/bin/fzf \
        || warn "fzf install failed — retry later with ~/.fzf/install --bin"
}

# btop ships a static musl binary per arch; asset names are version-independent.
install_btop_linux() {
    command -v btop >/dev/null 2>&1 && { log "btop already installed"; return; }
    log "Installing btop"
    local arch
    case "$(uname -m)" in
        x86_64)  arch="x86_64"  ;;
        aarch64) arch="aarch64" ;;
        *) warn "no btop binary for $(uname -m), skipping"; return ;;
    esac
    local tmpd; tmpd="$(mktemp -d)"
    { curl -fsSL "https://github.com/aristocratos/btop/releases/latest/download/btop-${arch}-unknown-linux-musl.tar.gz" -o "$tmpd/btop.tar.gz" \
        && tar -xzf "$tmpd/btop.tar.gz" -C "$tmpd" \
        && $SUDO install -m755 "$tmpd/btop/bin/btop" /usr/local/bin/btop; } || warn "btop install failed"
    rm -rf "$tmpd"
}

# Eternal terminal — survives network drops / roaming.
install_et_linux() {
    command -v et >/dev/null 2>&1 && { log "et already installed"; return; }
    log "Installing eternal terminal"
    # add-apt-repository -y runs apt-get update internally.
    $SUDO add-apt-repository -y ppa:jgmath2000/et
    $SUDO apt-get install -y et
}

# Pin to the 0.11.x line. Our nvim-treesitter is the archived master branch,
# whose query-directive handlers are incompatible with nvim 0.12's treesitter
# API — render-markdown crashes on .md files. The mac runs 0.11.x via brew, so
# match it here. (Ubuntu's apt nvim is too old regardless.) Revisit this pin
# alongside a treesitter-main migration, not on its own.
install_nvim_linux() {
    local nvim_version="v0.11.7"
    if command -v nvim >/dev/null 2>&1 && nvim --version | head -1 | grep -qF "${nvim_version#v}"; then
        log "nvim ${nvim_version} already installed"; return
    fi
    log "Installing neovim ${nvim_version} from official release"
    local arch tarball
    case "$(uname -m)" in
        x86_64)  arch="x86_64" ;;
        aarch64) arch="arm64"  ;;
        *) err "unsupported arch for nvim install: $(uname -m)" ;;
    esac
    tarball="nvim-linux-${arch}.tar.gz"
    curl -fsSL "https://github.com/neovim/neovim/releases/download/${nvim_version}/${tarball}" -o "/tmp/${tarball}"
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
    # Pipe through $SUDO so the installer doesn't try (and fail without a TTY)
    # to escalate on its own. Force install dir explicitly.
    curl -sS https://starship.rs/install.sh | $SUDO sh -s -- -y -b /usr/local/bin
}

install_packages() {
    case "$OS" in
        Darwin) install_macos_packages ;;
        Linux)
            if command -v apt-get >/dev/null 2>&1; then
                install_debian_packages
            elif command -v dnf >/dev/null 2>&1; then
                install_amazonlinux_packages
            else
                err "no supported package manager (apt-get or dnf) found"
            fi
            ;;
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

# Linux-only: cargo-managed tools the distro doesn't package at usable versions.
# eza/delta/difftastic are missing on both Debian and AL2023. AL2023 additionally
# lacks ripgrep/fd/bat (Debian gets those from apt), so build them here too.
install_cargo_tools_linux() {
    [ "$OS" = "Linux" ] || return 0
    local to_build=()
    command -v eza   >/dev/null 2>&1 || to_build+=(eza)
    command -v delta >/dev/null 2>&1 || to_build+=(git-delta)
    command -v difft >/dev/null 2>&1 || to_build+=(difftastic)
    if ! command -v apt-get >/dev/null 2>&1; then
        command -v rg  >/dev/null 2>&1 || to_build+=(ripgrep)
        command -v fd  >/dev/null 2>&1 || to_build+=(fd-find)
        command -v bat >/dev/null 2>&1 || to_build+=(bat)
    fi
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

# Pre-install nvim plugins, treesitter parsers, and mason LSPs so the editor
# is fully usable after first launch (no async surprises). Lazy auto-installs
# missing plugins during init.lua, so a single headless call covers everything.
warmup_nvim() {
    command -v nvim >/dev/null 2>&1 || { warn "nvim not on PATH, skipping warmup"; return; }
    # Lazy installs branch tips on first run, but lazy-lock.json pins known-good
    # commits — notably nvim-treesitter, whose master tip was archived without the
    # configs module our init.lua uses. Install everything, then restore to the
    # lockfile so the pinned (working) commits win before we build parsers.
    log "Installing + pinning nvim plugins to lazy-lock.json"
    nvim --headless "+Lazy! install" +qa </dev/null 2>/dev/null || warn "lazy install had issues"
    nvim --headless "+Lazy! restore" +qa </dev/null 2>/dev/null || warn "lazy restore had issues"
    log "Warming up nvim (treesitter parsers + mason LSPs — can take a few minutes)"
    nvim --headless -c "luafile $DEVENV_DIR/config/nvim/scripts/warmup.lua" -c "qa" </dev/null \
        || warn "nvim warmup had issues — retry via :Lazy / :Mason / :TSUpdate"
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

    # Ensure login bash sources .bashrc. Ubuntu's default .profile does this,
    # but rustup may overwrite .profile with just its env source. Create a
    # .bash_profile (bash prefers this) that explicitly sources both.
    local bash_profile="$HOME/.bash_profile"
    if [ ! -e "$bash_profile" ]; then
        log "creating ~/.bash_profile (sources .profile + .bashrc)"
        cat > "$bash_profile" <<'EOF'
# devenv: bash login profile.
[ -f "$HOME/.profile" ] && . "$HOME/.profile"
[ -f "$HOME/.bashrc"  ] && . "$HOME/.bashrc"
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
    symlink_configs
    install_claude_plugins
    warmup_nvim
    setup_shell

    log "Done. Open a new shell."
    log "Next: fill in ~/.config/devenv/secrets.env."
}

main "$@"
