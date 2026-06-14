#!/usr/bin/env bash
#
# Idempotent dotfiles installer / updater.
#
# Safe to run any number of times: every step checks current state first, then
# fixes / installs / updates only what's needed. On macOS it uses Homebrew; on
# Linux it uses the native package manager (apt/dnf/pacman) for base tools and
# falls back to Linuxbrew only for version-sensitive tools. Linux package
# installs require root — the script uses sudo and may prompt for a password.
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
# Use UNQUOTED ($SUDO cmd) so the empty-string case drops the word cleanly.
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

# Installed nvim version (x.y.z) on stdout, or return 1 if nvim is absent or unparseable.
nvim_version() {
  command -v nvim >/dev/null 2>&1 || return 1
  nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'
}

# Native-tier package list for the given PM (bootstrap + tools distros ship fine).
native_packages() {
  case "$1" in
    apt)    echo "git curl zsh tmux jq tree unzip build-essential wl-clipboard xclip fontconfig" ;;
    dnf)    echo "git curl zsh tmux jq tree unzip @development-tools wl-clipboard xclip fontconfig" ;;
    pacman) echo "git curl zsh tmux jq tree unzip base-devel wl-clipboard xclip fontconfig" ;;
  esac
}

# Refresh package metadata for the given PM.
pm_update() {
  case "$1" in
    apt)    $SUDO apt-get update ;;
    dnf)    $SUDO dnf -y makecache ;;
    pacman) : ;;   # no-op: pm_install runs an atomic -Syu so the DB is never synced without upgrading
  esac
}

# Install packages with the given PM: pm_install <pm> pkg...
pm_install() {
  local pm="$1"; shift
  case "$pm" in
    apt)    $SUDO apt-get install -y "$@" ;;
    dnf)    $SUDO dnf install -y "$@" ;;
    pacman) $SUDO pacman -Syu --needed --noconfirm "$@" ;;
  esac
}

