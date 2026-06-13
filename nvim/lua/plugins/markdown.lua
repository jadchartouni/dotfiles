return {
  {
    -- In-editor markdown rendering: pretty in normal mode, raw while editing.
    -- Toggle manually with <leader>mr (:RenderMarkdown toggle).
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    opts = {},
  },
}
