return {
  {
    "tpope/vim-obsession",
    -- Load eagerly (not lazily): when tmux-resurrect restarts nvim with
    -- `nvim -S Session.vim`, the session file calls back into obsession to
    -- resume tracking, so the plugin must already be available at startup.
    lazy = false,
  },
}
