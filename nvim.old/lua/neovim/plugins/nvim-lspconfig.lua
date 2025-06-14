-- Setup Mason to automatically install LSP servers
require("mason").setup()

require("mason-lspconfig").setup({
	automatic_installation = true,
	ensure_installed = {
		"html",
		"cssls",
		"tailwindcss",
		"emmet_ls",
		"intelephense",
	},
})

-- Enable keybinds for available lsp servers
local on_attach = function(client, bufnr)
	-- Keybind options
	local opts = { noremap = true, silent = true, buffer = bufnr }
end

-- Used to enable autocompletion (assign to every lsp server config)
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Diagnostic information
vim.diagnostic.config({
	virtual_text = false,
	float = {
		source = true,
	},
})

-- Change the Diagnostic symbols in the sign column (gutter)
local signs = { Error = " ", Warn = " ", Hint = "ﴞ ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- PHP
require("lspconfig").intelephense.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- Vue, JavaScript, Typescript
require("lspconfig").volar.setup({
	-- Enable "Take Over Mode" where volar will provide all JS/TS LSP services
	-- This drastically improves the responsiveness of diagnostic updates on change
	filetypes = {
		"typescript",
		"javascript",
		"javascriptreact",
		"typescriptreact",
		"vue",
		"json",
	},
	capabilities = capabilities,
	on_attach = on_attach,
})

-- Tailwind CSS
require("lspconfig").tailwindcss.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- HTML
require("lspconfig").html.setup({
	filetypes = {
		"html",
		"blade",
		"php",
	},
	capabilities = capabilities,
	on_attach = on_attach,
})

-- JSON
require("lspconfig").jsonls.setup({
	capabilities = capabilities,
	settings = {
		json = {
			schemas = require("schemastore").json.schemas(),
		},
	},
})

-- Keymaps
vim.keymap.set("n", "<leader>d", "<cmd>lua vim.diagnostic.open_float()<cr>")
vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>")
vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>")
vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
vim.keymap.set("n", "gi", ":Telescope lsp_implementations<cr>")
vim.keymap.set("n", "gr", ":Telescope lsp_references<cr>")
vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>")
vim.keymap.set("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>")
