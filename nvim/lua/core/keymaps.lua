-- Comma is my leader
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Shortcut
local keymap = vim.keymap

-- General keymaps
keymap.set("i", "jj", "<esc>")

-- Move properly when wrapping
keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })

-- Deselect search
keymap.set("n", "<leader><space>", ":nohl<cr>")

-- Reselect visual selection after indenting
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- Maintain the cursor position when yanking a visual selection
-- http://ddrscott.github.io/blog/2016/yank-without-jank/
keymap.set("v", "y", "myy`y")
keymap.set("v", "Y", "myY`y")

-- Paste replace visual selection without copying it
keymap.set("v", "p", '"_dP')

-- Easy insertion of a trailing ; or , from insert mode
keymap.set("i", ";;", "<Esc>A;<Esc>")
keymap.set("i", ",,", "<Esc>A,<Esc>")

-- Move text up and down
keymap.set("i", "<A-j>", "<Esc>:move .+1<CR>==gi")
keymap.set("i", "<A-k>", "<Esc>:move .-2<CR>==gi")
keymap.set("x", "<A-j>", ":move '>+1<CR>gv-gv")
keymap.set("x", "<A-k>", ":move '<-2<CR>gv-gv")

-- When deleting a character, don't copy it to clipboard
keymap.set("n", "x", '"_x')

-- Toggle spellcheck
keymap.set("n", "<leader>es", ":setlocal spell spelllang=en_us<cr>")
keymap.set("n", "<leader>ds", ":setlocal nospell<cr>")

-- Window split
keymap.set("n", "<leader>sv", "<C-w>v") -- Split window vertically
keymap.set("n", "<leader>sh", "<C-w>s") -- Split window horizontally
keymap.set("n", "<leader>se", "<C-w>=") -- Make split windows equal width
keymap.set("n", "<leader>sx", ":close<cr>") -- Close current split window

-- Tabs
keymap.set("n", "<leader>to", ":tabnew<cr>") -- Open a new tab
keymap.set("n", "<leader>tx", ":tabclose<cr>") -- Close current tab
keymap.set("n", "<leader>tn", ":tabn<cr>") -- Go to next tab
keymap.set("n", "<leader>tp", ":tabp<cr>") -- Go to pevious tab

-- Buffers
keymap.set("n", "<leader>bn", ":bn<cr>") -- Go to next buffer
keymap.set("n", "<leader>bp", ":bp<cr>") -- Go to previous buffer
keymap.set("n", "<leader>bd", function() -- Delete current buffer, keep the window
  -- Plain :bd CLOSES the window when another window exists (e.g. the tree),
  -- so show a different buffer here first, then delete the old one.
  local cur = vim.api.nvim_get_current_buf()
  local other_listed = vim.tbl_filter(function(b)
    return vim.bo[b].buflisted and b ~= cur
  end, vim.api.nvim_list_bufs())
  vim.cmd(#other_listed > 0 and "bprevious" or "enew")
  vim.cmd("bdelete " .. cur)
end, { desc = "Delete buffer without closing the window" })
keymap.set("n", "<leader>bt", function() -- Toggle the buffer tab bar
  vim.opt.showtabline = (vim.opt.showtabline:get() == 0) and 2 or 0
end, { desc = "Toggle bufferline visibility" })

-- Re-indent the whole file, keeping the cursor in place
keymap.set("n", "<leader>=", "mzgg=G`z")

-- Toggle soft word wrap (with word-boundary breaking) for the current buffer
keymap.set("n", "<leader>w", function()
  vim.wo.wrap = not vim.wo.wrap
  vim.wo.linebreak = vim.wo.wrap
end, { desc = "Toggle word wrap" })

-- Plugin: nvim-tree
keymap.set("n", "<leader>ft", ":NvimTreeToggle<cr>") -- Toggle file tree
keymap.set("n", "<leader>fe", ":NvimTreeFindFile<cr>") -- Reveal current file in tree

-- Plugin: render-markdown
keymap.set("n", "<leader>mr", ":RenderMarkdown toggle<cr>") -- Toggle markdown rendering
