local formatting = require("null-ls").builtins.formatting
local diagnostics = require("null-ls").builtins.diagnostics

-- To setup format on save
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

require("null-ls").setup({
	sources = {
		formatting.prettier,
		formatting.stylua,
	},
	-- Configure format on save
	on_attach = function(current_client, bufnr)
		if current_client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({
						filter = function(client)
							--  Only use null-ls for formatting instead of lsp server
							return client.name == "null-ls"
						end,
						bufnr = bufnr,
					})
				end,
			})
		end
	end,
})

require("mason-null-ls").setup({
	ensure_installed = {
		"prettier",
		"stylua",
	},
})

-- Keymaps
vim.api.nvim_create_user_command("Format", vim.lsp.buf.formatting, {})
