-- SentryCore palette
-- Derived from the SentryCore brand identity guidelines.

local M = {}

M.colors = {
  -- Base surfaces
  bg          = "#0F0A1F", -- deepened indigo (background)
  bg_dark     = "#0A0618", -- sidebar / float backdrop
  bg_alt      = "#1A1230", -- statusline, ANSI black
  bg_highlight = "#2A1F4A", -- selection, cursorline
  bg_visual   = "#3D2570", -- visual selection
  bg_float    = "#15102A",

  fg          = "#E6E4F0", -- primary text
  fg_dim      = "#C9C5DB", -- secondary text
  fg_dark     = "#9890B8", -- comments, line numbers
  fg_gutter   = "#3D3560",
  fg_faint    = "#756B96", -- ANSI bright black: dim CLI text (autosuggestions
                           -- etc.) — must stay readable against bg
  white       = "#FFFFFF", -- ANSI bright white

  -- Brand primaries
  purple      = "#6A39A9", -- Core Amethyst
  purple_br   = "#A855E0", -- bright magenta-purple
  magenta     = "#8324BF", -- Secure Magenta
  blue        = "#3D55B6", -- Quantum Blue
  blue_br     = "#5A78D9",
  cyan        = "#4A8FE7",
  cyan_br     = "#6BA8FF",

  -- Functional accents
  teal        = "#00BFA5", -- Alert Teal -> success
  teal_br     = "#3DD5B6",
  red         = "#E74C3C", -- Alert Red -> errors
  red_br      = "#FF6B5B",
  yellow      = "#C29BFF", -- on-brand "yellow" (lavender)
  yellow_br   = "#D9B8FF",
  orange      = "#E89A4A", -- warnings (derived)

  -- Diff
  diff_add    = "#1E3A2E",
  diff_change = "#1E2A4A",
  diff_delete = "#3A1E22",
  diff_text   = "#3D55B6",

  -- Git
  git_add     = "#00BFA5",
  git_change  = "#3D55B6",
  git_delete  = "#E74C3C",

  -- Borders
  border      = "#3D2570",
  border_hl   = "#6A39A9",
  border_dim  = "#2A2045", -- subtle UI borders / guides (Cursor, Obsidian)

  none        = "NONE",
}

return M
