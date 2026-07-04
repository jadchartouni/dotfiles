-- Enable soft word wrap for prose filetypes. The wrap *style* (linebreak +
-- breakindent + breakindentopt=shift:3) is global in options.lua, so just
-- flipping wrap on here gives these files the full enhanced wrapping.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
  end,
})
