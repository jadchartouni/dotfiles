-- Fuzzy finder: files, project-wide content grep, buffers, recent, help.
-- Uses telescope-fzf-native (compiled C sorter) for fzf-level matching speed,
-- and inherits the SentryCore Telescope* highlight groups for theming.
--
-- Requires `ripgrep` (rg) for live_grep — added to brew/Brewfile.
--
-- Keys (leader = ","):
--   ,ff  find files by name        ,fb  open buffers
--   ,fg  live grep (file contents) ,fr  recent files
--   ,fh  help tags
-- (Siblings of the existing ,ft / ,fe nvim-tree maps.)
--
-- TO REVERT: delete this file, then run `:Lazy clean` (or restart nvim).
return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live grep (contents)" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Find buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",   desc = "Recent files" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",  desc = "Help tags" },
    },
    opts = {
      defaults = {
        prompt_prefix = "   ",
        selection_caret = "  ",
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = { prompt_position = "top", preview_width = 0.55 },
        },
        -- The file-preview treesitter path in telescope 0.1.x depends on a
        -- whole chain of legacy nvim-treesitter APIs (get_module/get_parser/…)
        -- that the *main* branch removed. Use Vim's regex syntax for previews
        -- instead — still colored, and avoids that fragile chain entirely.
        -- (Grep result highlighting still uses treesitter via the shims below.)
        preview = { treesitter = false },
        -- mappings are added in config() below (they need telescope.actions,
        -- which isn't on the runtimepath yet while this opts table is built).
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    },
    config = function(_, opts)
      -- Compat shims for nvim-treesitter's *main* branch, which removed the
      -- legacy APIs telescope 0.1.x still calls in its grep-results highlighter
      -- (__files.lua). Both delegate to core/equivalent behavior:
      --   ft_to_lang  -> core vim.treesitter.language.get_lang
      --   is_enabled  -> true (callers already verified a parser + query exist)
      local pok, ts_parsers = pcall(require, "nvim-treesitter.parsers")
      if pok and ts_parsers.ft_to_lang == nil then
        ts_parsers.ft_to_lang = function(ft)
          return vim.treesitter.language.get_lang(ft) or ft
        end
      end
      local cok, ts_configs = pcall(require, "nvim-treesitter.configs")
      if cok and ts_configs.is_enabled == nil then
        ts_configs.is_enabled = function()
          return true
        end
      end

      -- Move through results with Ctrl-j / Ctrl-k without leaving insert mode
      -- (plain j/k still work after pressing <Esc> for normal mode).
      local actions = require("telescope.actions")
      opts.defaults.mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
        },
      }

      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("fzf") -- activate the compiled sorter
    end,
  },
}
