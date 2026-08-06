-- Floating filename label in the top-right corner of each split. Fixes the
-- side effect of lualine's `globalstatus`: with one statusline for the whole
-- editor, nothing says which file is in which split. Labels only appear when
-- there is more than one window.
--
-- TO REVERT: delete this file, then run `:Lazy clean` in nvim (or restart nvim
-- and lazy will prune it). Nothing else references it — removal is total.
return {
  {
    "b0o/incline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      local c = require("sentrycore.palette").colors
      require("incline").setup({
        hide = {
          only_win = true, -- no label when the window isn't competing with anything
        },
        window = {
          margin = { vertical = 0, horizontal = 1 },
        },
        render = function(props)
          local path = vim.api.nvim_buf_get_name(props.buf)
          local filename = path == "" and "[No Name]" or vim.fn.fnamemodify(path, ":t")
          local icon, icon_color = require("nvim-web-devicons").get_icon_color(filename)
          local modified = vim.bo[props.buf].modified
          return {
            icon and { icon, " ", guifg = props.focused and icon_color or nil } or "",
            filename,
            modified and { " ●", guifg = c.teal } or "",
            guibg = props.focused and c.bg_highlight or c.bg_alt,
            guifg = props.focused and c.fg or c.fg_dark,
          }
        end,
      })
    end,
  },
}
