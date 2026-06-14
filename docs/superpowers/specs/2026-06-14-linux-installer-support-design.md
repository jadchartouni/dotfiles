# Linux support for the dotfiles installer

**Date:** 2026-06-14
**Status:** Approved design, pending implementation plan

## Goal

Make `install.sh` and the configs work on Linux (both headless servers and GUI
desktops) in addition to macOS, without regressing the working macOS path.

## Target matrix

- **Environments:** headless server *and* GUI desktop. wezterm is installed only
  when a display is present; the rest of the toolchain installs everywhere.
- **Distros / package managers:** `apt` (Debian/Ubuntu), `dnf` (Fedora/RHEL),
  `pacman` (Arch). Any other PM: fail with a clear message.
- **Install strategy:** hybrid — native package manager for base/system tools;
  Linuxbrew only as a fallback for version-sensitive tools the distro ships too
  old or not at all.

## Non-goals (out of scope)

Not installed on Linux — these are not configured by these dotfiles and/or are
macOS-only apps: php, composer, node, pnpm, uv, awscli, azure-cli,
docker-desktop, Laravel Herd, session-manager-plugin, git-credential-manager,
raycast, the-unarchiver. Adding any of these is a separate effort.

## Architecture

### Detection layer (new helpers near the top of `install.sh`)

- `is_macos` — exists today (`uname -s` = Darwin).
- `is_linux` — `uname -s` = Linux.
- `detect_pm` — echoes `apt` / `dnf` / `pacman` by probing `command -v`; dies
  with a clear message if none found.
- `has_gui` — true when `$DISPLAY` or `$WAYLAND_DISPLAY` is set. Gates wezterm
  install on Linux.
- `SUDO` — empty when running as root (`id -u` = 0), else `sudo`. Native PM
  installs use `$SUDO`. **Behavior change:** the installer may now prompt for a
  sudo password on Linux. This is called out in the script's header comment and
  in console output before the first privileged step.

All macOS-only logic (Homebrew bootstrap, `brew bundle`, Herd) stays guarded by
`is_macos` exactly as today.

### Package strategy (hybrid)

Two tiers on Linux:

**Native tier** — always installed via the detected PM. Bootstrap plus tools
distros ship at acceptable versions:

| Purpose            | apt                       | dnf                       | pacman              |
|--------------------|---------------------------|---------------------------|---------------------|
| git                | git                       | git                       | git                 |
| curl               | curl                      | curl                      | curl                |
| zsh                | zsh                       | zsh                       | zsh                 |
| tmux               | tmux                      | tmux                      | tmux                |
| jq                 | jq                        | jq                        | jq                  |
| tree               | tree                      | tree                      | tree                |
| unzip              | unzip                     | unzip                     | unzip               |
| C toolchain        | build-essential           | @development-tools (group)| base-devel          |
| clipboard          | wl-clipboard, xclip       | wl-clipboard, xclip       | wl-clipboard, xclip |
| fontconfig         | fontconfig                | fontconfig                | fontconfig          |

Notes:
- The clipboard tool is required for nvim's `clipboard = "unnamedplus"`. Install
  `wl-clipboard` and `xclip` so both Wayland and X11 sessions work; harmless if
  one's session type is unused.
- `bat` is intentionally **not** in the native tier — on Debian/Ubuntu it ships
  as the `batcat` binary, which the configs don't reference. It lives in the
  version tier (Linuxbrew installs it as `bat`).

**Version tier** — tools the configs depend on at recent versions:
`neovim` (>= 0.11), `tree-sitter-cli`, `fzf`, `bat`.

For each, the script first checks the native install and its version:
- `neovim`: require **>= 0.11** (nvim-treesitter `main` branch requirement;
  `tree-sitter-cli` is needed for `:TSUpdate` to compile parsers).
- `fzf`, `bat`, `tree-sitter-cli`: require merely present (any recent version is
  fine; these are not tightly version-pinned by the config).

If a tool is missing or below its minimum, the script ensures **Linuxbrew** is
installed (lazily — only on first need) and installs that tool from brew. Result:
- Arch / current Fedora: native versions suffice → **Linuxbrew never installed.**
- Debian / Ubuntu (and older Fedora): nvim is too old → **Linuxbrew installed**,
  supplying the laggard tools only.

