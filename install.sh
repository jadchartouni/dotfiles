#!/usr/bin/env bash
#
# Idempotent dotfiles installer / updater.
#
# Safe to run any number of times: every step checks current state first, then
# fixes / installs / updates only what's needed. Homebrew runs on macOS only,
# so this also works on Linux (it just skips the brew step there).
#
# Run from a local checkout:
#   ./install.sh
#
# Or bootstrap a fresh machine directly (clones the repo first):
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/jadchartouni/dotfiles/main/install.sh)"
#
set -u

REPO_URL="https://github.com/jadchartouni/dotfiles.git"
BRANCH="main"
DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

# ----------------------------------------------------------------------------
# Output helpers
# ----------------------------------------------------------------------------
if [ -t 1 ]; then
  c_reset=$'\e[0m'; c_blue=$'\e[34m'; c_green=$'\e[32m'; c_yellow=$'\e[33m'
else
  c_reset=''; c_blue=''; c_green=''; c_yellow=''
fi
info() { printf '%s•%s %s\n' "$c_blue"   "$c_reset" "$*"; }
ok()   { printf '%s✓%s %s\n' "$c_green"  "$c_reset" "$*"; }
warn() { printf '%s!%s %s\n' "$c_yellow" "$c_reset" "$*"; }
step() { printf '\n%s══ %s ══%s\n' "$c_blue" "$*" "$c_reset"; }
die()  { warn "$*"; exit 1; }

