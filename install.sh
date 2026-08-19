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

# arch_regex [machine] -> grep -E alternation matching this machine's flavor in
# release asset names (projects disagree: x86_64/amd64/x64, aarch64/arm64).
arch_regex() {
  local m="${1:-$(uname -m)}"
  case "$m" in
    x86_64|amd64|x64) echo "(x86_64|amd64|x64)" ;;
    aarch64|arm64)    echo "(aarch64|arm64)" ;;
    *)                echo "$m" ;;
  esac
}

# expand_arch <pattern> [machine] -> pattern with {arch} -> arch_regex output.
expand_arch() {
  local re; re="$(arch_regex "${2:-}")"
  printf '%s\n' "${1//\{arch\}/$re}"
}

# native_for_pm <pm> <field> -> native package name for this PM.
# field is "-" (no native package), a bare name (same on every PM), or
# per-PM overrides "apt:x,dnf:y,pacman:z" (PM not listed -> no candidate).
native_for_pm() {
  local pm="$1" field="$2" part
  [ "$field" = "-" ] && return 1
  case "$field" in
    *:*)
      local IFS=','
      for part in $field; do
        case "$part" in "$pm":*) echo "${part#"$pm":}"; return 0 ;; esac
      done
      return 1 ;;
    *) echo "$field" ;;
  esac
}

# Installed nvim version (x.y.z) on stdout, or return 1 if nvim is absent or unparseable.
nvim_version() {
  command -v nvim >/dev/null 2>&1 || return 1
  nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'
}

# cmd_version <cmd> -> first x.y[.z] in `<cmd> --version`, or failure.
cmd_version() {
  command -v "$1" >/dev/null 2>&1 || return 1
  "$1" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1
  # grep in a pipeline: rely on output emptiness, not exit status
}

# pkg_satisfied <check> <min> -> success when <check> exists and meets <min>.
# min "-" means any version. A probe that yields no version fails the check.
pkg_satisfied() {
  local check="$1" min="$2" v
  command -v "$check" >/dev/null 2>&1 || return 1
  [ "$min" = "-" ] && return 0
  v="$(cmd_version "$check")"
  [ -n "$v" ] || return 1
  version_ge "$v" "$min"
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

# Read GitHub release JSON on stdin, echo the first browser_download_url whose
# value matches the given extended regex. Returns 1 when nothing matches.
gh_url_filter() {
  grep -oE '"browser_download_url" *: *"[^"]+"' \
    | grep -oE 'https://[^"]+' \
    | grep -E -m1 "$1"
}

# asset_kind <url> -> targz | gz | bin, by extension.
asset_kind() {
  case "$1" in
    *.tar.gz|*.tgz) echo targz ;;
    *.gz)           echo gz ;;
    *)              echo bin ;;
  esac
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
# Manifest-driven package resolution (Linux). See linux/packages.conf.
# ----------------------------------------------------------------------------

# install_gh_release <name> <check> <owner/repo:asset-regex>
# Latest-release asset -> ~/.local/bin (single binaries, flat tarballs) or
# ~/.local/opt/<name> with bin/* symlinked (tarballs with a directory tree).
install_gh_release() {
  local name="$1" check="$2" spec="$3"
  local repo="${spec%%:*}" pattern="${spec#*:}" url tmp bindir="$HOME/.local/bin"
  pattern="$(expand_arch "$pattern")"
  url="$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | gh_url_filter "$pattern")" \
    || { warn "$name: no release asset matching $pattern"; return 1; }
  tmp="$(mktemp -d)" || return 1
  mkdir -p "$bindir"
  info "$name: downloading ${url##*/}"
  if ! curl -fsSL -o "$tmp/asset" "$url"; then warn "$name: download failed"; rm -rf "$tmp"; return 1; fi
  case "$(asset_kind "$url")" in
    targz)
      tar -xzf "$tmp/asset" -C "$tmp" || { warn "$name: extract failed"; rm -rf "$tmp"; return 1; }
      local tree
      tree="$(find "$tmp" -maxdepth 2 -type d -name bin | head -1)"
      if [ -n "$tree" ]; then
        # Full tree (e.g. neovim): keep it in ~/.local/opt, symlink executables.
        rm -rf "$HOME/.local/opt/$name"; mkdir -p "$HOME/.local/opt"
        mv "$(dirname "$tree")" "$HOME/.local/opt/$name"
        local exe
        for exe in "$HOME/.local/opt/$name/bin/"*; do
          [ -x "$exe" ] && ln -sf "$exe" "$bindir/$(basename "$exe")"
        done
      else
        local bin
        bin="$(find "$tmp" -maxdepth 2 -type f -name "$check" | head -1)"
        [ -n "$bin" ] || { warn "$name: no '$check' binary in archive"; rm -rf "$tmp"; return 1; }
        install -m 755 "$bin" "$bindir/$check"
      fi ;;
    gz)
      gunzip -c "$tmp/asset" > "$bindir/$check" || { warn "$name: gunzip failed"; rm -rf "$tmp"; return 1; }
      chmod +x "$bindir/$check" ;;
    bin)
      install -m 755 "$tmp/asset" "$bindir/$check" ;;
  esac
  rm -rf "$tmp"
}

