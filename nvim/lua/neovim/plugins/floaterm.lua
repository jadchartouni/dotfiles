vim.keymap.set('n', '<C-w>', ':FloatermToggle scratch<cr>')
vim.keymap.set('t', '<C-w>', '<C-\\><C-n>:FloatermToggle scratch<cr>')

vim.g.floaterm_gitcommit = 'floaterm'
vim.g.floaterm_autoinsert = 1
vim.g.floaterm_width = 0.8
vim.g.floaterm_height = 0.8
vim.g.floaterm_wintitle = 0

vim.cmd([[
    highlight link Floaterm CursorLine
    highlight link FloatermBorder CursorLineBg
]])