return {
  {
    -- Seamless <C-h/j/k/l> navigation between nvim splits and tmux panes.
    -- Requires matching bindings in tmux.conf (handled with the tmux dotfile).
    "christoomey/vim-tmux-navigator",
    event = "VeryLazy",
    config = function()
      -- Some terminals (e.g. qterminal) send the same byte for Ctrl-h and
      -- Backspace, so Ctrl-h reaches nvim as <BS>; map it to "navigate left"
      -- too. Normal-mode only — insert-mode Backspace is unaffected.
      vim.keymap.set("n", "<BS>", "<cmd>TmuxNavigateLeft<cr>", { silent = true })
    end,
  },
}
