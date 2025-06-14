-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/jadchartouni/.cache/nvim/packer_hererocks/2.1.1748459687/share/lua/5.1/?.lua;/Users/jadchartouni/.cache/nvim/packer_hererocks/2.1.1748459687/share/lua/5.1/?/init.lua;/Users/jadchartouni/.cache/nvim/packer_hererocks/2.1.1748459687/lib/luarocks/rocks-5.1/?.lua;/Users/jadchartouni/.cache/nvim/packer_hererocks/2.1.1748459687/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/jadchartouni/.cache/nvim/packer_hererocks/2.1.1748459687/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  LuaSnip = {
    config = { "\27LJ\2\n6\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\27neovim.plugins.luasnip\frequire\0" },
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/LuaSnip",
    url = "https://github.com/L3MON4D3/LuaSnip"
  },
  ["bufferline.nvim"] = {
    config = { "\27LJ\2\n9\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\30neovim.plugins.bufferline\frequire\0" },
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/bufferline.nvim",
    url = "https://github.com/akinsho/bufferline.nvim"
  },
  ["cmp-buffer"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/cmp-buffer",
    url = "https://github.com/hrsh7th/cmp-buffer"
  },
  ["cmp-cmdline"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/cmp-cmdline",
    url = "https://github.com/hrsh7th/cmp-cmdline"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["cmp-nvim-lsp-signature-help"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp-signature-help",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp-signature-help"
  },
  ["cmp-nvim-lua"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/cmp-nvim-lua",
    url = "https://github.com/hrsh7th/cmp-nvim-lua"
  },
  ["cmp-path"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/cmp-path",
    url = "https://github.com/hrsh7th/cmp-path"
  },
  cmp_luasnip = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/cmp_luasnip",
    url = "https://github.com/saadparwaiz1/cmp_luasnip"
  },
  ["copilot-cmp"] = {
    config = { "\27LJ\2\n9\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\16copilot_cmp\frequire\0" },
    load_after = {
      ["copilot.lua"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/opt/copilot-cmp",
    url = "https://github.com/zbirenbaum/copilot-cmp"
  },
  ["copilot.lua"] = {
    after = { "copilot-cmp" },
    commands = { "Copilot" },
    config = { "\27LJ\2\n6\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\27neovim.plugins.copilot\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/opt/copilot.lua",
    url = "https://github.com/zbirenbaum/copilot.lua"
  },
  ["gitsigns.nvim"] = {
    config = { "\27LJ\2\ní\1\0\1\a\0\v\0\0196\1\0\0009\1\1\0019\1\2\1'\3\3\0'\4\4\0'\5\5\0005\6\6\0=\0\a\6B\1\5\0016\1\0\0009\1\1\0019\1\2\1'\3\3\0'\4\b\0'\5\t\0005\6\n\0=\0\a\6B\1\5\1K\0\1\0\1\0\2\vbuffer\0\texpr\0021&diff ? '[c' : '<cmd>Gitsigns prev_hunk<cr>'\a[h\vbuffer\1\0\2\vbuffer\0\texpr\0021&diff ? ']c' : '<cmd>Gitsigns next_hunk<cr>'\a]h\6n\bset\vkeymap\bvimk\1\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0003\3\4\0=\3\5\2B\0\2\1K\0\1\0\14on_attach\0\1\0\2\14on_attach\0\18sign_priority\3\20\nsetup\rgitsigns\frequire\0" },
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
    url = "https://github.com/lewis6991/gitsigns.nvim"
  },
  ["indent-blankline.nvim"] = {
    config = { "\27LJ\2\n?\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0$neovim.plugins.indent-blankline\frequire\0" },
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/indent-blankline.nvim",
    url = "https://github.com/lukas-reineke/indent-blankline.nvim"
  },
  ["lspkind-nvim"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/lspkind-nvim",
    url = "https://github.com/onsails/lspkind-nvim"
  },
  ["lualine.nvim"] = {
    config = { "\27LJ\2\n6\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\27neovim.plugins.lualine\frequire\0" },
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  ["mason-lspconfig.nvim"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/mason-lspconfig.nvim",
    url = "https://github.com/williamboman/mason-lspconfig.nvim"
  },
  ["mason-null-ls.nvim"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/mason-null-ls.nvim",
    url = "https://github.com/jayp0521/mason-null-ls.nvim"
  },
  ["mason.nvim"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/mason.nvim",
    url = "https://github.com/williamboman/mason.nvim"
  },
  ["null-ls.nvim"] = {
    config = { "\27LJ\2\n6\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\27neovim.plugins.null-ls\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/opt/null-ls.nvim",
    url = "https://github.com/jose-elias-alvarez/null-ls.nvim"
  },
  ["nvim-cmp"] = {
    config = { "\27LJ\2\n7\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\28neovim.plugins.nvim-cmp\frequire\0" },
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-lspconfig"] = {
    after = { "null-ls.nvim" },
    config = { "\27LJ\2\n=\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\"neovim.plugins.nvim-lspconfig\frequire\0" },
    loaded = true,
    only_config = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-tree.lua"] = {
    config = { "\27LJ\2\n8\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\29neovim.plugins.nvim-tree\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/opt/nvim-tree.lua",
    url = "https://github.com/kyazdani42/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    config = { "\27LJ\2\n>\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0#neovim.plugins.nvim-treesitter\frequire\0" },
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-treesitter-textobjects"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/nvim-treesitter-textobjects",
    url = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects"
  },
  ["nvim-ts-context-commentstring"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/nvim-ts-context-commentstring",
    url = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/kyazdani42/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  playground = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/playground",
    url = "https://github.com/nvim-treesitter/playground"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["schemastore.nvim"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/schemastore.nvim",
    url = "https://github.com/b0o/schemastore.nvim"
  },
  ["splitjoin.vim"] = {
    config = { "\27LJ\2\n8\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\29neovim.plugins.splitjoin\frequire\0" },
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/splitjoin.vim",
    url = "https://github.com/AndrewRadev/splitjoin.vim"
  },
  ["telescope-file-browser.nvim"] = {
    config = { "\27LJ\2\nE\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0*neovim.plugins.telescope-file-browser\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/opt/telescope-file-browser.nvim",
    url = "https://github.com/nvim-telescope/telescope-file-browser.nvim"
  },
  ["telescope-fzf-native.nvim"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim",
    url = "https://github.com/nvim-telescope/telescope-fzf-native.nvim"
  },
  ["telescope-live-grep-args.nvim"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/telescope-live-grep-args.nvim",
    url = "https://github.com/nvim-telescope/telescope-live-grep-args.nvim"
  },
  ["telescope.nvim"] = {
    after = { "telescope-file-browser.nvim" },
    config = { "\27LJ\2\n8\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\29neovim.plugins.telescope\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/opt/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["todo-comments.nvim"] = {
    config = { "\27LJ\2\n?\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\18todo-comments\frequire\0" },
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/todo-comments.nvim",
    url = "https://github.com/folke/todo-comments.nvim"
  },
  ["vim-commentary"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/vim-commentary",
    url = "https://github.com/tpope/vim-commentary"
  },
  ["vim-eunuch"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/vim-eunuch",
    url = "https://github.com/tpope/vim-eunuch"
  },
  ["vim-floaterm"] = {
    config = { "\27LJ\2\n;\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0 neovim.plugins.vim-floaterm\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/opt/vim-floaterm",
    url = "https://github.com/voldikss/vim-floaterm"
  },
  ["vim-heritage"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/vim-heritage",
    url = "https://github.com/jessarcher/vim-heritage"
  },
  ["vim-lastplace"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/vim-lastplace",
    url = "https://github.com/farmergreg/vim-lastplace"
  },
  ["vim-nightfly-colors"] = {
    after = { "telescope.nvim", "vim-floaterm", "nvim-tree.lua", "telescope-file-browser.nvim" },
    config = { "\27LJ\2\nÿ\4\0\0\t\0\24\0X6\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\0\0009\0\3\0009\0\4\0)\2\0\0'\3\5\0005\4\t\0006\5\0\0009\5\3\0059\5\6\5'\a\a\0+\b\2\0B\5\3\0029\5\b\5=\5\n\0046\5\0\0009\5\3\0059\5\6\5'\a\a\0+\b\2\0B\5\3\0029\5\b\5=\5\v\4B\0\4\0016\0\0\0009\0\3\0009\0\4\0)\2\0\0'\3\f\0005\4\15\0006\5\0\0009\5\3\0059\5\6\5'\a\r\0+\b\2\0B\5\3\0029\5\14\5=\5\n\0046\5\0\0009\5\3\0059\5\6\5'\a\16\0+\b\2\0B\5\3\0029\5\b\5=\5\v\4B\0\4\0016\0\0\0009\0\3\0009\0\4\0)\2\0\0'\3\17\0005\4\19\0006\5\0\0009\5\3\0059\5\6\5'\a\18\0+\b\2\0B\5\3\0029\5\b\5=\5\n\0046\5\0\0009\5\3\0059\5\6\5'\a\18\0+\b\2\0B\5\3\0029\5\b\5=\5\v\4B\0\4\0016\0\0\0009\0\3\0009\0\4\0)\2\0\0'\3\20\0005\4\21\0B\0\4\0016\0\0\0009\0\3\0009\0\4\0)\2\0\0'\3\22\0005\4\23\0B\0\4\1K\0\1\0\1\0\1\afg\f#2c3043\24IndentBlanklineChar\1\0\1\afg\f#2c3043\25NvimTreeIndentMarker\1\0\2\afg\0\abg\0\15CursorLine\17CursorLineBg\15StatusLine\1\0\2\afg\0\abg\0\15foreground\fNonText\22StatusLineNonText\abg\afg\1\0\2\afg\0\abg\0\15background\16NormalFloat\24nvim_get_hl_by_name\16FloatBorder\16nvim_set_hl\bapi\25colorscheme nightfly\bcmd\bvim\0" },
    loaded = true,
    only_config = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/vim-nightfly-colors",
    url = "https://github.com/bluz71/vim-nightfly-colors"
  },
  ["vim-pasta"] = {
    config = { "\27LJ\2\n8\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\29neovim.plugins.vim-pasta\frequire\0" },
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/vim-pasta",
    url = "https://github.com/sickill/vim-pasta"
  },
  ["vim-polyglot"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/vim-polyglot",
    url = "https://github.com/sheerun/vim-polyglot"
  },
  ["vim-repeat"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/vim-repeat",
    url = "https://github.com/tpope/vim-repeat"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/vim-surround",
    url = "https://github.com/tpope/vim-surround"
  },
  ["vim-textobj-user"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/vim-textobj-user",
    url = "https://github.com/kana/vim-textobj-user"
  },
  ["vim-textobj-xmlattr"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/vim-textobj-xmlattr",
    url = "https://github.com/whatyouhide/vim-textobj-xmlattr"
  },
  ["vim-tmux-navigator"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/vim-tmux-navigator",
    url = "https://github.com/christoomey/vim-tmux-navigator"
  },
  ["vim-unimpaired"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/vim-unimpaired",
    url = "https://github.com/tpope/vim-unimpaired"
  },
  ["vim-visual-star-search"] = {
    loaded = true,
    path = "/Users/jadchartouni/.local/share/nvim/site/pack/packer/start/vim-visual-star-search",
    url = "https://github.com/nelstrom/vim-visual-star-search"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: indent-blankline.nvim
time([[Config for indent-blankline.nvim]], true)
try_loadstring("\27LJ\2\n?\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0$neovim.plugins.indent-blankline\frequire\0", "config", "indent-blankline.nvim")
time([[Config for indent-blankline.nvim]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\2\n>\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0#neovim.plugins.nvim-treesitter\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: LuaSnip
time([[Config for LuaSnip]], true)
try_loadstring("\27LJ\2\n6\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\27neovim.plugins.luasnip\frequire\0", "config", "LuaSnip")
time([[Config for LuaSnip]], false)
-- Config for: vim-pasta
time([[Config for vim-pasta]], true)
try_loadstring("\27LJ\2\n8\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\29neovim.plugins.vim-pasta\frequire\0", "config", "vim-pasta")
time([[Config for vim-pasta]], false)
-- Config for: lualine.nvim
time([[Config for lualine.nvim]], true)
try_loadstring("\27LJ\2\n6\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\27neovim.plugins.lualine\frequire\0", "config", "lualine.nvim")
time([[Config for lualine.nvim]], false)
-- Config for: bufferline.nvim
time([[Config for bufferline.nvim]], true)
try_loadstring("\27LJ\2\n9\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\30neovim.plugins.bufferline\frequire\0", "config", "bufferline.nvim")
time([[Config for bufferline.nvim]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
try_loadstring("\27LJ\2\n=\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\"neovim.plugins.nvim-lspconfig\frequire\0", "config", "nvim-lspconfig")
time([[Config for nvim-lspconfig]], false)
-- Config for: vim-nightfly-colors
time([[Config for vim-nightfly-colors]], true)
try_loadstring("\27LJ\2\nÿ\4\0\0\t\0\24\0X6\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\0\0009\0\3\0009\0\4\0)\2\0\0'\3\5\0005\4\t\0006\5\0\0009\5\3\0059\5\6\5'\a\a\0+\b\2\0B\5\3\0029\5\b\5=\5\n\0046\5\0\0009\5\3\0059\5\6\5'\a\a\0+\b\2\0B\5\3\0029\5\b\5=\5\v\4B\0\4\0016\0\0\0009\0\3\0009\0\4\0)\2\0\0'\3\f\0005\4\15\0006\5\0\0009\5\3\0059\5\6\5'\a\r\0+\b\2\0B\5\3\0029\5\14\5=\5\n\0046\5\0\0009\5\3\0059\5\6\5'\a\16\0+\b\2\0B\5\3\0029\5\b\5=\5\v\4B\0\4\0016\0\0\0009\0\3\0009\0\4\0)\2\0\0'\3\17\0005\4\19\0006\5\0\0009\5\3\0059\5\6\5'\a\18\0+\b\2\0B\5\3\0029\5\b\5=\5\n\0046\5\0\0009\5\3\0059\5\6\5'\a\18\0+\b\2\0B\5\3\0029\5\b\5=\5\v\4B\0\4\0016\0\0\0009\0\3\0009\0\4\0)\2\0\0'\3\20\0005\4\21\0B\0\4\0016\0\0\0009\0\3\0009\0\4\0)\2\0\0'\3\22\0005\4\23\0B\0\4\1K\0\1\0\1\0\1\afg\f#2c3043\24IndentBlanklineChar\1\0\1\afg\f#2c3043\25NvimTreeIndentMarker\1\0\2\afg\0\abg\0\15CursorLine\17CursorLineBg\15StatusLine\1\0\2\afg\0\abg\0\15foreground\fNonText\22StatusLineNonText\abg\afg\1\0\2\afg\0\abg\0\15background\16NormalFloat\24nvim_get_hl_by_name\16FloatBorder\16nvim_set_hl\bapi\25colorscheme nightfly\bcmd\bvim\0", "config", "vim-nightfly-colors")
time([[Config for vim-nightfly-colors]], false)
-- Config for: gitsigns.nvim
time([[Config for gitsigns.nvim]], true)
try_loadstring("\27LJ\2\ní\1\0\1\a\0\v\0\0196\1\0\0009\1\1\0019\1\2\1'\3\3\0'\4\4\0'\5\5\0005\6\6\0=\0\a\6B\1\5\0016\1\0\0009\1\1\0019\1\2\1'\3\3\0'\4\b\0'\5\t\0005\6\n\0=\0\a\6B\1\5\1K\0\1\0\1\0\2\vbuffer\0\texpr\0021&diff ? '[c' : '<cmd>Gitsigns prev_hunk<cr>'\a[h\vbuffer\1\0\2\vbuffer\0\texpr\0021&diff ? ']c' : '<cmd>Gitsigns next_hunk<cr>'\a]h\6n\bset\vkeymap\bvimk\1\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0003\3\4\0=\3\5\2B\0\2\1K\0\1\0\14on_attach\0\1\0\2\14on_attach\0\18sign_priority\3\20\nsetup\rgitsigns\frequire\0", "config", "gitsigns.nvim")
time([[Config for gitsigns.nvim]], false)
-- Config for: nvim-cmp
time([[Config for nvim-cmp]], true)
try_loadstring("\27LJ\2\n7\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\28neovim.plugins.nvim-cmp\frequire\0", "config", "nvim-cmp")
time([[Config for nvim-cmp]], false)
-- Config for: splitjoin.vim
time([[Config for splitjoin.vim]], true)
try_loadstring("\27LJ\2\n8\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\29neovim.plugins.splitjoin\frequire\0", "config", "splitjoin.vim")
time([[Config for splitjoin.vim]], false)
-- Config for: todo-comments.nvim
time([[Config for todo-comments.nvim]], true)
try_loadstring("\27LJ\2\n?\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\18todo-comments\frequire\0", "config", "todo-comments.nvim")
time([[Config for todo-comments.nvim]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd null-ls.nvim ]]

-- Config for: null-ls.nvim
try_loadstring("\27LJ\2\n6\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\27neovim.plugins.null-ls\frequire\0", "config", "null-ls.nvim")

vim.cmd [[ packadd nvim-tree.lua ]]

-- Config for: nvim-tree.lua
try_loadstring("\27LJ\2\n8\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\29neovim.plugins.nvim-tree\frequire\0", "config", "nvim-tree.lua")

vim.cmd [[ packadd telescope.nvim ]]

-- Config for: telescope.nvim
try_loadstring("\27LJ\2\n8\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\29neovim.plugins.telescope\frequire\0", "config", "telescope.nvim")

vim.cmd [[ packadd telescope-file-browser.nvim ]]

-- Config for: telescope-file-browser.nvim
try_loadstring("\27LJ\2\nE\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0*neovim.plugins.telescope-file-browser\frequire\0", "config", "telescope-file-browser.nvim")

vim.cmd [[ packadd vim-floaterm ]]

-- Config for: vim-floaterm
try_loadstring("\27LJ\2\n;\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0 neovim.plugins.vim-floaterm\frequire\0", "config", "vim-floaterm")

time([[Sequenced loading]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.api.nvim_create_user_command, 'Copilot', function(cmdargs)
          require('packer.load')({'copilot.lua'}, { cmd = 'Copilot', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'copilot.lua'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Copilot ', 'cmdline')
      end})
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'copilot.lua'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
