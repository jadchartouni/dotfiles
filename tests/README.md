# Tests

## Unit tests (pure helpers)

    bash tests/test_helpers.sh

Sources `install.sh` (which stops early when sourced via the source-guard) and
asserts on the pure helper functions: `version_ge`, `native_packages`,
`appimage_url_filter`.

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
- First run: native tier installs (incl. ripgrep/zoxide/direnv); nvim,
  tree-sitter-cli, fzf, bat and sesh are resolved via Linuxbrew when absent —
  on every distro, since the native tier does not include them.
- Second run: every step reports "already" / "in sync" (idempotent), and
  Linuxbrew is not reinstalled.
- `nvim --version` reports >= 0.11.

To iterate against the local checkout instead of the GitHub clone, mount it:
`docker run --rm -it -v "$PWD":/root/.dotfiles ubuntu:24.04 bash -c '... cd /root/.dotfiles && ./install.sh ...'`
(omit the git clone line).

## Desktop / wezterm (manual)

On a Linux desktop with `$DISPLAY` set, run `./install.sh`, then confirm
`wezterm` launches and the `SUPER+a` leader keybinds work.
