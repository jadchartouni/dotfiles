return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- The legacy `master` branch is frozen and breaks on Neovim 0.11+/0.12: its
    -- custom query directives (query_predicates.lua) get a nil node under the
    -- new directive API, surfacing as "attempt to call method 'range'" whenever
    -- markdown code-block injections are parsed (e.g. by render-markdown).
    -- The `main` branch is the supported rewrite for modern Neovim.
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        -- Curated set for a file editor; not "all".
        "lua", "vim", "vimdoc", "bash",
        "markdown", "markdown_inline",
        "json", "yaml", "toml",
        "html", "css", "javascript", "typescript",
        "php", "gitcommit", "diff",
      })

      -- main branch doesn't auto-enable highlighting; start it per buffer for
      -- any filetype whose parser is installed.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
          if lang and vim.treesitter.language.add(lang) then
            vim.treesitter.start(ev.buf, lang)
          end
        end,
      })
    end,
  },
}
