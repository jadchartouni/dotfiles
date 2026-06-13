return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- The legacy `master` branch is frozen and breaks on Neovim 0.11+/0.12: its
    -- custom query directives get a nil node under the new directive API,
    -- surfacing as "attempt to call method 'range'" when markdown code-block
    -- injections are parsed. The `main` branch is the supported rewrite.
    -- It compiles parsers with the `tree-sitter` CLI (see Brewfile).
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")

      -- Precompile a broad base set so common filetypes highlight instantly.
      ts.install({
        "bash", "css", "diff", "dockerfile", "git_rebase", "gitcommit",
        "gitignore", "go", "html", "javascript", "json", "lua",
        "luadoc", "make", "markdown", "markdown_inline", "php", "python",
        "query", "regex", "ruby", "rust", "scss", "sql", "toml", "tsx",
        "typescript", "vim", "vimdoc", "xml", "yaml",
      })

      -- Languages that have a parser available to install.
      local available = {}
      for _, lang in ipairs(ts.get_available()) do
        available[lang] = true
      end

      -- Start highlighting for every buffer; if the parser isn't installed yet,
      -- fetch + compile it asynchronously on first use, then start (mirrors the
      -- old master-branch `auto_install`).
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          local buf = ev.buf
          local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
          if not lang or not available[lang] then
            return
          end
          if vim.treesitter.language.add(lang) then
            vim.treesitter.start(buf, lang)
          else
            ts.install(lang):await(function()
              vim.schedule(function()
                if vim.api.nvim_buf_is_valid(buf) then
                  pcall(vim.treesitter.start, buf, lang)
                end
              end)
            end)
          end
        end,
      })
    end,
  },
}
