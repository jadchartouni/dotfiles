-- Dim inactive nvim windows (splits) so it's always obvious which one is live —
-- e.g. nvim-tree recedes when you're in the editor, and vice-versa. It also
-- fades the whole nvim instance when tmux focus leaves the pane, via tmux's
-- `focus-events on` (already set in tmux.conf).
--
-- TO REVERT: delete this file, then run `:Lazy clean` in nvim (or restart nvim
-- and lazy will prune it). Nothing else references it — removal is total.
return {
  {
    "TaDaa/vimade",
    event = "VeryLazy",
    opts = {
      -- Fade by *window* so every inactive split dims, regardless of which
      -- buffer it shows. ("buffers" would only fade non-current buffers.)
      ncmode = "windows",
      -- Fade the WHOLE nvim pane when terminal focus leaves it (e.g. you jump
      -- to another tmux pane). Relies on tmux's `focus-events on`, already set.
      enablefocusfading = true,
      -- 0 = fully dark, 1 = no fade. 0.7 is a gentle dim — inactive windows
      -- recede slightly but stay clearly readable. (Lower = stronger fade.)
      fadelevel = 0.7,
      -- Pull faded windows gently toward SentryCore bg_alt (#1A1230).
      tint = {
        bg = { rgb = { 26, 18, 48 }, intensity = 0.25 },
      },
      -- Never fade :terminal buffers — they repaint constantly and vimade
      -- re-tinting each redraw causes flicker and lag.
      blocklist = {
        terminal = { buf_opts = { bt = "terminal" } },
      },
    },
    config = function(_, opts)
      require("vimade").setup(opts)
    end,
  },
}
