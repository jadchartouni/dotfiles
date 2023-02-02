-- Auto-install packer if not installed
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
        vim.cmd([[packadd packer.nvim]])
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

-- Auto-command that reloads neovim whenever you save this file
vim.cmd([[
    augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile>
    augroup end
]])

-- Start packer
return require("packer").startup(function(use)
    use("wbthomason/packer.nvim") -- Packer, plugins manager

    -- Change colorscheme
    use({
        "bluz71/vim-nightfly-colors",
        config = function()
            vim.cmd("colorscheme nightfly")

            -- Hide the characters in FloatBorder
            vim.api.nvim_set_hl(0, "FloatBorder", {
                fg = vim.api.nvim_get_hl_by_name("NormalFloat", true).background,
                bg = vim.api.nvim_get_hl_by_name("NormalFloat", true).background,
            })

            -- Make the StatusLineNonText background the same as StatusLine
            vim.api.nvim_set_hl(0, 'StatusLineNonText', {
                fg = vim.api.nvim_get_hl_by_name('NonText', true).foreground,
                bg = vim.api.nvim_get_hl_by_name('StatusLine', true).background,
            })

            -- Hide the characters in CursorLineBg
            vim.api.nvim_set_hl(0, 'CursorLineBg', {
                fg = vim.api.nvim_get_hl_by_name('CursorLine', true).background,
                bg = vim.api.nvim_get_hl_by_name('CursorLine', true).background,
            })

            vim.api.nvim_set_hl(0, 'NvimTreeIndentMarker', { fg = '#2c3043' })
            vim.api.nvim_set_hl(0, 'IndentBlanklineChar', { fg = '#2c3043' })
        end,
    })

    use("tpope/vim-commentary") -- Commenting support
    use("tpope/vim-surround") -- Add, change, and delete surrounding text
    use("tpope/vim-eunuch") -- Useful commands like :Rename and :SudoWrite
    use("tpope/vim-unimpaired") -- Handy bracket mappings, like [b and ]b
    use("tpope/vim-repeat") -- Allow plugins to enable repeating of commands
    use("sheerun/vim-polyglot") -- Add more languages
    use("christoomey/vim-tmux-navigator") -- Seamless navigation between vim and tmux
    use("farmergreg/vim-lastplace") -- Jump to last location in a file when opened
    use("nelstrom/vim-visual-star-search") -- Enable * searching with visually selected text
    use("jessarcher/vim-heritage") -- Automatically create parent dirs when saving

    -- Text objects for HTML attributes
    use({
        "whatyouhide/vim-textobj-xmlattr",
        requires = "kana/vim-textobj-user"
    })

    -- Autopairs
    use({
        "windwp/nvim-autopairs",
        config = function()
            require("neovim.plugins.nvim-autopairs")
        end,
    })

    -- Split arrays and functions onto multiple lines
    use({
        "AndrewRadev/splitjoin.vim",
        config = function()
            require("neovim.plugins.splitjoin")
        end,
    })

    -- Automatically fix indentation when pasting code
    use({
        "sickill/vim-pasta",
        config = function()
            require("neovim.plugins.vim-pasta")
        end,
    })

    -- Fuzzy finder
    use({
        "nvim-telescope/telescope.nvim",
        after = "vim-nightfly-colors",
        requires = {
            "nvim-lua/plenary.nvim",
            "kyazdani42/nvim-web-devicons",
            "nvim-telescope/telescope-live-grep-args.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", run = "make" }
        },
        config = function()
            require("neovim.plugins.telescope")
        end,
    })

    -- File tree
    use({
        "kyazdani42/nvim-tree.lua",
        after = "vim-nightfly-colors",
        requires = "kyazdani42/nvim-web-devicons",
        config = function()
            require("neovim.plugins.nvim-tree")
        end,
    })

    -- Floating file tree
    use({
        "nvim-telescope/telescope-file-browser.nvim",
        after = {
            "vim-nightfly-colors",
            "telescope.nvim",
        },
        requires = "nvim-telescope/telescope.nvim",
        config = function()
            require("neovim.plugins.telescope-file-browser")
        end,
    })

    -- Status line
    use({
        "nvim-lualine/lualine.nvim",
        requires = "kyazdani42/nvim-web-devicons",
        config = function()
            require("neovim.plugins.lualine")
        end,
    })

    -- Indent blank lines
    use({
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            require("neovim.plugins.indent-blankline")
        end,
    })

    -- Gitsigns
    use({
        "lewis6991/gitsigns.nvim",
        requires = "nvim-lua/plenary.nvim",
        config = function()
            require("gitsigns").setup({
                sign_priority = 20,
                on_attach = function(bufnr)
                    vim.keymap.set('n', ']h', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<cr>'", { expr = true, buffer = bufnr })
                    vim.keymap.set('n', '[h', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<cr>'", { expr = true, buffer = bufnr })
                end,
            })
        end,
    })

    -- Floating terminal
    use({
        "voldikss/vim-floaterm",
        after = "vim-nightfly-colors",
        config = function()
            require("neovim.plugins.vim-floaterm")
        end,
    })

    -- Tree-sitter
    use({
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        requires = {
            "nvim-treesitter/playground",
            "nvim-treesitter/nvim-treesitter-textobjects",
            "JoosepAlviste/nvim-ts-context-commentstring",
        },
        config = function()
            require("neovim.plugins.nvim-treesitter")
        end,
    })

    -- LSP
    use({
        "neovim/nvim-lspconfig",
        requires = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("neovim.plugins.nvim-lspconfig")
        end,
    })

    -- Snippets
    use({
        "L3MON4D3/LuaSnip",
        config = function()
            require("neovim.plugins.luasnip")
        end,
    })

    -- Autocompletion
    use({
        "hrsh7th/nvim-cmp",
        requires = {
            "L3MON4D3/LuaSnip",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "onsails/lspkind-nvim",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            require("neovim.plugins.nvim-cmp")
        end,
    })

    -- Todo comments
    use({
        "folke/todo-comments.nvim",
        requires = "nvim-lua/plenary.nvim",
        config = function()
            require("todo-comments").setup({}) 
        end,
    })

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require("packer").sync()
    end
end)
