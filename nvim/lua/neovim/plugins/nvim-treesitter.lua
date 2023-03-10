require("nvim-treesitter.configs").setup({
	ensure_installed = "all",
	auto_install = true,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = true,
	},
	indent = {
		enable = true,
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
	context_commentstring = {
		enable = true,
	},
})
