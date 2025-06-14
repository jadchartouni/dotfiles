require("nvim-treesitter.configs").setup({
	ensure_installed = "all",
	auto_install = true,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = true,
	},
	indent = {
		enable = false,
	},
	autotag = {
		enable = true,
	},
	textobjects = {
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				["if"] = "@function.inner",
				["af"] = "@function.outer",
				["ic"] = "@class.inner",
				["ac"] = "@class.outer",
				["ia"] = "@parameter.inner",
				["aa"] = "@parameter.outer",
			},
		},
	},
})

vim.g.skip_ts_context_commentstring_module = true
