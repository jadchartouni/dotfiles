return {
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    -- Load after the colorscheme so the palette is on the runtime path.
    config = function()
      local ok, palette = pcall(require, "sentrycore.palette")
      local c = ok and palette.colors or {}

      require("bufferline").setup({
        options = {
          mode = "buffers",
          numbers = "none",
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          diagnostics = false, -- no LSP configured yet
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = false, -- drop the global close button on the far right
          color_icons = true,
          -- Straight vertical separators (no slant, no rounded corners).
          separator_style = "thin",
          always_show_bufferline = true,
          offsets = {
            {
              filetype = "NvimTree",
              text = "Explorer",
              highlight = "Directory",
              separator = true,
            },
          },
        },
        highlights = {
          fill = { bg = c.bg_dark },

          -- Inactive buffers
          background = { fg = c.fg_dark, bg = c.bg_alt },
          buffer_visible = { fg = c.fg_dim, bg = c.bg_alt },
          -- Active buffer connects to the editor background
          buffer_selected = { fg = c.fg, bg = c.bg, bold = true, italic = false },

          -- Straight separators
          separator = { fg = c.bg_dark, bg = c.bg_alt },
          separator_visible = { fg = c.bg_dark, bg = c.bg_alt },
          separator_selected = { fg = c.bg_dark, bg = c.bg },

          -- Selected indicator bar
          indicator_selected = { fg = c.purple_br, bg = c.bg },
          indicator_visible = { fg = c.bg_alt, bg = c.bg_alt },

          -- Modified (unsaved) dot
          modified = { fg = c.orange, bg = c.bg_alt },
          modified_visible = { fg = c.orange, bg = c.bg_alt },
          modified_selected = { fg = c.teal, bg = c.bg },

          -- Close buttons
          close_button = { fg = c.fg_dark, bg = c.bg_alt },
          close_button_visible = { fg = c.fg_dim, bg = c.bg_alt },
          close_button_selected = { fg = c.red_br, bg = c.bg },

          -- Duplicate-name path prefixes
          duplicate = { fg = c.fg_dark, bg = c.bg_alt, italic = true },
          duplicate_visible = { fg = c.fg_dim, bg = c.bg_alt, italic = true },
          duplicate_selected = { fg = c.fg_dim, bg = c.bg, italic = true },
        },
      })
    end,
  },
}