is_macos() { [ "$(uname -s)" = "Darwin" ]; }
is_linux() { [ "$(uname -s)" = "Linux" ]; }
has_gui()  { [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; }

# Minimum Neovim for nvim-treesitter's `main` branch (parsers compiled via :TSUpdate).
MIN_NVIM="0.11"

# Run privileged package commands as root directly, otherwise via sudo.
if [ "$(id -u)" -eq 0 ]; then SUDO=""; else SUDO="sudo"; fi

# Detect the system package manager. Echoes apt|dnf|pacman, or returns 1.
detect_pm() {
  if   command -v apt-get >/dev/null 2>&1; then echo apt
  elif command -v dnf     >/dev/null 2>&1; then echo dnf
  elif command -v pacman  >/dev/null 2>&1; then echo pacman
  else return 1
  fi
}

# version_ge A B  -> success (0) when version A >= version B, comparing major.minor.
version_ge() {
  local a="$1" b="$2" a_major a_minor b_major b_minor a_rest b_rest
  a_major="${a%%.*}"; a_rest="${a#*.}"; a_minor="${a_rest%%.*}"
  b_major="${b%%.*}"; b_rest="${b#*.}"; b_minor="${b_rest%%.*}"
  a_major="${a_major//[!0-9]/}"; a_minor="${a_minor//[!0-9]/}"
  b_major="${b_major//[!0-9]/}"; b_minor="${b_minor//[!0-9]/}"
  a_major="${a_major:-0}"; a_minor="${a_minor:-0}"
  b_major="${b_major:-0}"; b_minor="${b_minor:-0}"
  if [ "$a_major" -gt "$b_major" ]; then return 0; fi
  if [ "$a_major" -lt "$b_major" ]; then return 1; fi
  [ "$a_minor" -ge "$b_minor" ]
}

# Installed nvim version (x.y.z) on stdout, or return 1 if nvim is absent.
nvim_version() {
  command -v nvim >/dev/null 2>&1 || return 1
  nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1
}

# ----------------------------------------------------------------------------
# Idempotent symlink: link <source> <destination>
#   - already the correct symlink -> leave it
#   - a different symlink         -> repoint it
#   - a real file/dir in the way  -> back it up (timestamped), then link
# ----------------------------------------------------------------------------
link() {
  local src="$1" dest="$2"
  if [ ! -e "$src" ]; then
    warn "source missing, skipping: $src"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    if [ "$(readlink "$dest")" = "$src" ]; then
      ok "already linked: $dest"
      return
    fi
    rm -f "$dest"
  elif [ -e "$dest" ]; then
    local backup="$dest.backup-$(date +%Y%m%d-%H%M%S)"
    mv "$dest" "$backup"
    warn "backed up existing $dest -> $backup"
  fi
  ln -s "$src" "$dest"
  ok "linked $dest -> $src"
}

# When sourced (e.g. by tests/test_helpers.sh) expose the helpers above and stop
# before performing any installation. When executed normally, continue.
if (return 0 2>/dev/null); then return 0; fi

# ----------------------------------------------------------------------------
# 0. Prerequisites: Homebrew (macOS) provides git; ensure git exists elsewhere
# ----------------------------------------------------------------------------
step "Prerequisites"
if is_macos; then
  if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew (also installs the Xcode CLT, which provides git)..."
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
      || die "Homebrew installation failed"
    # Make brew available in this session
    for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
      [ -x "$b" ] && eval "$("$b" shellenv)"
    done
    ok "Homebrew installed"
  else
    ok "Homebrew present"
  fi
fi
command -v git >/dev/null 2>&1 || die "git is required. Install it (e.g. 'sudo apt install git') and re-run."

# ----------------------------------------------------------------------------
# 1. Repository: use a local checkout if we're inside one, else clone/update
# ----------------------------------------------------------------------------
step "Repository"
SELF="${BASH_SOURCE[0]:-}"
if [ -n "$SELF" ] && [ -f "$SELF" ] && [ -f "$(cd "$(dirname "$SELF")" && pwd)/brew/Brewfile" ]; then
  DOTFILES="$(cd "$(dirname "$SELF")" && pwd)"
  ok "using local checkout: $DOTFILES"
elif [ -d "$DOTFILES/.git" ]; then
  info "updating $DOTFILES"
  git -C "$DOTFILES" pull --ff-only --quiet && ok "repo updated" || warn "could not fast-forward; leaving as-is"
else
  info "cloning $REPO_URL -> $DOTFILES"
  git clone --branch "$BRANCH" "$REPO_URL" "$DOTFILES" && ok "repo cloned" || die "clone failed"
fi

# ----------------------------------------------------------------------------
# 2. Packages (Homebrew — macOS only)
# ----------------------------------------------------------------------------
step "Packages"
if is_macos; then
  if brew bundle --file="$DOTFILES/brew/Brewfile"; then
    ok "Homebrew packages in sync"
  else
    warn "brew bundle reported problems (continuing)"
  fi
else
  info "Non-macOS ($(uname -s)) — skipping Homebrew."
  warn "Install equivalents with your package manager, e.g.: neovim tmux wezterm fzf + a Nerd Font"
fi

# ----------------------------------------------------------------------------
# 3. Shell (Oh My Zsh + plugins)
# ----------------------------------------------------------------------------
step "Shell (zsh)"
if [ -d "$HOME/.oh-my-zsh" ]; then
  ok "Oh My Zsh present"
else
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && ok "Oh My Zsh installed" || warn "Oh My Zsh install failed"
fi
ZSH_PLUGINS="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
for p in zsh-autosuggestions zsh-syntax-highlighting; do
  if [ -d "$ZSH_PLUGINS/$p/.git" ]; then
    git -C "$ZSH_PLUGINS/$p" pull --ff-only --quiet 2>/dev/null && ok "$p updated" || warn "$p update skipped"
  else
    git clone --depth 1 "https://github.com/zsh-users/$p" "$ZSH_PLUGINS/$p" >/dev/null 2>&1 \
      && ok "$p installed" || warn "$p clone failed"
  fi
done

# ----------------------------------------------------------------------------
# 4. Symlinks
# ----------------------------------------------------------------------------
step "Symlinks"
link "$DOTFILES/nvim"           "$HOME/.config/nvim"
link "$DOTFILES/wezterm"        "$HOME/.config/wezterm"
link "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"
link "$DOTFILES/zsh/zshrc"      "$HOME/.zshrc"
link "$DOTFILES/zsh/p10k.zsh"   "$HOME/.p10k.zsh"
link "$DOTFILES/zsh/zprofile"   "$HOME/.zprofile"

# ----------------------------------------------------------------------------
# 5. Git global ignore (setting the value is itself idempotent)
# ----------------------------------------------------------------------------
step "Git"
git config --global core.excludesfile "$DOTFILES/git/gitignore_global"
ok "core.excludesfile -> $DOTFILES/git/gitignore_global"

# ----------------------------------------------------------------------------
# 6. tmux plugin manager + plugins
# ----------------------------------------------------------------------------
step "tmux plugins"
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM_DIR/.git" ]; then
  git -C "$TPM_DIR" pull --ff-only --quiet 2>/dev/null && ok "TPM updated" || warn "TPM update skipped"
else
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR" >/dev/null 2>&1 && ok "TPM installed" || warn "TPM clone failed"
fi
if command -v tmux >/dev/null 2>&1 && [ -x "$TPM_DIR/bin/install_plugins" ]; then
  # Throwaway session so install works whether or not a server is already up,
  # without disturbing existing sessions.
  tmux new-session -d -s __install 2>/dev/null || true
  "$TPM_DIR/bin/install_plugins" >/dev/null 2>&1 && ok "tmux plugins installed/updated" \
    || warn "could not auto-install tmux plugins; press prefix + I inside tmux"
  tmux kill-session -t __install 2>/dev/null || true
fi

# ----------------------------------------------------------------------------
# 7. Neovim plugins (lazy.nvim install + sync to lockfile)
# ----------------------------------------------------------------------------
step "Neovim plugins"
if command -v nvim >/dev/null 2>&1; then
  nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 && ok "Neovim plugins synced" \
    || warn "Neovim plugin sync had issues; open nvim and run :Lazy"
else
  warn "nvim not installed; skipping plugin sync"
fi

step "Done"
ok "Dotfiles installed. Restart your terminal (and tmux) to pick everything up."
