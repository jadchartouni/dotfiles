-- Enable soft word wrap for prose filetypes. The wrap *style* (linebreak +
-- breakindent + hanging list indent via breakindentopt=list:-1) is global in
-- options.lua, so just flipping wrap on gives the full enhanced wrapping.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
  end,
})
