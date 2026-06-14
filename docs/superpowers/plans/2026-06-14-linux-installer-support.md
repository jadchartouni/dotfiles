# Linux Installer Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `install.sh` and the configs install and work on Linux (apt/dnf/pacman, headless and desktop) without regressing the macOS path.

**Architecture:** Add a detection layer and Linux branches inside the existing flat `install.sh` (kept single-file so the `curl | bash` bootstrap still works). Linux uses a hybrid package strategy: native PM for base/system tools, Linuxbrew only as a fallback for version-sensitive tools (neovim ≥ 0.11, tree-sitter-cli, fzf with `--zsh`, bat). Pure helper functions are unit-tested via a source-guard; imperative install steps are verified with shellcheck and per-distro container runs.

**Tech Stack:** Bash, apt/dnf/pacman, Homebrew (Linuxbrew), WezTerm Lua config, shellcheck, Docker containers for integration testing.

---

## File Structure

- **Modify** `install.sh` — all installer logic. New detection helpers + source-guard near the top; Linux branches added to the Prerequisites and Packages steps; two new steps (Fonts, wezterm) gated to Linux.
- **Modify** `zsh/zprofile` — add a Linuxbrew `shellenv` branch so brew-installed tools are on PATH in future shells.
- **Modify** `wezterm/wezterm.lua` — OS-gate the leader key (CMD on macOS, SUPER on Linux) and the macOS-only blur.
- **Create** `tests/test_helpers.sh` — plain-bash unit tests for the pure helper functions (`version_ge`, `native_packages`, `appimage_url_filter`). No test framework dependency.
- **Create** `tests/README.md` — how to run the unit tests and the container integration matrix.

A note on testing philosophy for this plan: an OS installer mutates the system and needs root + real package managers, so it cannot be fully unit-tested. The plan applies real TDD to the **pure helper functions** (Tasks 1–2), and verifies the **imperative steps** with `shellcheck` (static) plus **per-distro Docker runs** (Task 9, integration). This is called out so the lighter per-step verification on imperative tasks is understood, not mistaken for a gap.

---

## Task 1: Detection helpers, source-guard, and version comparison

**Files:**
- Modify: `install.sh` (helpers section, after the output helpers around line 35)
- Create: `tests/test_helpers.sh`

- [ ] **Step 1: Write the failing unit test for `version_ge` and detection helpers**

Create `tests/test_helpers.sh`:

```bash
#!/usr/bin/env bash
# Unit tests for the pure helper functions in install.sh.
# Sources install.sh (which stops early when sourced) and asserts on helpers.
set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$HERE/../install.sh"

fails=0
check() { # check <description> <expected> <actual>
  if [ "$2" = "$3" ]; then
    printf 'ok   - %s\n' "$1"
  else
    printf 'FAIL - %s (expected %q, got %q)\n' "$1" "$2" "$3"; fails=$((fails+1))
  fi
}
check_true()  { if "$@"; then printf 'ok   - %s\n' "$*"; else printf 'FAIL - %s (expected true)\n' "$*"; fails=$((fails+1)); fi; }
check_false() { if "$@"; then printf 'FAIL - %s (expected false)\n' "$*"; fails=$((fails+1)); else printf 'ok   - %s\n' "$*"; fi; }

# version_ge A B -> success when A >= B (major.minor)
check_true  version_ge 0.11.0 0.11
check_true  version_ge 0.11.2 0.11
check_true  version_ge 0.12.0 0.11
check_true  version_ge 1.0.0  0.11
check_false version_ge 0.10.4 0.11
check_false version_ge 0.9.5  0.11
check_true  version_ge 0.11   0.11

echo
if [ "$fails" -eq 0 ]; then echo "ALL PASS"; exit 0; else echo "$fails FAILURE(S)"; exit 1; fi
```

- [ ] **Step 2: Run the test, verify it fails**

Run: `bash tests/test_helpers.sh`
Expected: FAIL — `source: ... install.sh` runs the whole installer (no source-guard yet) and/or `version_ge: command not found`.

- [ ] **Step 3: Add the source-guard and helpers to `install.sh`**

In `install.sh`, immediately after the existing `is_macos()` definition (line 35), add:

```bash
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
```

Then, at the boundary where imperative work begins — immediately **before** `step "Prerequisites"` (currently line 68) — insert the source-guard:

```bash
# When sourced (e.g. by tests/test_helpers.sh) expose the helpers above and stop
# before performing any installation. When executed normally, continue.
if (return 0 2>/dev/null); then return 0; fi
```

