return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        -- Curated set for a file editor (not "all" — that's slow IDE bloat).
        -- auto_install grabs anything else on demand.
        ensure_installed = {
          "lua", "vim", "vimdoc", "bash",
          "markdown", "markdown_inline",
          "json", "yaml", "toml",
          "html", "css", "javascript", "typescript",
          "php", "gitcommit", "diff",
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = false },
      })
    end,
  },
}
