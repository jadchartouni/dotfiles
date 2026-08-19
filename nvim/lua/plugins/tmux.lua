return {
  {
    -- Seamless <C-h/j/k/l> navigation between nvim splits and tmux panes.
    -- Requires matching bindings in tmux.conf (handled with the tmux dotfile).
    "christoomey/vim-tmux-navigator",
    event = "VeryLazy",
    config = function()
      -- Linux terminfo often declares kbs=^H, so Ctrl-h reaches nvim as <BS>;
      -- map it to "navigate left" too. Harmless on macOS (kbs=^?).
      vim.keymap.set("n", "<BS>", "<cmd>TmuxNavigateLeft<cr>", { silent = true })
    end,
  },
}
