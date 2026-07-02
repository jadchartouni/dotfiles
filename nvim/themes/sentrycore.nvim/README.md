# sentrycore.nvim

A Neovim colorscheme derived from the SentryCore brand identity. Deep indigo background, amethyst purple and quantum blue gradient accents, alert teal for success, alert red for errors.

Requires Neovim 0.8+ with `termguicolors` enabled.

## Install

This theme lives only in this dotfiles repo (there is no published GitHub
package) — install it as a local plugin.

### lazy.nvim (how these dotfiles load it — see `nvim/lua/plugins/ui.lua`)

```lua
{
  dir = vim.fn.stdpath("config") .. "/themes/sentrycore.nvim",
  name = "sentrycore",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("sentrycore")
  end,
}
```

### Manual install (no plugin manager)

Copy the plugin directly into Neovim's runtime path:

```bash
# Linux / macOS
cp -r sentrycore.nvim/* ~/.config/nvim/
```

This places `colors/sentrycore.lua` and `lua/sentrycore/` where Neovim looks for them. Then add to your `init.lua`:

```lua
vim.o.termguicolors = true
vim.cmd.colorscheme("sentrycore")
```

### As a local plugin (recommended for manual install)

Keep the plugin self-contained by dropping it into `pack/`:

```bash
mkdir -p ~/.local/share/nvim/site/pack/themes/start
cp -r sentrycore.nvim ~/.local/share/nvim/site/pack/themes/start/
```

Then:

```lua
vim.cmd.colorscheme("sentrycore")
```

## Activate

```vim
:colorscheme sentrycore
```

Or in `init.lua`:

```lua
vim.o.termguicolors = true
vim.cmd.colorscheme("sentrycore")
```

## Supported plugins

Treesitter, LSP diagnostics, Telescope, nvim-tree, neo-tree, gitsigns, nvim-cmp, which-key, indent-blankline, nvim-notify, plus all standard syntax groups.