- [ ] **Step 4: Run the test, verify it passes**

Run: `bash tests/test_helpers.sh`
Expected: PASS — all `version_ge` checks report `ok`, final line `ALL PASS`.

- [ ] **Step 5: Lint**

Run: `shellcheck install.sh tests/test_helpers.sh`
Expected: no errors (SC1091 in the test is suppressed via the inline directive).

- [ ] **Step 6: Commit**

```bash
git add install.sh tests/test_helpers.sh
git commit -m "Add Linux detection helpers, version compare, and source-guard"
```

---

## Task 2: Native-tier package mapping (pure) + unit test

**Files:**
- Modify: `install.sh` (helpers section)
- Modify: `tests/test_helpers.sh`

- [ ] **Step 1: Add failing tests for `native_packages`**

Append to `tests/test_helpers.sh`, before the final summary block:

```bash
# native_packages <pm> -> space-separated package list for that PM
check_true  bash -c '[ -n "$(native_packages apt)" ]'
check_true  bash -c 'native_packages apt    | grep -q build-essential'
check_true  bash -c 'native_packages dnf    | grep -q "@development-tools"'
check_true  bash -c 'native_packages pacman | grep -q base-devel'
check_true  bash -c 'native_packages apt    | grep -q wl-clipboard'
check_true  bash -c 'native_packages pacman | grep -q fontconfig'
```

(These run in subshells that re-source install.sh; that is fine — they assert the function exists and maps correctly.)

Note: subshell `bash -c` invocations do NOT inherit `native_packages` from the parent shell. Change them to call the function in-process instead:

```bash
check_true  test -n "$(native_packages apt)"
check_nonempty() { if native_packages "$1" | grep -q "$2"; then printf 'ok   - native_packages %s has %s\n' "$1" "$2"; else printf 'FAIL - native_packages %s missing %s\n' "$1" "$2"; fails=$((fails+1)); fi; }
check_nonempty apt    build-essential
check_nonempty dnf    "@development-tools"
check_nonempty pacman base-devel
check_nonempty apt    wl-clipboard
check_nonempty pacman fontconfig
```

- [ ] **Step 2: Run the test, verify it fails**

Run: `bash tests/test_helpers.sh`
Expected: FAIL — `native_packages: command not found`.

- [ ] **Step 3: Add `native_packages` and PM action helpers to `install.sh`**

In the helpers section (after `nvim_version`), add:

```bash
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
    apt)    $SUDO apt-get update -y ;;
    dnf)    $SUDO dnf -y makecache ;;
    pacman) $SUDO pacman -Sy --noconfirm ;;
  esac
}

# Install packages with the given PM: pm_install <pm> pkg...
pm_install() {
  local pm="$1"; shift
  case "$pm" in
    apt)    $SUDO apt-get install -y "$@" ;;
    dnf)    $SUDO dnf install -y "$@" ;;
    pacman) $SUDO pacman -S --needed --noconfirm "$@" ;;
  esac
}
```

- [ ] **Step 4: Run the test, verify it passes**

Run: `bash tests/test_helpers.sh`
Expected: PASS — `native_packages` checks all `ok`, final `ALL PASS`.

- [ ] **Step 5: Lint and commit**

```bash
shellcheck install.sh tests/test_helpers.sh
git add install.sh tests/test_helpers.sh
git commit -m "Add native-tier package mapping and PM action helpers"
```

---

## Task 3: Linux branch in the Prerequisites step

**Files:**
- Modify: `install.sh` (header comment + Prerequisites step, around lines 1–14 and 68–84)

- [ ] **Step 1: Update the header comment to mention Linux + sudo**

Replace the existing comment block lines 6–7:

```bash
# fixes / installs / updates only what's needed. Homebrew runs on macOS only,
# so this also works on Linux (it just skips the brew step there).
```

with:

```bash
# fixes / installs / updates only what's needed. On macOS it uses Homebrew; on
# Linux it uses the native package manager (apt/dnf/pacman) for base tools and
# falls back to Linuxbrew only for version-sensitive tools. Linux package
# installs require root — the script uses sudo and may prompt for a password.
```

- [ ] **Step 2: Add the Linux branch to the Prerequisites step**

In the Prerequisites step, the current code is:

