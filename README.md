# dotfiles

Personal macOS / Linux dotfiles, themed end-to-end with **SentryCore** — a
custom dark colorscheme shared across the editor, terminal, and multiplexer.

## What's inside

| Path             | Description                                                        |
| ---------------- | ----------------------------------------------------------------- |
| `brew/Brewfile`  | CLI tools, apps, and Nerd Fonts installed via Homebrew            |
| `git/`           | Global gitignore                                                   |
| `nvim/`          | Neovim config (lazy.nvim) + the SentryCore theme                  |
| `tmux/`          | tmux config (see `docs/tmux.md` for the cheat sheet)             |
| `wezterm/`       | WezTerm config + SentryCore color scheme                          |
| `docs/`          | Notes and cheat sheets                                             |
| `LICENSE.md`     | MIT                                                                |

## Highlights

- **Neovim** as a clean file editor (not an IDE): lazy.nvim, treesitter
  highlighting, lualine, nvim-tree, in-editor markdown rendering, and seamless
  tmux navigation. No LSP / completion / formatters by design.
- **WezTerm** using JetBrainsMono Nerd Font, the SentryCore scheme, leader-based
  splits/panes, and single-cell icon rendering.
- **tmux** with `vim-tmux-navigator` (seamless `C-h/j/k/l` across nvim & tmux),
  session persistence (`resurrect` + `continuum`), and a SentryCore status line.

## Requirements

- macOS or Linux
- [Homebrew](https://brew.sh) (for the Brewfile)
- Neovim, tmux (≥ 3.x), and WezTerm — all installed by the Brewfile

## Install

One-line bootstrap on a fresh machine — clones the repo, installs Homebrew (on
macOS), and sets everything up:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/jadchartouni/dotfiles/main/install.sh)"
```

Or from a local checkout:

```sh
git clone https://github.com/jadchartouni/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

`install.sh` is **idempotent** — run it any time to install, update, or repair.
It clones/updates the repo, installs packages (Homebrew on macOS; skipped on
Linux), symlinks the configs (backing up anything in the way), wires the global
gitignore, and installs the tmux + Neovim plugins.

> Run it in a real terminal so it can prompt for `sudo` when needed (Homebrew
> and Docker Desktop both require it).

## Neovim keys

Leader is <kbd>,</kbd>. A few essentials:

| Key            | Action                          |
| -------------- | ------------------------------- |
| `<leader>ft`   | Toggle file tree                |
| `<leader>fe`   | Reveal current file in the tree |
| `<leader>=`    | Re-indent the whole file        |
| `<leader>w`    | Toggle soft word wrap           |
| `<leader>mr`   | Toggle markdown rendering        |
| `jj`           | Escape (insert mode)            |

To swap the colorscheme back to nightfly, set `enabled = true` in
`nvim/lua/plugins/ui.nightfly.lua` and `enabled = false` in `ui.lua`.

## License

[MIT](LICENSE.md)
