local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require("lspkind")

local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

-- Load friendly snippets
require("luasnip/loaders/from_vscode").lazy_load()
require("luasnip/loaders/from_snipmate").lazy_load({ "./snippets" })

cmp.setup({
	formatting = {
		format = lspkind.cmp_format({
			max_width = 50,
			ellipsis_char = "...",
			mode = "symbol_text",
			with_text = true,
			menu = {
				copilot = "[Copilot]",
				nvim_lsp = "[LSP]",
				luasnip = "[Lua]",
				buffer = "[Buffer]",
				path = "[Path]",
			},
		}),
	},
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = {
		["<C-j>"] = cmp.mapping.select_next_item(), -- Next suggestion
		["<C-k>"] = cmp.mapping.select_prev_item(), -- Previous suggestion
		["<C-Space>"] = cmp.mapping.complete(), -- Show completion suggestions
		["<C-e>"] = cmp.mapping.abort(), -- Close completion window
		["<CR>"] = cmp.mapping.confirm({ select = false }),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	},
	sources = {
		{ name = "copilot" },
		{ name = "nvim_lsp" },
		{ name = "nvim_lsp_signature_help" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "path" },
	},
	experimental = {
		ghost_text = true,
	},
})
