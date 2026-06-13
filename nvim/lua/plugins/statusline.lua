return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        -- "auto" derives colors from the active colorscheme (sentrycore),
        -- since sentrycore doesn't ship a dedicated lualine theme.
        theme = "auto",
        section_separators = "",
        component_separators = "",
        globalstatus = true,
      },
    },
  },
}