# resolve_packages <pm> <manifest>
# Tier order per entry: already satisfied -> native (batched) -> GitHub
# release -> Linuxbrew (x86_64 only). One tool's failure never aborts.
resolve_packages() {
  local pm="$1" manifest="$2"
  local name check min native gh pkg pkg2 batch=""
  export PATH="$HOME/.local/bin:$PATH"

  # Pass 1: everything the native PM should provide, in one transaction.
  while read -r name check min native gh; do
    case "$name" in ''|\#*) continue ;; esac
    if [ "$check" != "-" ] && pkg_satisfied "$check" "$min"; then continue; fi
    pkg="$(native_for_pm "$pm" "$native")" && batch="$batch $pkg"
  done < "$manifest"
  if [ -n "$batch" ]; then
    # shellcheck disable=SC2086
    if ! pm_install "$pm" $batch; then
      warn "batch install failed — retrying packages individually"
      for pkg2 in $batch; do
        pm_install "$pm" "$pkg2" || warn "$pkg2: native install failed"
      done
    fi
  fi

  # Pass 2: verify each probed tool; fall back per entry.
  while read -r name check min native gh; do
    case "$name" in ''|\#*) continue ;; esac
    [ "$check" = "-" ] && continue
    if pkg_satisfied "$check" "$min"; then ok "$name $(cmd_version "$check" || echo present)"; continue; fi
    if [ "$gh" != "-" ] && install_gh_release "$name" "$check" "$gh" && pkg_satisfied "$check" "$min"; then
      ok "$name installed from GitHub release"; continue
    fi
    if [ "$(uname -m)" = "x86_64" ] && ensure_linuxbrew && brew install "$name" && pkg_satisfied "$check" "$min"; then
      ok "$name installed via Linuxbrew"; continue
    fi
    warn "$name: could not satisfy (check '$check', min $min) — install manually"
  done < "$manifest"
}

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
  pm_install "$PM" git curl unzip ca-certificates || die "bootstrap package install failed"
  ok "bootstrap tier installed (git curl unzip)"
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
  resolve_packages "$PM" "$DOTFILES/linux/packages.conf"
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
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
ZSH_PLUGINS="$ZSH_CUSTOM_DIR/plugins"
for p in zsh-autosuggestions zsh-syntax-highlighting; do
  if [ -d "$ZSH_PLUGINS/$p/.git" ]; then
    git -C "$ZSH_PLUGINS/$p" pull --ff-only --quiet 2>/dev/null && ok "$p updated" || warn "$p update skipped"
  else
    git clone --depth 1 "https://github.com/zsh-users/$p" "$ZSH_PLUGINS/$p" >/dev/null 2>&1 \
      && ok "$p installed" || warn "$p clone failed"
  fi
done

# Powerlevel10k theme (referenced by zshrc as ZSH_THEME="powerlevel10k/powerlevel10k").
P10K_DIR="$ZSH_CUSTOM_DIR/themes/powerlevel10k"
if [ -d "$P10K_DIR/.git" ]; then
  git -C "$P10K_DIR" pull --ff-only --quiet 2>/dev/null && ok "powerlevel10k updated" || warn "powerlevel10k update skipped"
else
  git clone --depth 1 "https://github.com/romkatv/powerlevel10k" "$P10K_DIR" >/dev/null 2>&1 \
    && ok "powerlevel10k installed" || warn "powerlevel10k clone failed"
fi

# ----------------------------------------------------------------------------
# 4. Symlinks
# ----------------------------------------------------------------------------
step "Symlinks"
link "$DOTFILES/nvim"           "$HOME/.config/nvim"
link "$DOTFILES/wezterm"        "$HOME/.config/wezterm"
link "$DOTFILES/btop"           "$HOME/.config/btop"
link "$DOTFILES/yazi"           "$HOME/.config/yazi"
link "$DOTFILES/eza"            "$HOME/.config/eza"
link "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"
link "$DOTFILES/zsh/zshrc"      "$HOME/.zshrc"
link "$DOTFILES/zsh/p10k.zsh"   "$HOME/.p10k.zsh"
link "$DOTFILES/zsh/zprofile"   "$HOME/.zprofile"

# Obsidian SentryCore snippet — only on machines where the iCloud vault exists.
# (iCloud won't sync the symlink to other devices; it's a local convenience.)
OBSIDIAN_VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault"
if [ -d "$OBSIDIAN_VAULT/.obsidian" ]; then
  link "$DOTFILES/obsidian/sentrycore.css" "$OBSIDIAN_VAULT/.obsidian/snippets/sentrycore.css"
fi

# Cursor SentryCore theme — linked as an unpacked extension, only if Cursor exists.
if [ -d "$HOME/.cursor/extensions" ]; then
  link "$DOTFILES/cursor" "$HOME/.cursor/extensions/sentrycore-theme"
fi

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
# 8. Raycast visual settings (macOS only, and only if Raycast is installed)
# ----------------------------------------------------------------------------
if is_macos && [ -d "/Applications/Raycast.app" ]; then
  step "Raycast"
  bash "$DOTFILES/raycast/settings.sh" && ok "Raycast visual settings applied" \
    || warn "Raycast settings failed"
fi

# ----------------------------------------------------------------------------
# 9. wezterm (Linux desktop only — useless on a headless box)
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
