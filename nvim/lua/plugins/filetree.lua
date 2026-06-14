return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
    init = function()
      -- Disable netrw so nvim-tree is the only file explorer
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    opts = {
      update_focused_file = { enable = true },
      view = { width = 35, side = "left" },
      git = { ignore = false },
      filters = {
        custom = { "__pycache__" },
      },
      renderer = {
        group_empty = true,
        indent_markers = { enable = true },
        icons = {
          -- Minimal, single-width glyphs only. Per-filetype devicons are
          -- disabled (they render wide and overflow with the regular Nerd Font,
          -- and a "tmux" folder must not show the tmux icon). All files share
          -- one simple glyph; folders use plain open/closed folder glyphs.
          web_devicons = {
            file = { enable = false },
            folder = { enable = false },
          },
          glyphs = {
            default = "",
            symlink = "",
            folder = {
              -- Triangle arrows show what's expandable/collapsed. These are
              -- plain Unicode (not nerd glyphs), so they stay single-width.
              arrow_closed = "▸",
              arrow_open = "▾",
              default = "",
              open = "",
              empty = "",
              empty_open = "",
              symlink = "",
              symlink_open = "",
            },
          },
        },
      },
    },
  },
}
