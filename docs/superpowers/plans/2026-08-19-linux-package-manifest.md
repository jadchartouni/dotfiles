# Linux Package Manifest Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give `install.sh` a declarative, brew-like package manifest for Linux (`linux/packages.conf`) with a native → GitHub-release → Linuxbrew(x86_64-only) resolver, replacing the hardcoded `native_packages()` / `ensure_version_tools()` shell.

**Architecture:** Pure helper functions (parsing, arch mapping, version checks, URL filtering) go in `install.sh` *above* its source-guard so `tests/test_helpers.sh` can source and unit-test them. The impure engine (`resolve_packages`, `install_gh_release`) also lives in `install.sh`, exercised by the Docker integration matrix. The manifest is whitespace-separated text, one tool per line.

**Tech Stack:** bash (no new dependencies), curl, tar/gunzip, GitHub releases API, existing `pm_install`/`ensure_linuxbrew`/`version_ge` helpers.

## Global Constraints

- Spec: `docs/superpowers/specs/2026-08-19-linux-package-manifest-design.md`
- All new pure helpers MUST be defined before the source-guard line in install.sh (`if (return 0 2>/dev/null); then return 0; fi`) so tests can source them.
- Script runs under `set -u`; every new function must be safe with unset-variable checking (use `${1:-}` style defaults where an arg is optional).
- Per-tool failures `warn` and continue — `die` stays reserved for "no supported PM" / "no git".
- Version comparison uses the existing `version_ge` (major.minor only).
- `{arch}` in gh patterns expands to `(x86_64|amd64|x64)` on x86_64 machines and `(aarch64|arm64)` on ARM machines.
- User-level installs go to `~/.local/bin` (single binaries) and `~/.local/opt/<name>` (trees); never require sudo for gh-release installs.
- macOS behavior must not change; run `bash tests/test_helpers.sh` (all pass) and `bash -n install.sh` after every task.
- Match existing output style: `info`/`ok`/`warn` helpers, comments in the terse existing voice.
- Commit after each task; keep each commit to that task's files.

## File Structure

- `install.sh` — helpers added above the source-guard; engine + wiring below it; `native_packages()` and `ensure_version_tools()` deleted.
- `linux/packages.conf` — new manifest (terminal-core scope, ~24 lines).
- `tests/test_helpers.sh` — new unit tests; `native_packages` tests replaced by manifest tests.
- `tests/README.md` — Kali row in the Docker matrix.

---

### Task 1: Arch helpers (`arch_regex`, `expand_arch`)

**Files:**
- Modify: `install.sh` (insert after `version_ge`, before `nvim_version`)
- Test: `tests/test_helpers.sh`

**Interfaces:**
- Produces: `arch_regex [machine]` → echoes alternation group for the current (or given) machine; `expand_arch <pattern> [machine]` → echoes pattern with every `{arch}` replaced.

- [ ] **Step 1: Write the failing tests** (append to `tests/test_helpers.sh` before the final `echo`/exit block)

```bash
# arch_regex [machine] -> grep alternation for that architecture's asset names
check "arch_regex x86_64"  "(x86_64|amd64|x64)" "$(arch_regex x86_64)"
check "arch_regex aarch64" "(aarch64|arm64)"    "$(arch_regex aarch64)"
check "arch_regex arm64"   "(aarch64|arm64)"    "$(arch_regex arm64)"
check "arch_regex default is non-empty" "0" "$(test -n "$(arch_regex)"; echo $?)"

# expand_arch <pattern> [machine] -> {arch} placeholders replaced
check "expand_arch replaces placeholder" \
  "nvim-linux-(aarch64|arm64)\.tar\.gz" \
  "$(expand_arch 'nvim-linux-{arch}\.tar\.gz' arm64)"
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bash tests/test_helpers.sh`
Expected: FAIL / `arch_regex: command not found` errors, non-zero exit.

- [ ] **Step 3: Implement in `install.sh`** (after the `version_ge` function)

