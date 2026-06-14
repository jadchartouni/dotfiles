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

echo
if [ "$fails" -eq 0 ]; then echo "ALL PASS"; exit 0; else echo "$fails FAILURE(S)"; exit 1; fi
