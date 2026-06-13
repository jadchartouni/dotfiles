return {
  {
    dir = "~/.config/nvim/themes/sentrycore.nvim",
    name = "sentrycore",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme sentrycore")
    end,
  },
}