```bash
step "Prerequisites"
if is_macos; then
  if ! command -v brew >/dev/null 2>&1; then
    ...
  else
    ok "Homebrew present"
  fi
fi
command -v git >/dev/null 2>&1 || die "git is required. Install it (e.g. 'sudo apt install git') and re-run."
```

Insert an `elif is_linux; then` branch before the final `command -v git` line:

```bash
step "Prerequisites"
if is_macos; then
  if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew (also installs the Xcode CLT, which provides git)..."
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
      || die "Homebrew installation failed"
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
  # shellcheck disable=SC2046
  pm_update "$PM" || warn "package metadata refresh failed (continuing)"
  # shellcheck disable=SC2046
  pm_install "$PM" $(native_packages "$PM") || die "native package install failed"
  ok "native tier installed"
fi
command -v git >/dev/null 2>&1 || die "git is required. Install it (e.g. 'sudo apt install git') and re-run."
```

(The `$(native_packages ...)` is intentionally unquoted to word-split into args; SC2046 is suppressed.)

- [ ] **Step 3: Lint**

Run: `shellcheck install.sh`
Expected: no errors.

- [ ] **Step 4: Verify the macOS path is unaffected (dry reasoning + re-run)**

Run on macOS: `./install.sh`
Expected: takes the `is_macos` branch exactly as before (`Homebrew present`), never prints `Detected package manager`. The `elif is_linux` branch is not reached.

- [ ] **Step 5: Commit**

```bash
git add install.sh
git commit -m "Install native-tier packages on Linux in Prerequisites step"
```

---

## Task 4: Linuxbrew shellenv in zprofile

**Files:**
- Modify: `zsh/zprofile`

- [ ] **Step 1: Add the Linuxbrew branch**

The current file is:

```bash
# Login-shell environment.

# Homebrew (Apple Silicon → /opt/homebrew, Intel → /usr/local)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
```

Replace with:

```bash
# Login-shell environment.

# Homebrew (Apple Silicon → /opt/homebrew, Intel → /usr/local, Linuxbrew → /home/linuxbrew)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
```

- [ ] **Step 2: Verify syntax**

Run: `zsh -n zsh/zprofile`
Expected: no output (valid syntax).

- [ ] **Step 3: Commit**

```bash
git add zsh/zprofile
git commit -m "Add Linuxbrew shellenv branch to zprofile"
```

---

## Task 5: Version-tier resolution (Linuxbrew fallback) in the Packages step

**Files:**
- Modify: `install.sh` (helpers section + Packages step, around lines 102–115)

- [ ] **Step 1: Add `ensure_linuxbrew` and `ensure_version_tools` helpers**

In the helpers section (after `pm_install`), add:

```bash
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
```

- [ ] **Step 2: Add the Linux branch to the Packages step**

Current Packages step:

```bash
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
```

Replace the `else` branch with an `elif is_linux` branch:

```bash
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
```

- [ ] **Step 3: Lint**

Run: `shellcheck install.sh`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add install.sh
git commit -m "Resolve version-sensitive tools via Linuxbrew fallback on Linux"
```

---

## Task 6: Nerd Font installation on Linux

**Files:**
- Modify: `install.sh` (helpers section + new Fonts step)

- [ ] **Step 1: Add the `install_nerd_font_linux` helper**

In the helpers section, add:

```bash
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
```

- [ ] **Step 2: Add the Fonts step (Linux only) after the Packages step**

Immediately after the Packages step's closing `fi`, add:

```bash
# ----------------------------------------------------------------------------
# 2b. Fonts (Linux — macOS gets Nerd Fonts via Brewfile casks)
# ----------------------------------------------------------------------------
if is_linux; then
  step "Fonts"
  install_nerd_font_linux
fi
```

- [ ] **Step 3: Lint**

Run: `shellcheck install.sh`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add install.sh
git commit -m "Install JetBrainsMono Nerd Font on Linux"
```

---

## Task 7: OS-gate the wezterm config

**Files:**
- Modify: `wezterm/wezterm.lua`

- [ ] **Step 1: Detect the OS at the top of the config**

After `local config = wezterm.config_builder()` (line 5), add:

```lua
-- macOS uses CMD as leader; Linux/Windows have no CMD key, so use SUPER.
local is_macos = wezterm.target_triple:find('darwin') ~= nil
```

- [ ] **Step 2: Make the leader mods OS-aware**

Change the leader block (lines 10–14) from `mods = 'CMD'` to:

```lua
config.leader = {
    key = 'a',
    mods = is_macos and 'CMD' or 'SUPER',
    timeout_milliseconds = 1000,
}
```

