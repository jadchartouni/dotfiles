local bufferline = require("bufferline")

bufferline.setup({
	options = {
		offsets = {
			{
				filetype = "NvimTree",
				text = "File Explorer",
				text_align = "left",
				highlight = "Directory",
				separator = true,
			},
		},
		diagnostics = "nvim_lsp",
		separator_style = { "", "" },
		modified_icon = "●",
		show_close_icon = false,
		show_buffer_close_icons = false,
		show_buffer_icons = false,
		style_preset = {
			bufferline.style_preset.no_italic,
			bufferline.style_preset.no_bold,
		},
	},
})