```bash
# arch_regex [machine] -> grep -E alternation matching this machine's flavor in
# release asset names (projects disagree: x86_64/amd64/x64, aarch64/arm64).
arch_regex() {
  case "${1:-$(uname -m)}" in
    x86_64|amd64|x64) echo "(x86_64|amd64|x64)" ;;
    aarch64|arm64)    echo "(aarch64|arm64)" ;;
    *)                echo "$(uname -m)" ;;
  esac
}

# expand_arch <pattern> [machine] -> pattern with {arch} -> arch_regex output.
expand_arch() {
  local re; re="$(arch_regex "${2:-}")"
  printf '%s\n' "${1//\{arch\}/$re}"
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `bash tests/test_helpers.sh` → `ALL PASS`. Also `bash -n install.sh`.

- [ ] **Step 5: Commit**

```bash
git add install.sh tests/test_helpers.sh
git commit -m "Add arch_regex/expand_arch helpers for gh-release asset matching"
```

---

### Task 2: Per-PM native name resolution (`native_for_pm`)

**Files:**
- Modify: `install.sh` (after `expand_arch`)
- Test: `tests/test_helpers.sh`

**Interfaces:**
- Consumes: nothing new.
- Produces: `native_for_pm <pm> <native-field>` → echoes the package name for that PM and returns 0, or returns 1 when the field is `-` or has overrides without this PM.

- [ ] **Step 1: Write the failing tests**

```bash
# native_for_pm <pm> <field> -> package name for that PM, or failure
check "native_for_pm plain name"    "ripgrep"          "$(native_for_pm apt ripgrep)"
check "native_for_pm apt override"  "build-essential"  "$(native_for_pm apt apt:build-essential,dnf:@development-tools,pacman:base-devel)"
check "native_for_pm dnf override"  "@development-tools" "$(native_for_pm dnf apt:build-essential,dnf:@development-tools,pacman:base-devel)"
check_false native_for_pm apt -
check_false native_for_pm dnf apt:universal-ctags
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bash tests/test_helpers.sh` → FAILs / command not found.

- [ ] **Step 3: Implement**

```bash
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
```

- [ ] **Step 4: Run tests to verify they pass** — `bash tests/test_helpers.sh` → `ALL PASS`; `bash -n install.sh`.

- [ ] **Step 5: Commit**

```bash
git add install.sh tests/test_helpers.sh
git commit -m "Add native_for_pm manifest field resolver"
```

---

### Task 3: GitHub release URL filter (`gh_url_filter`)

**Files:**
- Modify: `install.sh` (next to `appimage_url_filter`)
- Test: `tests/test_helpers.sh`

**Interfaces:**
- Produces: `gh_url_filter <regex>` — reads release JSON on stdin, echoes the first `browser_download_url` whose value matches `<regex>`, returns 1 if none.

- [ ] **Step 1: Write the failing tests**

```bash
# gh_url_filter <regex> reads release JSON on stdin, echoes first matching asset URL
gh_json='{"assets":[{"browser_download_url":"https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-arm64.tar.gz"},{"browser_download_url":"https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-x86_64.tar.gz"}]}'
check "gh_url_filter picks arm64 asset" \
  "https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-arm64.tar.gz" \
  "$(printf '%s' "$gh_json" | gh_url_filter "$(expand_arch 'nvim-linux-{arch}\.tar\.gz' arm64)")"
check "gh_url_filter picks x86 asset" \
  "https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-x86_64.tar.gz" \
  "$(printf '%s' "$gh_json" | gh_url_filter "$(expand_arch 'nvim-linux-{arch}\.tar\.gz' x86_64)")"
