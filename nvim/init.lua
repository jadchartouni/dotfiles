require("core.options")
require("core.keymaps")
require("core.autocmds")

-- Inside Cursor/VS Code the UI is owned by the editor (vscode-neovim sets
-- vim.g.vscode). Skip the plugin manager and all UI plugins there; only the
-- core Vim behaviour above is reused. Standalone nvim loads everything.
if not vim.g.vscode then
  require("core.lazy")
end