# Ensure brew is available on Linux, installing Linuxbrew on first need.
ensure_linuxbrew() {
  command -v brew >/dev/null 2>&1 && return 0
  if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"; return 0
  fi
  info "Installing Homebrew (Linuxbrew) for version-sensitive tools..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    || { warn "Linuxbrew install failed"; return 1; }
  [ -x /home/linuxbrew/.linuxbrew/bin/brew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  command -v brew >/dev/null 2>&1
}

# Ensure the version-sensitive tools the configs depend on, brewing only laggards.
ensure_version_tools() {
  local v
  v="$(nvim_version || true)"
  if [ -n "$v" ] && version_ge "$v" "$MIN_NVIM"; then
    ok "neovim $v (>= $MIN_NVIM)"
  else
    info "neovim ${v:-absent} (< $MIN_NVIM) — installing via Homebrew"
    ensure_linuxbrew && brew install neovim && ok "neovim installed via brew" \
      || warn "could not install neovim >= $MIN_NVIM; treesitter may not work"
  fi

  # tree-sitter-cli (binary: tree-sitter) — needed for :TSUpdate to compile parsers
  if command -v tree-sitter >/dev/null 2>&1; then
    ok "tree-sitter-cli present"
  else
    info "tree-sitter-cli absent — installing via Homebrew"
    ensure_linuxbrew && brew install tree-sitter-cli && ok "tree-sitter-cli installed" \
      || warn "tree-sitter-cli install failed; parsers may not compile"
  fi

  # fzf must support `fzf --zsh` (>= 0.48), used by zshrc
  if command -v fzf >/dev/null 2>&1 && fzf --zsh >/dev/null 2>&1; then
    ok "fzf (supports --zsh)"
  else
    info "fzf missing or too old (no --zsh) — installing via Homebrew"
    ensure_linuxbrew && brew install fzf && ok "fzf installed via brew" \
      || warn "fzf install failed; Ctrl-R/Ctrl-T integration unavailable"
  fi

  # bat — referenced by config; native Debian ships it as `batcat`, so brew it
  if command -v bat >/dev/null 2>&1; then
    ok "bat present"
  else
    info "bat absent — installing via Homebrew"
    ensure_linuxbrew && brew install bat && ok "bat installed via brew" \
      || warn "bat install failed"
  fi
}

# Install JetBrainsMono Nerd Font into the user font dir if not already present.
install_nerd_font_linux() {
  if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
    ok "JetBrainsMono Nerd Font present"; return
  fi
  local dir="$HOME/.local/share/fonts" tmp
  mkdir -p "$dir"; tmp="$(mktemp -d)"
  info "Downloading JetBrainsMono Nerd Font..."
  if curl -fsSL -o "$tmp/JBM.zip" \
       https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip \
     && unzip -oq "$tmp/JBM.zip" -d "$dir"; then
    fc-cache -f "$dir" >/dev/null 2>&1
    ok "JetBrainsMono Nerd Font installed"
  else
    warn "Nerd Font install failed; install JetBrainsMono Nerd Font manually"
  fi
  rm -rf "$tmp"
}

# Read GitHub release JSON on stdin, echo the first Ubuntu AppImage asset URL.
appimage_url_filter() {
  grep -oE 'https://[^"]*Ubuntu[^"]*\.AppImage' | head -1
}

# Install wezterm on a Linux desktop: native repo per PM, AppImage as fallback.
install_wezterm_linux() {
  command -v wezterm >/dev/null 2>&1 && { ok "wezterm present"; return; }
  local pm="$1"
  case "$pm" in
    pacman)
      # wezterm is in Arch's official repos; a failure here is transient, and an
      # Ubuntu AppImage is the wrong remedy on Arch — so do not fall through.
      pm_install pacman wezterm && ok "wezterm installed (pacman)" \
        || warn "wezterm: pacman install failed"
      return ;;
    apt)
      # Only register the apt repo if we actually fetched a key — otherwise a
      # network failure would write a sources.list that poisons every future
      # `apt update`. On any failure, fall through to the AppImage (valid on Debian/Ubuntu).
      local key
      if key="$(curl -fsSL https://apt.fury.io/wez/gpg.key)" && [ -n "$key" ]; then
        printf '%s' "$key" | gpg --dearmor | $SUDO tee /usr/share/keyrings/wezterm-fury.gpg >/dev/null
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *" \
          | $SUDO tee /etc/apt/sources.list.d/wezterm.list >/dev/null
        $SUDO apt-get update \
          && pm_install apt wezterm && { ok "wezterm installed (apt repo)"; return; }
      fi ;;
    dnf)
      $SUDO dnf -y copr enable wezfurlong/wezterm-nightly \
        && pm_install dnf wezterm && { ok "wezterm installed (copr)"; return; } ;;
  esac
  warn "wezterm repo install unavailable; trying AppImage"
  local url
  url="$(curl -fsSL https://api.github.com/repos/wez/wezterm/releases/latest | appimage_url_filter)"
  if [ -n "$url" ]; then
    mkdir -p "$HOME/.local/bin"
    info "Downloading wezterm AppImage..."
    if curl -fsSL -o "$HOME/.local/bin/wezterm" "$url"; then
      chmod +x "$HOME/.local/bin/wezterm"
      ok "wezterm AppImage installed to ~/.local/bin/wezterm"; return
    fi
  fi
  warn "wezterm install failed; install manually from https://wezterm.org/install/linux.html"
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
# bash-only: `return` in a subshell succeeds only when the file is being sourced.
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
elif is_linux; then
  PM="$(detect_pm)" || die "Unsupported Linux: need apt, dnf, or pacman. Install base tools manually and re-run."
  info "Detected package manager: $PM"
  [ -n "$SUDO" ] && info "Privileged installs use sudo; you may be prompted for your password."
  pm_update "$PM" || warn "package metadata refresh failed (continuing)"
  # shellcheck disable=SC2046
  pm_install "$PM" $(native_packages "$PM") || die "native package install failed"
  ok "native tier installed"
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
elif is_linux; then
  ensure_version_tools
fi

# ----------------------------------------------------------------------------
# 2b. Fonts (Linux — macOS gets Nerd Fonts via Brewfile casks)
# ----------------------------------------------------------------------------
if is_linux; then
  step "Fonts"
  install_nerd_font_linux
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

# ----------------------------------------------------------------------------
# 8. wezterm (Linux desktop only — useless on a headless box)
# ----------------------------------------------------------------------------
if is_linux; then
  step "wezterm"
  if has_gui; then
    install_wezterm_linux "$PM"
  else
    info "No display detected (headless) — skipping wezterm install."
  fi
fi

step "Done"
ok "Dotfiles installed. Restart your terminal (and tmux) to pick everything up."