- [ ] **Step 3: Guard the macOS-only blur**

Change lines 96–98:

```lua
-- Window opacity
config.window_background_opacity = 0.9
config.macos_window_background_blur = 20
```

to:

```lua
-- Window opacity
config.window_background_opacity = 0.9
if is_macos then
    config.macos_window_background_blur = 20
end
```

- [ ] **Step 4: Verify it still loads on macOS**

Run on macOS: `wezterm --config-file wezterm/wezterm.lua ls-fonts >/dev/null && echo OK`
Expected: `OK` (config parses; no Lua error). The leader stays CMD on macOS.

- [ ] **Step 5: Commit**

```bash
git add wezterm/wezterm.lua
git commit -m "OS-gate wezterm leader key (CMD on macOS, SUPER on Linux)"
```

---

## Task 8: Install wezterm on Linux desktops

**Files:**
- Modify: `install.sh` (helpers section + new wezterm step)
- Modify: `tests/test_helpers.sh` (test for the AppImage URL filter)

- [ ] **Step 1: Add a failing test for the AppImage URL filter**

The fallback parses the GitHub releases API for the AppImage asset URL. Extract that parsing into a pure, testable filter. Append to `tests/test_helpers.sh` before the summary:

```bash
# appimage_url_filter reads release JSON on stdin, echoes the AppImage asset URL
sample_json='{"assets":[{"browser_download_url":"https://github.com/wez/wezterm/releases/download/2024/WezTerm-2024-Ubuntu20.04.AppImage"},{"browser_download_url":"https://github.com/wez/wezterm/releases/download/2024/WezTerm-2024-src.tar.gz"}]}'
got="$(printf '%s' "$sample_json" | appimage_url_filter)"
check "appimage_url_filter picks the AppImage" \
  "https://github.com/wez/wezterm/releases/download/2024/WezTerm-2024-Ubuntu20.04.AppImage" "$got"
```

- [ ] **Step 2: Run the test, verify it fails**

Run: `bash tests/test_helpers.sh`
Expected: FAIL — `appimage_url_filter: command not found`.

- [ ] **Step 3: Add `appimage_url_filter` and `install_wezterm_linux` helpers**

In the helpers section, add:

```bash
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
      pm_install pacman wezterm && { ok "wezterm installed (pacman)"; return; } ;;
    apt)
      curl -fsSL https://apt.fury.io/wez/gpg.key \
        | $SUDO gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg 2>/dev/null
      echo "deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *" \
        | $SUDO tee /etc/apt/sources.list.d/wezterm.list >/dev/null
      $SUDO apt-get update -y \
        && pm_install apt wezterm && { ok "wezterm installed (apt repo)"; return; } ;;
    dnf)
      $SUDO dnf -y copr enable wezfurlong/wezterm-nightly \
        && pm_install dnf wezterm && { ok "wezterm installed (copr)"; return; } ;;
  esac
  warn "wezterm repo install unavailable; trying AppImage"
  local url
  url="$(curl -fsSL https://api.github.com/repos/wez/wezterm/releases/latest | appimage_url_filter)"
  if [ -n "$url" ]; then
    mkdir -p "$HOME/.local/bin"
    if curl -fsSL -o "$HOME/.local/bin/wezterm" "$url"; then
      chmod +x "$HOME/.local/bin/wezterm"
      ok "wezterm AppImage installed to ~/.local/bin/wezterm"; return
    fi
  fi
  warn "wezterm install failed; install manually from https://wezterm.org/install/linux.html"
}
```

- [ ] **Step 4: Run the test, verify it passes**

Run: `bash tests/test_helpers.sh`
Expected: PASS — including the new `appimage_url_filter` check; final `ALL PASS`.

- [ ] **Step 5: Add the wezterm step (Linux + GUI) near the end of the script**

Immediately before the final `step "Done"` block, add:

```bash
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
```

(`$PM` is set in the Prerequisites Linux branch; this step only runs when `is_linux`, so it is always defined here.)

- [ ] **Step 6: Lint**

Run: `shellcheck install.sh tests/test_helpers.sh`
Expected: no errors.

- [ ] **Step 7: Commit**

```bash
git add install.sh tests/test_helpers.sh
git commit -m "Install wezterm on Linux desktops with AppImage fallback"
```

---

## Task 9: Integration verification (containers) + test docs

**Files:**
- Create: `tests/README.md`

