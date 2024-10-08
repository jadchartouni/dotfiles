require("nvim-tree").setup({
	update_focused_file = {
		enable = true,
	},
	view = {
		width = 35,
		adaptive_size = true,
	},
	git = {
		ignore = false,
	},
	renderer = {
		group_empty = true,
		icons = {
			show = {
				folder_arrow = false,
			},
		},
		indent_markers = {
			enable = true,
		},
	},
})

vim.cmd([[
    highlight NvimTreeIndentMarker guifg=#30323E
    augroup NvimTreeHighlights
    autocmd ColorScheme * highlight NvimTreeIndentMarker guifg=#30323E
    augroup end
]])
