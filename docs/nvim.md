# Neovim

Neovim configuration and cheat sheet. A clean file editor (not an IDE): no LSP,
completion, or formatters by design. Built on lazy.nvim, themed with SentryCore.

Leader is `,` (comma). Below, `<leader>` means `,`.

## Essential keys

| Description                         | Command / key binding |
| ----------------------------------- | --------------------- |
| Escape insert mode                  | `j` `j`               |
| Clear search highlight              | `<leader>` `Space`    |
| Insert trailing `;`                 | `;` `;` (insert mode) |
| Insert trailing `,`                 | `,` `,` (insert mode) |
| Move line / selection down          | `Alt + j`             |
| Move line / selection up            | `Alt + k`             |
| Re-indent the whole file            | `<leader>` `=`        |
| Toggle soft word wrap               | `<leader>` `w`        |
| Spellcheck on / off                 | `<leader>es` / `<leader>ds` |

Wrapped lines: `j` / `k` move by screen line (gj/gk) when no count is given.

## Find & files

Fuzzy finding with Telescope (`telescope-fzf-native` sorter) + nvim-tree.

| Description                     | Command / key binding |
| ------------------------------- | --------------------- |
| Find files by name              | `<leader>ff`          |
| Live grep (search contents)     | `<leader>fg`          |
| Find open buffers               | `<leader>fb`          |
| Recent files                    | `<leader>fr`          |
| Help tags                       | `<leader>fh`          |
| Toggle file tree                | `<leader>ft`          |
| Reveal current file in the tree | `<leader>fe`          |

Inside a Telescope prompt:

| Description                          | Command / key binding |
| ------------------------------------ | --------------------- |
| Next / previous result (while typing)| `Ctrl + j` / `Ctrl + k` |
| Next / previous result (default)     | `Ctrl + n` / `Ctrl + p` |
| Normal mode, then move with `j`/`k`  | `Esc`                 |
| Open selection                       | `Enter`               |
| Open in split / vsplit               | `Ctrl + x` / `Ctrl + v` |
| Close                                | `Esc` `Esc` / `Ctrl + c` |

## Windows & splits

| Description                  | Command / key binding |
| ---------------------------- | --------------------- |
| Split vertically (side by side) | `<leader>sv`       |
| Split horizontally (stacked) | `<leader>sh`          |
| Equalize split sizes         | `<leader>se`          |
| Close current split          | `<leader>sx`          |
| Move between splits / tmux panes | `Ctrl + h/j/k/l`  |

New splits open to the right and below (`splitright` / `splitbelow`).

## Tabs

| Description       | Command / key binding |
| ----------------- | --------------------- |
| New tab           | `<leader>to`          |
| Close tab         | `<leader>tx`          |
| Next tab          | `<leader>tn`          |
| Previous tab      | `<leader>tp`          |

## Buffers

| Description           | Command / key binding |
| --------------------- | --------------------- |
| Next buffer           | `<leader>bn`          |
| Previous buffer       | `<leader>bp`          |
| Delete current buffer | `<leader>bd`          |

## Markdown

| Description                | Command / key binding |
| -------------------------- | --------------------- |
| Toggle markdown rendering  | `<leader>mr`          |

## Notable options

| Option                          | Effect                                     |
| ------------------------------- | ------------------------------------------ |
| `number` + `relativenumber`     | Hybrid line numbers                        |
| `expandtab`, `shiftwidth = 4`   | 4-space indentation, no tabs               |
| `ignorecase` + `smartcase`      | Case-insensitive search unless you type a capital |
| `wrap = false`                  | No line wrapping (toggle with `<leader>w`) |
| `scrolloff = 8`                 | Keep 8 lines of context around the cursor  |
| `clipboard = unnamedplus`       | Yank/paste uses the system clipboard       |
| `splitright` / `splitbelow`     | New splits open right / below              |
| `undofile`                      | Persistent undo across sessions            |
| `backup`                        | Automatic backups (kept out of cwd)        |
| `confirm`                       | Prompt instead of failing on unsaved exit  |
| `termguicolors`                 | True-color (required by SentryCore)        |

## Plugins

Managed by [lazy.nvim](https://github.com/folke/lazy.nvim). Run `:Lazy` for the
UI, `:Lazy sync` to install/update, `:Lazy clean` to prune removed plugins.

| Plugin                       | Purpose                                   |
| ---------------------------- | ----------------------------------------- |
| `telescope.nvim` (+ fzf-native) | Fuzzy finder: files, live grep, buffers |
| `nvim-tree.lua`              | File explorer                             |
| `nvim-treesitter` (main)     | Syntax highlighting                       |
| `lualine.nvim`              | Status line                               |
| `vimade`                     | Dim inactive windows                      |
| `render-markdown.nvim`       | In-editor markdown rendering              |
| `vim-tmux-navigator`         | Seamless `Ctrl + h/j/k/l` across nvim & tmux |

## Theme

SentryCore is the default colorscheme (`nvim/themes/sentrycore.nvim`). To switch
back to nightfly, set `enabled = true` in `nvim/lua/plugins/ui.nightfly.lua` and
`enabled = false` in `ui.lua`.