- [ ] **Step 1: Write the test docs**

Create `tests/README.md`:

```markdown
# Tests

## Unit tests (pure helpers)

    bash tests/test_helpers.sh

Sources `install.sh` (which stops early when sourced) and asserts on the pure
helper functions: `version_ge`, `native_packages`, `appimage_url_filter`.

## Integration matrix (headless install per distro)

Run the installer end-to-end in a throwaway container per distro. Each must
finish without `die`, be idempotent on a second run, and produce nvim >= 0.11.

Ubuntu (apt):

    docker run --rm -it ubuntu:24.04 bash -c '
      apt-get update && apt-get install -y sudo curl git &&
      git clone https://github.com/jadchartouni/dotfiles /root/.dotfiles &&
      cd /root/.dotfiles && ./install.sh && ./install.sh &&
      nvim --version | head -1'

Fedora (dnf):

    docker run --rm -it fedora:latest bash -c '
      dnf install -y sudo curl git &&
      git clone https://github.com/jadchartouni/dotfiles /root/.dotfiles &&
      cd /root/.dotfiles && ./install.sh && ./install.sh &&
      nvim --version | head -1'

Arch (pacman):

    docker run --rm -it archlinux:latest bash -c '
      pacman -Sy --noconfirm sudo curl git &&
      git clone https://github.com/jadchartouni/dotfiles /root/.dotfiles &&
      cd /root/.dotfiles && ./install.sh && ./install.sh &&
      nvim --version | head -1'

Expected per distro:
- First run: native tier installs; nvim/tree-sitter/fzf/bat resolved (brew on
  Ubuntu/Fedora-old, native on Arch); symlinks created.
- Second run: every step reports "already" / "in sync" (idempotent).
- `nvim --version` reports >= 0.11.
- Arch run never prints "Installing Homebrew (Linuxbrew)".

## Desktop / wezterm (manual)

On a Linux desktop with `$DISPLAY` set, run `./install.sh`, then confirm
`wezterm` launches and the `SUPER+a` leader keybinds work.
```

- [ ] **Step 2: Run the unit tests one final time**

Run: `bash tests/test_helpers.sh`
Expected: `ALL PASS`.

- [ ] **Step 3: Run the Ubuntu integration container (primary brew-fallback path)**

Run the Ubuntu command from `tests/README.md` (clone replaced with the local checkout if iterating locally: mount the repo with `-v "$PWD":/root/.dotfiles`).
Expected: both runs succeed, second is idempotent, `nvim --version` >= 0.11, Linuxbrew gets installed for nvim.

- [ ] **Step 4: Run the Arch integration container (native-only path)**

Run the Arch command.
Expected: succeeds, idempotent, `nvim --version` >= 0.11, and **no** Linuxbrew install line (native nvim is current).

- [ ] **Step 5: Run the Fedora integration container**

Run the Fedora command.
Expected: succeeds, idempotent, `nvim --version` >= 0.11.

- [ ] **Step 6: macOS regression**

Run on macOS: `./install.sh`
Expected: identical behavior to before this work — macOS branch only, all steps idempotent, no Linux output.

- [ ] **Step 7: Commit**

```bash
git add tests/README.md
git commit -m "Add test docs and integration matrix for Linux installer"
```

---

## Self-Review Notes

- **Spec coverage:** detection layer (T1), native tier (T2–T3), sudo/header (T3), Linuxbrew + version tier with MIN_NVIM 0.11 (T5), Brewfile untouched (no task modifies it — confirmed), fonts (T6), wezterm config OS-gate (T7), wezterm per-distro install + AppImage fallback gated on has_gui (T8), unchanged portable steps (untouched), error handling via die/warn (T3, T5, T6, T8), testing strategy incl. macOS regression and per-distro idempotency (T9). zprofile Linuxbrew PATH (T4) supports the version tier. All spec sections map to a task.
- **Placeholder scan:** no TBD/TODO; every code step shows complete code; commands have expected output.
- **Type/name consistency:** helper names are consistent across tasks — `detect_pm`, `version_ge`, `nvim_version`, `native_packages`, `pm_update`, `pm_install`, `ensure_linuxbrew`, `ensure_version_tools`, `install_nerd_font_linux`, `appimage_url_filter`, `install_wezterm_linux`; `$PM`, `$SUDO`, `$MIN_NVIM` used consistently. Binary-vs-formula distinctions noted (tree-sitter/tree-sitter-cli, bat/batcat).
```
