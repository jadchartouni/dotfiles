-- Shortcut
local opt = vim.opt

-- Line numbers
opt.relativenumber = true
opt.number = true

-- Tabs and indentation
opt.expandtab = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.autoindent = true
opt.smartindent = true
opt.breakindent = true
-- Hanging indent for wrapped lines: list items (per formatlistpat) continue
-- aligned under their text ("- " hangs by 2, "1. " by 3); plain paragraphs
-- wrap with no extra shift. Markdown's ftplugin brings its own formatlistpat.
opt.breakindentopt = "list:-1"
opt.formatlistpat = [[^\s*\%([-*+]\|\d\+[.)]\)\s\+]] -- bullets + numbered lists

-- Line wrapping: off by default; prose filetypes turn it on (autocmds.lua) and
-- <leader>w toggles it. linebreak + breakindent(opt) make every wrap break at
-- word boundaries and stay indented, wherever wrap gets enabled.
opt.wrap = false
opt.linebreak = true

-- Autocomplete
opt.wildmode = "longest:full,full"
opt.completeopt = "menuone,longest,preview" -- Set completeopt to have a better completion experience

-- Search settings
opt.ignorecase = true
opt.smartcase = true

-- Cursor line
opt.cursorline = true

-- Scrolling
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Mouse settings
opt.mouse = "a"

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.fillchars:append({ eob = " " }) -- Remove ~ from end of buffer
-- Heavy box-drawing chars for split separators (incl. junctions), so window
-- borders read as solid panel frames instead of thin hairlines.
opt.fillchars:append({
  vert = "┃",
  vertleft = "┫",
  vertright = "┣",
  verthoriz = "╋",
  horiz = "━",
  horizup = "┻",
  horizdown = "┳",
})

-- Window title
opt.title = true

-- Clipboard
opt.clipboard = "unnamedplus" -- Use system clipboard

-- Split windows
opt.splitright = true
opt.splitbelow = true

opt.iskeyword:append("-")

-- Text spelling
opt.spell = false

-- Changes management
opt.confirm = true -- Ask if exiting without writing
opt.undofile = true -- Persistent undo
opt.backup = true -- Automatic backup
opt.backupdir:remove(".") -- Keep backups out of the current directory