`MIN_NVIM` is defined as a constant (`0.11`) and compared with a small version
helper (parse `nvim --version` first line, compare major.minor numerically).

### Brewfile handling

The existing macOS `brew/Brewfile` is **unchanged** (zero risk to the working
macOS setup). The Linux version tier is a short, explicit list inside
`install.sh` (4 formulae) installed via `brew install` — no second Brewfile to
keep in sync.

### Fonts (Linux)

p10k / the terminals need a Nerd Font. On Linux, if no JetBrainsMono Nerd Font is
present (`fc-list | grep -qi jetbrainsmono`), download the JetBrainsMono Nerd
Font release zip into `~/.local/share/fonts/`, unzip, and run `fc-cache -f`.
Idempotent: skipped when already present.

### wezterm

**Config** (`wezterm/wezterm.lua`): make it OS-aware so one file serves both
platforms.
- Detect macOS via `wezterm.target_triple:find('darwin')`.
- Leader `mods`: `'CMD'` on macOS, `'SUPER'` on Linux.
- `macos_window_background_blur`: applied only on macOS (it is ignored elsewhere,
  but guarding keeps the config clean).
- All other keybinds and appearance settings are unchanged and shared.

**Install** (Linux desktop only — behind `has_gui`; pointless on a headless
box): real install, per-distro, using WezTerm's official packages, with an
AppImage fallback so the step does not silently fail:
- **pacman:** `wezterm` (native, current).
- **apt:** add WezTerm's official apt repo (`apt.fury.io/wez`) with its signing
  key, then `apt install wezterm`.
- **dnf:** enable WezTerm's COPR, then `dnf install wezterm`.
- **fallback:** if the repo route fails, download the latest WezTerm AppImage
  from GitHub releases into `~/.local/bin/wezterm` and mark it executable.
- Idempotent: skipped if `command -v wezterm` already succeeds.

### Unchanged, already-portable steps

Oh My Zsh + plugins, symlinks, `git config core.excludesfile`, TPM + tmux
plugins, and `nvim --headless +Lazy! sync` need no changes — they use portable
tooling and already guard their macOS-specific pieces. nvim itself is clean (no
Mac-specific code; `clipboard = unnamedplus` is satisfied by the native-tier
clipboard tool).

## Installer flow (Linux additions, in existing step order)

0. **Prerequisites:** `is_macos` → Homebrew (today's path). `is_linux` → detect
   PM, announce sudo use, `$SUDO <pm> update` + install the **native tier**.
   Final `command -v git` guard remains.
1. **Repository:** unchanged.
2. **Packages:** `is_macos` → `brew bundle` (today). `is_linux` → run the
   **version tier** resolution (native-version checks → lazy Linuxbrew fallback),
   then the **fonts** step.
3. **Shell (zsh):** unchanged.
4. **Symlinks:** unchanged.
5. **Git:** unchanged.
6. **tmux plugins:** unchanged.
7. **Neovim plugins:** unchanged.
8. **(new, Linux + `has_gui`) wezterm:** install per above.

## Error handling

- Unknown distro / no supported PM → `die` with guidance.
- Native PM install failure → `die` (base tools are required).
- Version-tier brew fallback failure → `warn` and continue (degraded but usable).
- Font / wezterm failure → `warn` with a manual-install pointer; never abort.
- Preserve the existing idempotent, re-runnable property throughout: every step
  checks current state before acting.

## Testing strategy

- **macOS regression:** re-run `install.sh` on the current Mac; confirm output
  and behavior are identical to before (all steps idempotent, no Linux branches
  taken).
- **Linux, per distro** (containers are sufficient for the headless path):
  - Ubuntu (apt): verifies native tier + Linuxbrew fallback for nvim/tree-sitter.
  - Fedora (dnf): verifies group-install toolchain + version checks.
  - Arch (pacman): verifies native versions suffice and brew is **not** installed.
  - For each: run twice, assert idempotency (second run reports "already"/"in
    sync"); assert `nvim --version` >= 0.11; open nvim headless and confirm
    treesitter parsers compile; confirm symlinks created.
- **Desktop / wezterm:** manual check on at least one Linux desktop — wezterm
  installs, launches, and the `SUPER` leader keybinds work.
