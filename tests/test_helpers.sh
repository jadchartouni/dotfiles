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

# native_packages <pm> -> space-separated package list for that PM
check_true  test -n "$(native_packages apt)"
check_nonempty() { if native_packages "$1" | grep -q "$2"; then printf 'ok   - native_packages %s has %s\n' "$1" "$2"; else printf 'FAIL - native_packages %s missing %s\n' "$1" "$2"; fails=$((fails+1)); fi; }
check_nonempty apt    build-essential
check_nonempty dnf    "@development-tools"
check_nonempty pacman base-devel
check_nonempty apt    wl-clipboard
check_nonempty pacman fontconfig
check_nonempty apt    gnupg
check_nonempty apt    ripgrep
check_nonempty dnf    ripgrep
check_nonempty pacman ripgrep
check_nonempty apt    zoxide
check_nonempty apt    direnv

# appimage_url_filter reads release JSON on stdin, echoes the AppImage asset URL
sample_json='{"assets":[{"browser_download_url":"https://github.com/wez/wezterm/releases/download/2024/WezTerm-2024-Ubuntu20.04.AppImage"},{"browser_download_url":"https://github.com/wez/wezterm/releases/download/2024/WezTerm-2024-src.tar.gz"}]}'
got="$(printf '%s' "$sample_json" | appimage_url_filter)"
check "appimage_url_filter picks the AppImage" \
  "https://github.com/wez/wezterm/releases/download/2024/WezTerm-2024-Ubuntu20.04.AppImage" "$got"

# arch_regex [machine] -> grep alternation for that architecture's asset names
check "arch_regex x86_64"  "(x86_64|amd64|x64)" "$(arch_regex x86_64)"
check "arch_regex aarch64" "(aarch64|arm64)"    "$(arch_regex aarch64)"
check "arch_regex arm64"   "(aarch64|arm64)"    "$(arch_regex arm64)"
check "arch_regex default is non-empty" "0" "$(test -n "$(arch_regex)"; echo $?)"
check "arch_regex passes through unknown arch" "riscv64" "$(arch_regex riscv64)"

# expand_arch <pattern> [machine] -> {arch} placeholders replaced
check "expand_arch replaces placeholder" \
  "nvim-linux-(aarch64|arm64)\.tar\.gz" \
  "$(expand_arch 'nvim-linux-{arch}\.tar\.gz' arm64)"

# native_for_pm <pm> <field> -> native package name for this PM, or failure
check "native_for_pm plain name"    "ripgrep"          "$(native_for_pm apt ripgrep)"
check "native_for_pm apt override"  "build-essential"  "$(native_for_pm apt apt:build-essential,dnf:@development-tools,pacman:base-devel)"
check "native_for_pm dnf override"  "@development-tools" "$(native_for_pm dnf apt:build-essential,dnf:@development-tools,pacman:base-devel)"
check_false native_for_pm apt -
check_false native_for_pm dnf apt:universal-ctags

# gh_url_filter <regex> reads release JSON on stdin, echoes first matching asset URL
gh_json='{"assets":[{"browser_download_url":"https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-arm64.tar.gz"},{"browser_download_url":"https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-x86_64.tar.gz"}]}'
check "gh_url_filter picks arm64 asset" \
  "https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-arm64.tar.gz" \
  "$(printf '%s' "$gh_json" | gh_url_filter "$(expand_arch 'nvim-linux-{arch}\.tar\.gz' arm64)")"
check "gh_url_filter picks x86 asset" \
  "https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-x86_64.tar.gz" \
  "$(printf '%s' "$gh_json" | gh_url_filter "$(expand_arch 'nvim-linux-{arch}\.tar\.gz' x86_64)")"
check "gh_url_filter no match fails" "1" "$(printf '%s' "$gh_json" | gh_url_filter 'windows\.zip' >/dev/null; echo $?)"

# cmd_version / pkg_satisfied with stub commands
stubdir="$(mktemp -d)"
printf '#!/bin/sh\necho "stubtool v1.4.2 (deadbeef)"\n' > "$stubdir/stubtool"
chmod +x "$stubdir/stubtool"
PATH="$stubdir:$PATH"
check "cmd_version parses x.y.z" "1.4.2" "$(cmd_version stubtool)"
check_true  pkg_satisfied stubtool -
check_true  pkg_satisfied stubtool 1.4
check_true  pkg_satisfied stubtool 1.3
check_false pkg_satisfied stubtool 1.5
check_false pkg_satisfied no-such-cmd-xyz -
rm -rf "$stubdir"

echo
if [ "$fails" -eq 0 ]; then echo "ALL PASS"; exit 0; else echo "$fails FAILURE(S)"; exit 1; fi