check "gh_url_filter no match fails" "1" "$(printf '%s' "$gh_json" | gh_url_filter 'windows\.zip' >/dev/null; echo $?)"
```

- [ ] **Step 2: Run tests to verify they fail** — `bash tests/test_helpers.sh`.

- [ ] **Step 3: Implement**

```bash
# Read GitHub release JSON on stdin, echo the first browser_download_url whose
# value matches the given extended regex. Returns 1 when nothing matches.
gh_url_filter() {
  grep -oE '"browser_download_url" *: *"[^"]+"' \
    | grep -oE 'https://[^"]+' \
    | grep -E -m1 "$1"
}
```

- [ ] **Step 4: Run tests to verify they pass** — `bash tests/test_helpers.sh` → `ALL PASS`; `bash -n install.sh`.

- [ ] **Step 5: Commit**

```bash
git add install.sh tests/test_helpers.sh
git commit -m "Add gh_url_filter for release asset selection"
```

---

### Task 4: Version probe + satisfaction check (`cmd_version`, `pkg_satisfied`)

**Files:**
- Modify: `install.sh` (after `nvim_version`)
- Test: `tests/test_helpers.sh`

**Interfaces:**
- Consumes: `version_ge` (existing).
- Produces: `cmd_version <cmd>` → first `x.y[.z]` from `<cmd> --version`, or return 1. `pkg_satisfied <check> <min>` → 0 iff `<check>` is on PATH and (min is `-` or installed version ≥ min).

- [ ] **Step 1: Write the failing tests** (uses fake commands on PATH — no network, no assumptions about the host beyond mktemp)

```bash
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
```

- [ ] **Step 2: Run tests to verify they fail** — `bash tests/test_helpers.sh`.

- [ ] **Step 3: Implement**

```bash
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
```

- [ ] **Step 4: Run tests to verify they pass** — `bash tests/test_helpers.sh` → `ALL PASS`; `bash -n install.sh`.

- [ ] **Step 5: Commit**

```bash
git add install.sh tests/test_helpers.sh
git commit -m "Add cmd_version and pkg_satisfied manifest checks"
```

---

### Task 5: The manifest — `linux/packages.conf` (+ lint test)

**Files:**
- Create: `linux/packages.conf`
- Test: `tests/test_helpers.sh`

**Interfaces:**
- Produces: the manifest consumed by `resolve_packages` (Task 7). Columns: `name check min native gh`, whitespace-separated, `#` comments, `-` = not applicable.

- [ ] **Step 1: Write the failing tests**

```bash
# linux/packages.conf: every non-comment line has exactly 5 fields
conf="$HERE/../linux/packages.conf"
check "packages.conf exists" "0" "$(test -f "$conf"; echo $?)"
badlines="$(awk 'NF && $1 !~ /^#/ && NF != 5' "$conf" | wc -l | tr -d ' ')"
check "packages.conf lines have 5 fields" "0" "$badlines"
for tool in build-tools neovim fzf sesh tree-sitter-cli eza yazi btop bat universal-ctags ripgrep zoxide direnv; do
  if grep -qE "^$tool[[:space:]]" "$conf"; then printf 'ok   - packages.conf has %s\n' "$tool"
  else printf 'FAIL - packages.conf missing %s\n' "$tool"; fails=$((fails+1)); fi
done
```

- [ ] **Step 2: Run tests to verify they fail** — `bash tests/test_helpers.sh` (packages.conf missing).

- [ ] **Step 3: Create `linux/packages.conf`**

```
# Linux package manifest — the Brewfile counterpart for Linux installs.
# Read by resolve_packages() in install.sh. One tool per line, 5 fields:
#   name   check   min   native   gh
# name:   display name (also the brew formula for the x86_64 last-resort tier)
# check:  command probed on $PATH; "-" = no probe, always hand native to the PM
# min:    minimum version (major.minor), "-" = any
# native: package name for the system PM; same everywhere, or per-PM
#         "apt:x,dnf:y,pacman:z" (PM not listed = no native candidate); "-" = none
# gh:     GitHub release fallback "owner/repo:asset-regex"; {arch} expands per
#         machine to (x86_64|amd64|x64) or (aarch64|arm64); "-" = none
#
# Base (no probe: meta-packages and libraries the configs rely on)
build-tools     -            -     apt:build-essential,dnf:@development-tools,pacman:base-devel  -
fontconfig      -            -     fontconfig                                                    -
gnupg           -            -     gnupg                                                         -
wl-clipboard    -            -     wl-clipboard                                                  -
xclip           -            -     xclip                                                         -
unzip           -            -     unzip                                                         -
#
# Everyday tools (any version the distro ships is fine)
git             git          -     git                                                           -
curl            curl         -     curl                                                          -
zsh             zsh          -     zsh                                                           -
tmux            tmux         -     tmux                                                          -
jq              jq           -     jq                                                            -
tree            tree         -     tree                                                          -
ripgrep         rg           -     ripgrep                                                       -
zoxide          zoxide       -     zoxide                                                        -
direnv          direnv       -     direnv                                                        -
eza             eza          -     eza                                                           -
yazi            yazi         -     yazi                                                          -
btop            btop         -     btop                                                          -
universal-ctags ctags        -     apt:universal-ctags,dnf:ctags,pacman:ctags                    -
#
# Version-sensitive (native first, GitHub release when absent/too old)
neovim          nvim         0.11  neovim                                                        neovim/neovim:nvim-linux-{arch}\.tar\.gz
fzf             fzf          0.48  fzf                                                           junegunn/fzf:fzf-[0-9.]+-linux_{arch}\.tar\.gz
bat             bat          -     bat                                                           sharkdp/bat:bat-v[0-9.]+-{arch}-unknown-linux-(gnu|musl)\.tar\.gz
#
# Not packaged by distros
sesh            sesh         -     -                                                             joshmedeski/sesh:sesh_Linux_{arch}\.tar\.gz
tree-sitter-cli tree-sitter  -     -                                                             tree-sitter/tree-sitter:tree-sitter-linux-{arch}\.gz
```

