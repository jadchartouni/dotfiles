# dotfiles

Personal macOS / Linux dotfiles, themed end-to-end with **SentryCore** — a
custom dark colorscheme shared across the editor, terminal, and multiplexer.

## What's inside

| Path            | Description                                            |
| --------------- | ------------------------------------------------------ |
| `brew/Brewfile` | CLI tools, apps, and Nerd Fonts installed via Homebrew |
| `git/`          | Global gitignore                                       |
| `nvim/`         | Neovim config (lazy.nvim) + the SentryCore theme       |
| `tmux/`         | tmux config (see `docs/tmux.md` for the cheat sheet)   |
| `wezterm/`      | WezTerm config + SentryCore color scheme               |
| `docs/`         | Notes and cheat sheets                                 |
| `LICENSE.md`    | MIT                                                    |

## Highlights

- **Neovim** as a clean file editor (not an IDE): lazy.nvim, treesitter
  highlighting, lualine, nvim-tree, Telescope fuzzy finding (files + live grep),
  inactive-window dimming (vimade), in-editor markdown rendering, and seamless
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

Leader is <kbd>,</kbd>.

**Find / files** (Telescope + nvim-tree)

| Key          | Action                          |
| ------------ | ------------------------------- |
| `<leader>ff` | Find files by name              |
| `<leader>fg` | Live grep (search file contents)|
| `<leader>fb` | Find open buffers               |
| `<leader>fr` | Recent files                    |
| `<leader>fh` | Help tags                       |
| `<leader>ft` | Toggle file tree                |
| `<leader>fe` | Reveal current file in the tree |

**Windows / tabs / buffers**

| Key          | Action                          |
| ------------ | ------------------------------- |
| `<leader>sv` / `<leader>sh` | Split vertical / horizontal |
| `<leader>se` / `<leader>sx` | Equalize / close split      |
| `<leader>to` / `<leader>tx` | New / close tab             |
| `<leader>tn` / `<leader>tp` | Next / previous tab         |
| `<leader>bn` / `<leader>bp` | Next / previous buffer      |
| `<leader>bd` | Delete current buffer           |

**Editing / misc**

| Key          | Action                          |
| ------------ | ------------------------------- |
| `jj`         | Escape (insert mode)            |
| `<leader><space>` | Clear search highlight     |
| `<A-j>` / `<A-k>` | Move line/selection down / up |
| `<leader>=`  | Re-indent the whole file        |
| `<leader>w`  | Toggle soft word wrap           |
| `<leader>mr` | Toggle markdown rendering       |
| `<leader>es` / `<leader>ds` | Spellcheck on / off  |

To swap the colorscheme back to nightfly, set `enabled = true` in
`nvim/lua/plugins/ui.nightfly.lua` and `enabled = false` in `ui.lua`.

## tmux keys & options

Prefix is <kbd>C-a</kbd> (remapped from `C-b`). `docs/tmux.md` has the full
cheat sheet; the essentials:

**Keys** (`prefix` = `C-a`)

| Key                    | Action                                    |
| ---------------------- | ----------------------------------------- |
| `C-h/j/k/l`            | Move between panes (no prefix; spans nvim & tmux) |
| `prefix \|` / `prefix -` | Split horizontally / vertically         |
| `prefix h/j/k/l`       | Resize focused pane by 5 cells (repeatable) |
| `prefix m`             | Toggle pane zoom (fullscreen)             |
| `prefix R` / `prefix T`| Resize pane to an exact width / height %  |
| `prefix r`             | Reload `~/.tmux.conf`                      |

**Key options**

| Option                       | Why                                       |
| ---------------------------- | ----------------------------------------- |
| `prefix C-a`                 | Easier reach than the default `C-b`       |
| `mouse on`                   | Click/scroll/drag to select & resize panes |
| `mode-keys vi`               | vi-style copy mode (`y` / `Enter` to yank)|
| `set-clipboard on`           | Yanks go to the system clipboard          |
| `base-index 1` / `pane-base-index 1` | Windows & panes count from 1      |
| `renumber-windows on`        | No gaps in window numbers after closing   |
| `escape-time 0`              | No lag on `<Esc>` (important inside nvim) |
| `focus-events on`            | Lets nvim/vimade react to pane focus changes |
| `aggressive-resize on`       | Panes resize to the active client         |

Plugins (via [TPM](https://github.com/tmux-plugins/tpm)): `vim-tmux-navigator`,
`tmux-resurrect`, `tmux-continuum` (auto-saves sessions every 15 min).

## License

[MIT](LICENSE.md)
