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
    opts = {
      heading = {
        -- No background bars: headings render as bold coloured text only.
        -- (render-markdown's default backgrounds link to Diff/Visual groups,
        -- which produced random-looking bars.) Foreground colours come from
        -- RenderMarkdownH1..H6 in the sentrycore theme.
        backgrounds = {},
      },
      bullet = {
        -- Smaller bullets than the default large filled circle (●), graded
        -- by nesting level.
        icons = { "•", "◦", "▪", "▫" },
      },
    },
  },
}
