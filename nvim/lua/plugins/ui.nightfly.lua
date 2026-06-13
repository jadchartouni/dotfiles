-- Fallback colorscheme. Kept in the repo but NOT loaded.
-- To switch back to nightfly: set enabled = true here and enabled = false in ui.lua.
return {
  {
    "bluz71/vim-nightfly-colors",
    name = "nightfly",
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme nightfly")
    end,
  },
}
