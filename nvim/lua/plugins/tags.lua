-- Jump-to-definition without LSP: gutentags keeps a ctags index fresh in the
-- background (regenerates on save), and nvim's built-in tag keys just work:
--   Ctrl-]  jump to the definition under the cursor (cross-file)
--   Ctrl-t  jump back
--   g]      list all matches when a name is defined more than once
-- Requires universal-ctags (in brew/Brewfile); inert when ctags is absent.
--
-- TO REVERT: delete this file, then run `:Lazy clean` (or restart nvim).
return {
  {
    "ludovicchabant/vim-gutentags",
    cond = vim.fn.executable("ctags") == 1,
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      -- Keep tags files out of project trees (no .gitignore churn); gutentags
      -- maps each project root to its own file under the nvim cache dir.
      vim.g.gutentags_cache_dir = vim.fn.stdpath("cache") .. "/ctags"
      -- Don't auto-index dependencies: their same-named symbols otherwise
      -- compete with project code and Ctrl-] lands in vendored files. Run
      -- :TagsDeps (below) to index them on demand as lower-priority matches.
      vim.g.gutentags_ctags_exclude = {
        "vendor", "node_modules", ".venv", "venv",
        "dist", "build", "*.min.js",
      }

      -- :TagsDeps — index dependency dirs into <project>/tags. 'tags' already
      -- searches "./tags" AFTER the gutentags cache file, so project
      -- definitions always rank first and vendor matches appear lower in the
      -- Ctrl-] pick-list. Re-run after composer/npm/pip installs.
      vim.api.nvim_create_user_command("TagsDeps", function()
        local root = vim.fs.root(0, ".git")
        if not root then
          return vim.notify("TagsDeps: no project root (.git) found", vim.log.levels.WARN)
        end
        local deps = {}
        for _, d in ipairs({ "vendor", "node_modules", ".venv", "venv" }) do
          if vim.uv.fs_stat(root .. "/" .. d) then
            table.insert(deps, d)
          end
        end
        if #deps == 0 then
          return vim.notify("TagsDeps: no dependency dirs in " .. root, vim.log.levels.WARN)
        end
        vim.system(
          { "ctags", "-R", "-f", "tags", unpack(deps) },
          { cwd = root },
          vim.schedule_wrap(function(res)
            if res.code == 0 then
              vim.notify("TagsDeps: indexed " .. table.concat(deps, ", "))
            else
              vim.notify("TagsDeps: ctags failed: " .. (res.stderr or ""), vim.log.levels.ERROR)
            end
          end)
        )
      end, { desc = "Index vendor/node_modules/venv as lower-priority tags" })
    end,
  },
}
