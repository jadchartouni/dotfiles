-- Comma is my leader
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Shortcut
local keymap = vim.keymap

-- General keymaps
keymap.set("i", "jj", "<esc>")

-- Move properly when wrapping
keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })
keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })

-- Deselect search
keymap.set("n", "<leader><space>", ":nohl<cr>")

-- Reselect visual selection after indenting
keymap.set('v', '<', '<gv')
keymap.set('v', '>', '>gv')

-- Maintain the cursor position when yanking a visual selection
-- http://ddrscott.github.io/blog/2016/yank-without-jank/
keymap.set('v', 'y', 'myy`y')
keymap.set('v', 'Y', 'myY`y')

-- Paste replace visual selection without copying it
keymap.set('v', 'p', '"_dP')

-- Easy insertion of a trailing ; or , from insert mode
keymap.set('i', ';;', '<Esc>A;<Esc>')
keymap.set('i', ',,', '<Esc>A,<Esc>')

-- Move text up and down
keymap.set('i', '<A-j>', '<Esc>:move .+1<CR>==gi')
keymap.set('i', '<A-k>', '<Esc>:move .-2<CR>==gi')
keymap.set('x', '<A-j>', ":move '>+1<CR>gv-gv")
keymap.set('x', '<A-k>', ":move '<-2<CR>gv-gv")

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

-- Plugin: nvim-tree
keymap.set("n", "<leader>ft", ":NvimTreeToggle<cr>")

-- Plugin: telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- Find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>") -- Find string in current working directory as you type
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>") -- Find string under cursor in current working directory
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- List open buffers in current neovim instance
keymap.set("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>") -- List files from history
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- List available help tags

-- Plugin: telescope-file-browser
keymap.set("n", "<leader>fa", "<cmd>Telescope file_browser hidden=true path=~ grouped=true<cr>") -- Lanch the floating file browser

-- Plugin: todo-comments
keymap.set("n", "<leader>td", ":TodoTelescope<cr>") -- List available help tags
