# Linux Package Manifest ("Linuxfile") — Design

Date: 2026-08-19
Status: approved (pending spec review)

## Goal

Make `install.sh` give Linux (primarily Kali ARM64 VMs, but any apt/dnf/pacman
distro) a declarative, brew-like package story: one file, one line per tool.
Today the Linux path hardcodes a native package string per PM plus ~8 lines of
bespoke shell per version-sensitive tool; large parts of the Brewfile have no
Linux equivalent at all.

## Decisions made during brainstorming

- **Scope: terminal core only.** The zsh/tmux/nvim experience and everyday CLI
  tools. No dev tier (php, node, pnpm, uv, docker), no cloud tier (awscli,
  azure-cli, terraform), no media tools (ffmpeg, imagemagick). Kali ships its
  own tooling for engagement work.
- **Lifecycle: ephemeral VMs rebuilt often.** Install speed matters; prefer
  native packages over anything that bootstraps slowly.
- **Architecture: ARM64 first.** VMs run on an Apple Silicon Mac. Homebrew on
  Linux has no ARM64 bottles (compiles from source, officially best-effort), so
  Linuxbrew cannot be a required tier. It remains an x86_64-only last resort.
- **macOS path unchanged.** Brewfile + `brew bundle` stay as-is.

## 1. The manifest — `linux/packages.conf`

Plain text, one entry per line, whitespace-separated columns, `#` comments.
`-` means "not applicable".

```
# name       check     min    native                              gh (owner/repo:asset-regex)
git          git       -      git                                 -
build-tools  -         -      apt:build-essential,dnf:@development-tools,pacman:base-devel  -
neovim       nvim      0.11   neovim                              neovim/neovim:nvim-linux-{arch}.tar.gz
fzf          fzf       0.48   fzf                                 junegunn/fzf:fzf-.*-linux_{arch}.tar.gz
sesh         sesh      -      -                                   joshmedeski/sesh:sesh_Linux_{arch}.tar.gz
...
```

Columns:

- **name** — display name for log output.
- **check** — command probed on `$PATH`. `-` = no probe; the native package is
  handed to the PM every run (PMs are idempotent, so this is a cheap no-op).
  Used for meta-packages (build-essential) and libraries (fontconfig).
- **min** — minimum version, compared major.minor via existing `version_ge`.
  Version is parsed from `<check> --version` (first `x.y.z` match). `-` = any
  version acceptable.
- **native** — package name for the system PM. Either a single name used for
  every PM, or per-PM overrides `apt:x,dnf:y,pacman:z` (a PM absent from the
  override list means "no native candidate on that PM"). `-` = no native
  package anywhere (e.g. sesh).
- **gh** — GitHub release fallback, `owner/repo:asset-regex`. The regex is
  matched against `releases/latest` asset URLs (same technique as the existing
  wezterm `appimage_url_filter`). `{arch}` expands to an alternation group for
  the current machine: `(x86_64|amd64)` or `(aarch64|arm64)`.

### Package list (initial)

- Base (check `-`): build-tools, fontconfig, gnupg, wl-clipboard, xclip, unzip
- Plain native: git, curl, zsh, tmux, jq, tree, ripgrep, zoxide, direnv, eza,
  yazi, btop, universal-ctags
- Native with gh fallback: neovim (min 0.11), fzf (min 0.48), bat (no min, but
  Debian/Kali's apt package installs the binary as `batcat`, so the check
  fails and the gh tier provides a real `bat`)
- gh-only: sesh, tree-sitter-cli

Note (bat on Debian/Kali): the apt package installs the binary as `batcat`.
The resolver's post-install probe fails for check-cmd `bat`, so it proceeds to
the gh tier, which installs a real `bat`. No special case needed.

## 2. The resolver (in install.sh)

Replaces `native_packages()` + `ensure_version_tools()`. For each entry:

1. **Satisfied?** `check` exists and meets `min` → `ok`, next entry.
2. **Native.** If a native candidate exists for the detected PM, install it
   (batched: all plain native packages install in one PM transaction for
   speed; version-gated ones re-probe after install).
3. **GitHub release.** Download matching asset. Plain or gzipped single
   binaries (tree-sitter) and flat tarballs (sesh, fzf) → binary into
   `~/.local/bin`. Tarballs with a directory tree (neovim) → extracted to
   `~/.local/opt/<name>`, executables symlinked into `~/.local/bin`.
   `~/.local/bin` is already on PATH via zshrc.
4. **Linuxbrew** — only when `uname -m` = x86_64, reusing `ensure_linuxbrew`.
5. **Warn and continue.** A single tool never aborts the install (`die` is
   reserved for no-PM / no-git, as today).

Idempotency: step 1 makes re-runs fast and re-entrant, preserving the
installer's existing contract (safe to run any number of times).

## 3. Unchanged

- macOS: Brewfile, `brew bundle`, Raycast, casks.
- Linux: Nerd Font installer, oh-my-zsh + plugins + p10k, symlinks, git
  excludesfile, TPM, headless `Lazy! sync`, wezterm installer (desktop-only,
  genuinely special-cased — keeps its apt-repo/copr/AppImage logic).

## 4. Kali / test matrix

- Kali is Debian/apt; no new code path.
- `tests/README.md` gains a `kalilinux/kali-rolling` row in the Docker matrix.
  On Apple Silicon, Docker runs the ARM64 image natively — exercising the
  exact architecture the real VMs use, including the gh-release ARM assets.
- `tests/test_helpers.sh` gains unit tests for the new pure helpers:
  manifest line parsing, per-PM native-name resolution, `{arch}` expansion,
  and the gh asset URL filter.

## Out of scope

- Dev tier (php, composer, node, pnpm, uv, docker), cloud tier (awscli,
  azure-cli, terraform), media tools (ffmpeg, imagemagick, wget on Linux).
- Any change to macOS behavior.
- Pinning gh releases to specific versions (uses `releases/latest`, matching
  the existing wezterm AppImage precedent).
