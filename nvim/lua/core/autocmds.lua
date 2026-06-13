-- Enable soft word wrap (breaking at word boundaries) for prose filetypes.
-- breakindent is set globally in options.lua so wrapped lines stay aligned.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})
