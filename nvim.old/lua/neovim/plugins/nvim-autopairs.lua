require("nvim-autopairs").setup({
	check_ts = true, -- Enable treesitter
	ts_config = {
		lua = { "string" }, -- Don't add pairs in lue treesitter nodes
	},
})

local cmp = require("cmp")
local autopairs = require("nvim-autopairs.completion.cmp")

-- Make autopairs and completion work together
cmp.event:on("confirm_done", autopairs.on_confirm_done())
