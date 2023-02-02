-- Setup Mason to automatically install LSP servers
require("mason").setup()
require("mason-lspconfig").setup({
        automatic_installation = true,
    })

-- PHP
require("lspconfig").intelephense.setup({})

-- Vue, JavaScript, Typescript
require("lspconfig").volar.setup({
        -- Enable "Take Over Mode" where volar will provide all JS/TS LSP services
        -- This drastically improves the responsiveness of diagnostic updates on change
        filetypes = {
            "typescript",
            "javascript",
            "javascriptreact",
            "typescriptreact",
            "vue"
        },
    })

-- Tailwind CSS
require("lspconfig").tailwindcss.setup({})

-- Keymaps
vim.keymap.set("n", "<leader>d", "<cmd>lua vim.diagnostic.open_float()<cr>")
vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>")
vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>")
vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
vim.keymap.set("n", "gi", ":Telescope lsp_implementations<cr>")
vim.keymap.set("n", "gr", ":Telescope lsp_references<cr>")
vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>")
vim.keymap.set("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>")

-- Diagnostic information
vim.diagnostic.config({
                virtual_text = false,
                float = {
                        source = true,
                },
        })

vim.fn.sign_define('DiagnosticSignError', { text = '', texthl = 'DiagnosticSignError' })
vim.fn.sign_define('DiagnosticSignWarn', { text = '', texthl = 'DiagnosticSignWarn' })
vim.fn.sign_define('DiagnosticSignInfo', { text = '', texthl = 'DiagnosticSignInfo' })
vim.fn.sign_define('DiagnosticSignHint', { text = '', texthl = 'DiagnosticSignHint' })