(Note: Debian/Kali's `bat` package installs the binary as `batcat`, so the
`bat` check stays unsatisfied after the native tier and the gh tier provides a
real `bat` — by design, no special case.)

- [ ] **Step 4: Run tests to verify they pass** — `bash tests/test_helpers.sh` → `ALL PASS`.

- [ ] **Step 5: Commit**

```bash
git add linux/packages.conf tests/test_helpers.sh
git commit -m "Add linux/packages.conf manifest (terminal-core scope)"
```

---

### Task 6: Asset classifier (`asset_kind`)

**Files:**
- Modify: `install.sh` (after `gh_url_filter`)
- Test: `tests/test_helpers.sh`

**Interfaces:**
- Produces: `asset_kind <url-or-filename>` → echoes `targz` | `gz` | `bin`.

- [ ] **Step 1: Write the failing tests**

```bash
# asset_kind classifies release assets by filename
check "asset_kind tar.gz" "targz" "$(asset_kind https://x/nvim-linux-arm64.tar.gz)"
check "asset_kind tgz"    "targz" "$(asset_kind x.tgz)"
check "asset_kind gz"     "gz"    "$(asset_kind https://x/tree-sitter-linux-arm64.gz)"
check "asset_kind bare"   "bin"   "$(asset_kind https://x/some-binary)"
```

- [ ] **Step 2: Run tests to verify they fail** — `bash tests/test_helpers.sh`.

- [ ] **Step 3: Implement**

```bash
# asset_kind <url> -> targz | gz | bin, by extension.
asset_kind() {
  case "$1" in
    *.tar.gz|*.tgz) echo targz ;;
    *.gz)           echo gz ;;
    *)              echo bin ;;
  esac
}
```

- [ ] **Step 4: Run tests to verify they pass** — `bash tests/test_helpers.sh` → `ALL PASS`; `bash -n install.sh`.

- [ ] **Step 5: Commit**

```bash
git add install.sh tests/test_helpers.sh
git commit -m "Add asset_kind release-asset classifier"
```

---

### Task 7: Engine (`install_gh_release`, `resolve_packages`) + wiring

**Files:**
- Modify: `install.sh` — add the two engine functions below the source-guard (they are impure; place them right after the source-guard, before "0. Prerequisites"); replace the Linux branch of section 0 and section 2; delete `native_packages()` and `ensure_version_tools()`.
- Test: `tests/test_helpers.sh` — delete the `native_packages` test block (lines asserting `check_nonempty ...`), which now tests a deleted function.

**Interfaces:**
- Consumes: `native_for_pm`, `pkg_satisfied`, `expand_arch`, `gh_url_filter`, `asset_kind`, `pm_install`, `ensure_linuxbrew`, `info`/`ok`/`warn`.
- Produces: `resolve_packages <pm> <manifest-path>` — the single entry point section 2 calls.

- [ ] **Step 1: Delete the old pieces**

