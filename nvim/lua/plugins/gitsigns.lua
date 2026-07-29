-- Git change markers in the signcolumn (added/changed/removed lines), plus
-- hunk-level actions: stage, reset, preview, and line blame.
--
-- Keys (leader = ","):
--   ]h / [h  next / previous hunk
--   ,hs  stage hunk        ,hr  reset hunk
--   ,hS  stage buffer      ,hR  reset buffer
--   ,hp  preview hunk      ,hb  blame current line
--   ,htb toggle inline blame for the whole buffer
--
-- TO REVERT: delete this file, then run `:Lazy clean` (or restart nvim).
return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end

        -- Navigation: fall back to plain ]c/[c motions in diff mode.
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next git hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Previous git hunk")

        -- Hunk actions
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage selected lines")
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset selected lines")
        map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, "Blame current line")
        map("n", "<leader>htb", gs.toggle_current_line_blame, "Toggle inline blame")
      end,
    },
  },
}
