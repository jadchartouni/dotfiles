-- Outline the *active* split's separators in a bright accent (tmux-style), so
-- the live window is framed instead of only inferred from vimade's dimming.
--
-- TO REVERT: delete this file, then run `:Lazy clean` in nvim (or restart nvim
-- and lazy will prune it). Nothing else references it — removal is total.
return {
  {
    "nvim-zh/colorful-winsep.nvim",
    event = "VeryLazy",
    opts = {
      -- Heavy lines, matching the base fillchars set in core/options.lua.
      border = "bold",
      -- SentryCore purple_br — bright enough to pop against the #3D2570
      -- border color the inactive separators keep.
      highlight = "#A855E0",
    },
  },
}