In `install.sh`: remove the `native_packages()` function and the whole `ensure_version_tools()` function. In `tests/test_helpers.sh`: remove the `# native_packages ...` block (the `check_true test -n "$(native_packages apt)"`, the `check_nonempty` definition and its 11 calls).

- [ ] **Step 2: Add the engine functions** (immediately after the source-guard line)

```bash
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
  local name check min native gh pkg batch=""
  export PATH="$HOME/.local/bin:$PATH"

  # Pass 1: everything the native PM should provide, in one transaction.
  while read -r name check min native gh; do
    case "$name" in ''|\#*) continue ;; esac
    if [ "$check" != "-" ] && pkg_satisfied "$check" "$min"; then continue; fi
    pkg="$(native_for_pm "$pm" "$native")" && batch="$batch $pkg"
  done < "$manifest"
  if [ -n "$batch" ]; then
    # shellcheck disable=SC2086
    pm_install "$pm" $batch || warn "some native packages failed (continuing)"
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
```

- [ ] **Step 3: Rewire the main flow**

Section 0 Linux branch — replace the two `pm_update`/`pm_install ... native_packages` lines' install with a minimal bootstrap (the manifest needs the repo, the repo needs git):

```bash
elif is_linux; then
  PM="$(detect_pm)" || die "Unsupported Linux: need apt, dnf, or pacman. Install base tools manually and re-run."
  info "Detected package manager: $PM"
  [ -n "$SUDO" ] && info "Privileged installs use sudo; you may be prompted for your password."
  pm_update "$PM" || warn "package metadata refresh failed (continuing)"
  pm_install "$PM" git curl unzip ca-certificates || die "bootstrap package install failed"
  ok "bootstrap tier installed (git curl unzip)"
fi
```

Section 2 — replace `ensure_version_tools` with the resolver:

```bash
elif is_linux; then
  resolve_packages "$PM" "$DOTFILES/linux/packages.conf"
fi
```

- [ ] **Step 4: Verify**

Run: `bash -n install.sh` (clean), `bash tests/test_helpers.sh` (ALL PASS),
`grep -n "native_packages\|ensure_version_tools" install.sh tests/test_helpers.sh` (no hits).

- [ ] **Step 5: Commit**

```bash
git add install.sh tests/test_helpers.sh
git commit -m "Replace hardcoded Linux tiers with manifest-driven resolver"
```

---

### Task 8: Docs + Kali integration run

**Files:**
- Modify: `tests/README.md`
- Test: Docker (integration)

**Interfaces:** none new.

- [ ] **Step 1: Update `tests/README.md`** — in the unit-test paragraph, replace the helper list `version_ge`, `native_packages`, `appimage_url_filter` with `version_ge`, `arch_regex`/`expand_arch`, `native_for_pm`, `gh_url_filter`, `cmd_version`/`pkg_satisfied`, `asset_kind`, and the `linux/packages.conf` lint. After the Fedora block, add:

````markdown
Kali (apt, and on Apple Silicon this runs the ARM64 image — the same
architecture as the real VMs, exercising the gh-release ARM assets):

    docker run --rm -it kalilinux/kali-rolling bash -c '
      apt-get update && apt-get install -y sudo curl git &&
      git clone https://github.com/jadchartouni/dotfiles /root/.dotfiles &&
      cd /root/.dotfiles && ./install.sh && ./install.sh &&
      nvim --version | head -1 && sesh --version && bat --version'
````

- [ ] **Step 2: Run the Kali integration test locally** (Docker Desktop; uses the *local* checkout instead of the GitHub clone so the uncommitted branch is what's tested)

```bash
docker run --rm -v ~/.dotfiles:/src:ro kalilinux/kali-rolling bash -c '
  apt-get update && apt-get install -y sudo git &&
  git clone /src /root/.dotfiles &&
  cd /root/.dotfiles && ./install.sh && ./install.sh &&
  nvim --version | head -1 && sesh --version && bat --version && tree-sitter --version'
```

Expected: both runs finish without `die`; second run is fast (all `ok`/skips); the four version lines print. Fix anything that fails before committing.

- [ ] **Step 3: Commit**

```bash
git add tests/README.md
git commit -m "Document manifest unit tests and add Kali ARM64 integration run"
```
