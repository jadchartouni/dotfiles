-- SentryCore Neovim colorscheme
local M = {}

function M.setup(opts)
  opts = opts or {}

  if vim.g.colors_name then
    vim.cmd("hi clear")
  end
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end

  vim.o.background = "dark"
  vim.o.termguicolors = true
  vim.g.colors_name = "sentrycore"

  local c = require("sentrycore.palette").colors

  local hl = function(group, spec)
    vim.api.nvim_set_hl(0, group, spec)
  end

  -- Editor UI
  hl("Normal",        { fg = c.fg, bg = c.bg })
  hl("NormalFloat",   { fg = c.fg, bg = c.bg_float })
  hl("NormalNC",      { fg = c.fg_dim, bg = c.bg })
  hl("FloatBorder",   { fg = c.border_hl, bg = c.bg_float })
  hl("FloatTitle",    { fg = c.purple_br, bg = c.bg_float, bold = true })

  hl("Cursor",        { fg = c.bg, bg = c.purple })
  hl("CursorLine",    { bg = c.bg_highlight })
  hl("CursorColumn",  { bg = c.bg_highlight })
  hl("CursorLineNr",  { fg = c.purple_br, bold = true })
  hl("LineNr",        { fg = c.fg_gutter })
  hl("SignColumn",    { fg = c.fg_dark, bg = c.bg })
  hl("ColorColumn",   { bg = c.bg_alt })

  hl("Visual",        { bg = c.bg_visual })
  hl("VisualNOS",     { bg = c.bg_visual })
  hl("Search",        { fg = c.bg, bg = c.purple_br })
  hl("IncSearch",     { fg = c.bg, bg = c.teal_br, bold = true })
  hl("CurSearch",     { fg = c.bg, bg = c.teal_br, bold = true })
  hl("MatchParen",    { fg = c.teal_br, bold = true, underline = true })

  hl("StatusLine",    { fg = c.fg, bg = c.bg_alt })
  hl("StatusLineNC",  { fg = c.fg_dark, bg = c.bg_dark })
  hl("WinSeparator",  { fg = c.border, bg = c.none })
  hl("VertSplit",     { fg = c.border, bg = c.none })

  hl("TabLine",       { fg = c.fg_dark, bg = c.bg_alt })
  hl("TabLineFill",   { bg = c.bg_dark })
  hl("TabLineSel",    { fg = c.fg, bg = c.purple, bold = true })

  hl("Pmenu",         { fg = c.fg, bg = c.bg_float })
  hl("PmenuSel",      { fg = c.fg, bg = c.bg_visual, bold = true })
  hl("PmenuSbar",     { bg = c.bg_alt })
  hl("PmenuThumb",    { bg = c.purple })
  hl("PmenuKind",     { fg = c.cyan, bg = c.bg_float })
  hl("PmenuExtra",    { fg = c.fg_dark, bg = c.bg_float })

  hl("Folded",        { fg = c.fg_dim, bg = c.bg_alt, italic = true })
  hl("FoldColumn",    { fg = c.fg_gutter, bg = c.bg })

  hl("NonText",       { fg = c.fg_gutter })
  hl("Whitespace",    { fg = c.fg_gutter })
  hl("EndOfBuffer",   { fg = c.bg })
  hl("Conceal",       { fg = c.fg_dark })
  hl("SpecialKey",    { fg = c.fg_gutter })

  hl("Directory",     { fg = c.blue_br })
  hl("Title",         { fg = c.purple_br, bold = true })
  hl("ModeMsg",       { fg = c.fg_dim, bold = true })
  hl("MoreMsg",       { fg = c.teal })
  hl("Question",      { fg = c.teal })
  hl("WarningMsg",    { fg = c.orange })
  hl("ErrorMsg",      { fg = c.red, bold = true })
  hl("MsgArea",       { fg = c.fg })
  hl("MsgSeparator",  { fg = c.border, bg = c.bg_alt })

  hl("WildMenu",      { fg = c.bg, bg = c.purple_br })
  hl("QuickFixLine",  { bg = c.bg_highlight, bold = true })

  hl("SpellBad",      { sp = c.red, undercurl = true })
  hl("SpellCap",      { sp = c.blue_br, undercurl = true })
  hl("SpellRare",     { sp = c.cyan, undercurl = true })
  hl("SpellLocal",    { sp = c.teal, undercurl = true })

  -- ══════════════════════════════════════════════════════════════════════
  -- Syntax — role-based palette
  --   keywords  → bright purple     functions  → sky blue
  --   types     → blue              strings    → mint
  --   values    → warm orange (numbers · booleans · constants)
  --   variables → foreground        properties → cyan   parameters → lavender
  --   operators & punctuation stay quiet so the accents read clearly
  -- ══════════════════════════════════════════════════════════════════════

  -- Legacy groups (fallbacks for non-treesitter buffers; mirror the TS map)
  hl("Comment",        { fg = c.fg_dark, italic = true })

  hl("Constant",       { fg = c.orange })
  hl("String",         { fg = c.teal_br })
  hl("Character",      { fg = c.teal_br })
  hl("Number",         { fg = c.orange })
  hl("Boolean",        { fg = c.orange, bold = true })
  hl("Float",          { fg = c.orange })

  hl("Identifier",     { fg = c.fg })
  hl("Function",       { fg = c.cyan_br })

  hl("Statement",      { fg = c.purple_br, italic = true })
  hl("Conditional",    { fg = c.purple_br, italic = true })
  hl("Repeat",         { fg = c.purple_br, italic = true })
  hl("Label",          { fg = c.purple_br })
  hl("Operator",       { fg = c.fg_dim })
  hl("Keyword",        { fg = c.purple_br, italic = true })
  hl("Exception",      { fg = c.purple_br, italic = true })

  hl("PreProc",        { fg = c.purple_br })
  hl("Include",        { fg = c.purple_br, italic = true })
  hl("Define",         { fg = c.purple_br })
  hl("Macro",          { fg = c.cyan_br })
  hl("PreCondit",      { fg = c.purple_br })

  hl("Type",           { fg = c.blue_br })
  hl("StorageClass",   { fg = c.purple_br, italic = true })
  hl("Structure",      { fg = c.blue_br })
  hl("Typedef",        { fg = c.blue_br })

  hl("Special",        { fg = c.teal })
  hl("SpecialChar",    { fg = c.teal })
  hl("Tag",            { fg = c.purple_br })
  hl("Delimiter",      { fg = c.fg_dim })
  hl("SpecialComment", { fg = c.fg_dark, italic = true })
  hl("Debug",          { fg = c.orange })

  hl("Underlined",     { underline = true })
  hl("Bold",           { bold = true })
  hl("Italic",         { italic = true })

  hl("Error",          { fg = c.red, bold = true })
  hl("Todo",           { fg = c.bg, bg = c.yellow, bold = true })

  -- Treesitter — comments
  hl("@comment",               { fg = c.fg_dark, italic = true })
  hl("@comment.documentation", { fg = c.fg_dark, italic = true })
  hl("@comment.todo",          { fg = c.bg, bg = c.yellow,  bold = true })
  hl("@comment.note",          { fg = c.bg, bg = c.teal_br, bold = true })
  hl("@comment.warning",       { fg = c.bg, bg = c.orange,  bold = true })
  hl("@comment.error",         { fg = c.bg, bg = c.red_br,  bold = true })

  -- Variables, parameters, members
  hl("@variable",                   { fg = c.fg })
  hl("@variable.builtin",           { fg = c.red_br, italic = true })
  hl("@variable.parameter",         { fg = c.yellow, italic = true })
  hl("@variable.parameter.builtin", { fg = c.yellow, italic = true })
  hl("@variable.member",            { fg = c.cyan })
  hl("@property",                   { fg = c.cyan })
  hl("@field",                      { fg = c.cyan })

  -- Constants & literals (warm = values)
  hl("@constant",          { fg = c.orange })
  hl("@constant.builtin",  { fg = c.orange, bold = true })
  hl("@constant.macro",    { fg = c.purple_br })
  hl("@number",            { fg = c.orange })
  hl("@number.float",      { fg = c.orange })
  hl("@float",             { fg = c.orange })
  hl("@boolean",           { fg = c.orange, bold = true })
  hl("@character",         { fg = c.teal_br })
  hl("@character.special", { fg = c.teal })

  -- Strings
  hl("@string",               { fg = c.teal_br })
  hl("@string.documentation", { fg = c.teal, italic = true })
  hl("@string.escape",        { fg = c.teal })
  hl("@string.special",       { fg = c.teal })
  hl("@string.special.url",   { fg = c.cyan, underline = true })
  hl("@string.special.path",  { fg = c.teal })
  hl("@string.regexp",        { fg = c.cyan })

  -- Functions & methods (sky blue)
  hl("@function",             { fg = c.cyan_br })
  hl("@function.builtin",     { fg = c.cyan_br, italic = true })
  hl("@function.call",        { fg = c.cyan_br })
  hl("@function.macro",       { fg = c.cyan_br })
  hl("@function.method",      { fg = c.cyan_br })
  hl("@function.method.call", { fg = c.cyan_br })
  hl("@constructor",          { fg = c.blue_br })

  -- Keywords (bright purple)
  hl("@keyword",                     { fg = c.purple_br, italic = true })
  hl("@keyword.function",            { fg = c.purple_br, italic = true })
  hl("@keyword.operator",            { fg = c.purple_br, italic = true })
  hl("@keyword.import",              { fg = c.purple_br, italic = true })
  hl("@keyword.type",                { fg = c.purple_br, italic = true })
  hl("@keyword.modifier",            { fg = c.purple_br, italic = true })
  hl("@keyword.repeat",              { fg = c.purple_br, italic = true })
  hl("@keyword.return",              { fg = c.purple_br, italic = true })
  hl("@keyword.debug",               { fg = c.purple_br, italic = true })
  hl("@keyword.exception",           { fg = c.purple_br, italic = true })
  hl("@keyword.conditional",         { fg = c.purple_br, italic = true })
  hl("@keyword.conditional.ternary", { fg = c.fg_dim })
  hl("@keyword.coroutine",           { fg = c.purple_br, italic = true })
  hl("@keyword.directive",           { fg = c.purple_br })
  hl("@keyword.directive.define",    { fg = c.purple_br })

  -- Operators & punctuation (quiet)
  hl("@operator",              { fg = c.fg_dim })
  hl("@punctuation.delimiter", { fg = c.fg_dim })
  hl("@punctuation.bracket",   { fg = c.fg_dim })
  hl("@punctuation.special",   { fg = c.orange })

  -- Types, modules, attributes
  hl("@type",              { fg = c.blue_br })
  hl("@type.builtin",      { fg = c.blue_br, italic = true })
  hl("@type.definition",   { fg = c.blue_br })
  hl("@type.qualifier",    { fg = c.purple_br, italic = true })
  hl("@module",            { fg = c.yellow_br })
  hl("@module.builtin",    { fg = c.yellow_br, italic = true })
  hl("@namespace",         { fg = c.yellow_br })
  hl("@label",             { fg = c.purple_br })
  hl("@attribute",         { fg = c.yellow_br })
  hl("@attribute.builtin", { fg = c.yellow_br })

  -- Tags (HTML / JSX / XML)
  hl("@tag",           { fg = c.purple_br })
  hl("@tag.builtin",   { fg = c.purple_br })
  hl("@tag.attribute", { fg = c.cyan })
  hl("@tag.delimiter", { fg = c.fg_dim })

  -- Misc
  hl("@none",    {})
  hl("@conceal", { fg = c.fg_dark })

  -- Markup (markdown & friends)
  hl("@markup.heading",        { fg = c.purple_br, bold = true })
  hl("@markup.heading.1",      { fg = c.purple_br, bold = true })
  hl("@markup.heading.2",      { fg = c.blue_br, bold = true })
  hl("@markup.heading.3",      { fg = c.cyan_br, bold = true })
  hl("@markup.heading.4",      { fg = c.teal_br, bold = true })
  hl("@markup.heading.5",      { fg = c.yellow_br, bold = true })
  hl("@markup.heading.6",      { fg = c.orange, bold = true })
  hl("@markup.strong",         { bold = true })
  hl("@markup.italic",         { italic = true })
  hl("@markup.strikethrough",  { strikethrough = true })
  hl("@markup.underline",      { underline = true })
  hl("@markup.quote",          { fg = c.fg_dim, italic = true })
  hl("@markup.math",           { fg = c.cyan_br })
  hl("@markup.link",           { fg = c.cyan_br })
  hl("@markup.link.label",     { fg = c.purple_br })
  hl("@markup.link.url",       { fg = c.cyan, underline = true })
  hl("@markup.raw",            { fg = c.teal_br, bg = c.bg_alt })
  hl("@markup.raw.block",      { fg = c.fg, bg = c.bg_dark })
  hl("@markup.list",           { fg = c.purple_br })
  hl("@markup.list.checked",   { fg = c.teal })
  hl("@markup.list.unchecked", { fg = c.fg_dark })

  -- Diff
  hl("@diff.plus",  { fg = c.git_add })
  hl("@diff.minus", { fg = c.git_delete })
  hl("@diff.delta", { fg = c.git_change })

  -- LSP semantic tokens → reuse the treesitter look
  hl("@lsp.type.class",         { link = "@type" })
  hl("@lsp.type.decorator",     { link = "@attribute" })
  hl("@lsp.type.enum",          { link = "@type" })
  hl("@lsp.type.enumMember",    { link = "@constant" })
  hl("@lsp.type.function",      { link = "@function" })
  hl("@lsp.type.interface",     { link = "@type" })
  hl("@lsp.type.macro",         { link = "@constant.macro" })
  hl("@lsp.type.method",        { link = "@function.method" })
  hl("@lsp.type.namespace",     { link = "@module" })
  hl("@lsp.type.parameter",     { link = "@variable.parameter" })
  hl("@lsp.type.property",      { link = "@property" })
  hl("@lsp.type.struct",        { link = "@type" })
  hl("@lsp.type.type",          { link = "@type" })
  hl("@lsp.type.typeParameter", { link = "@type.definition" })
  hl("@lsp.type.variable",      { link = "@variable" })

  -- render-markdown.nvim
  -- Headings: bold coloured text only (background bars are disabled via the
  -- plugin's `heading.backgrounds = {}` opt; setting *Bg to NONE here does not
  -- stick because render-markdown then treats it as unset and re-links it).
  hl("RenderMarkdownH1", { fg = c.purple_br, bold = true })
  hl("RenderMarkdownH2", { fg = c.blue_br, bold = true })
  hl("RenderMarkdownH3", { fg = c.cyan_br, bold = true })
  hl("RenderMarkdownH4", { fg = c.teal_br, bold = true })
  hl("RenderMarkdownH5", { fg = c.yellow_br, bold = true })
  hl("RenderMarkdownH6", { fg = c.orange, bold = true })
  -- Tables: keep every border/cell white (the default head links to a coloured
  -- heading group, which made the header border pink).
  hl("RenderMarkdownTableHead", { fg = c.fg })
  hl("RenderMarkdownTableRow",  { fg = c.fg })

  -- LSP
  hl("DiagnosticError",           { fg = c.red })
  hl("DiagnosticWarn",            { fg = c.orange })
  hl("DiagnosticInfo",            { fg = c.cyan_br })
  hl("DiagnosticHint",            { fg = c.teal })
  hl("DiagnosticOk",              { fg = c.teal })

  hl("DiagnosticVirtualTextError", { fg = c.red, bg = c.bg })
  hl("DiagnosticVirtualTextWarn",  { fg = c.orange, bg = c.bg })
  hl("DiagnosticVirtualTextInfo",  { fg = c.cyan_br, bg = c.bg })
  hl("DiagnosticVirtualTextHint",  { fg = c.teal, bg = c.bg })

  hl("DiagnosticUnderlineError",  { sp = c.red, undercurl = true })
  hl("DiagnosticUnderlineWarn",   { sp = c.orange, undercurl = true })
  hl("DiagnosticUnderlineInfo",   { sp = c.cyan_br, undercurl = true })
  hl("DiagnosticUnderlineHint",   { sp = c.teal, undercurl = true })

  hl("LspReferenceText",          { bg = c.bg_highlight })
  hl("LspReferenceRead",          { bg = c.bg_highlight })
  hl("LspReferenceWrite",         { bg = c.bg_visual })
  hl("LspSignatureActiveParameter", { fg = c.purple_br, bold = true })
  hl("LspInlayHint",              { fg = c.fg_gutter, bg = c.bg_alt, italic = true })

  -- Diff / git
  hl("DiffAdd",       { bg = c.diff_add })
  hl("DiffChange",    { bg = c.diff_change })
  hl("DiffDelete",    { bg = c.diff_delete })
  hl("DiffText",      { bg = c.diff_text, bold = true })

  hl("GitSignsAdd",          { fg = c.git_add })
  hl("GitSignsChange",       { fg = c.git_change })
  hl("GitSignsDelete",       { fg = c.git_delete })
  hl("GitSignsAddInline",    { bg = c.diff_add })
  hl("GitSignsChangeInline", { bg = c.diff_change })
  hl("GitSignsDeleteInline", { bg = c.diff_delete })

  hl("Added",         { fg = c.git_add })
  hl("Changed",       { fg = c.git_change })
  hl("Removed",       { fg = c.git_delete })

  -- Telescope
  hl("TelescopeNormal",         { fg = c.fg, bg = c.bg_float })
  hl("TelescopeBorder",         { fg = c.border_hl, bg = c.bg_float })
  hl("TelescopePromptNormal",   { fg = c.fg, bg = c.bg_alt })
  hl("TelescopePromptBorder",   { fg = c.purple, bg = c.bg_alt })
  hl("TelescopePromptTitle",    { fg = c.bg, bg = c.purple_br, bold = true })
  hl("TelescopePreviewTitle",   { fg = c.bg, bg = c.teal, bold = true })
  hl("TelescopeResultsTitle",   { fg = c.bg, bg = c.blue_br, bold = true })
  hl("TelescopeSelection",      { fg = c.fg, bg = c.bg_visual, bold = true })
  hl("TelescopeMatching",       { fg = c.purple_br, bold = true })

  -- nvim-tree / neo-tree
  hl("NvimTreeNormal",          { fg = c.fg_dim, bg = c.bg_dark })
  hl("NvimTreeFolderName",      { fg = c.blue_br })
  hl("NvimTreeFolderIcon",      { fg = c.purple_br })
  hl("NvimTreeOpenedFolderName",{ fg = c.purple_br, bold = true })
  hl("NvimTreeRootFolder",      { fg = c.purple_br, bold = true })
  hl("NvimTreeGitDirty",        { fg = c.orange })
  hl("NvimTreeGitNew",          { fg = c.teal })
  hl("NvimTreeGitDeleted",      { fg = c.red })
  hl("NvimTreeSpecialFile",     { fg = c.cyan_br })
  hl("NvimTreeIndentMarker",    { fg = c.fg_gutter })

  hl("NeoTreeNormal",           { fg = c.fg_dim, bg = c.bg_dark })
  hl("NeoTreeNormalNC",         { fg = c.fg_dim, bg = c.bg_dark })
  hl("NeoTreeDirectoryName",    { fg = c.blue_br })
  hl("NeoTreeDirectoryIcon",    { fg = c.purple_br })
  hl("NeoTreeRootName",         { fg = c.purple_br, bold = true })
  hl("NeoTreeGitModified",      { fg = c.orange })
  hl("NeoTreeGitAdded",         { fg = c.teal })
  hl("NeoTreeGitDeleted",       { fg = c.red })

  -- WhichKey
  hl("WhichKey",        { fg = c.purple_br })
  hl("WhichKeyGroup",   { fg = c.cyan_br })
  hl("WhichKeyDesc",    { fg = c.fg })
  hl("WhichKeySeperator", { fg = c.fg_dark })
  hl("WhichKeyFloat",   { bg = c.bg_float })

  -- Indent blankline
  hl("IblIndent",       { fg = c.fg_gutter })
  hl("IblScope",        { fg = c.purple })

  -- nvim-cmp
  hl("CmpItemAbbr",            { fg = c.fg })
  hl("CmpItemAbbrDeprecated",  { fg = c.fg_dark, strikethrough = true })
  hl("CmpItemAbbrMatch",       { fg = c.purple_br, bold = true })
  hl("CmpItemAbbrMatchFuzzy",  { fg = c.purple_br, bold = true })
  hl("CmpItemKindFunction",    { fg = c.purple_br })
  hl("CmpItemKindMethod",      { fg = c.purple_br })
  hl("CmpItemKindVariable",    { fg = c.cyan_br })
  hl("CmpItemKindKeyword",     { fg = c.magenta })
  hl("CmpItemKindClass",       { fg = c.blue_br })
  hl("CmpItemKindInterface",   { fg = c.blue_br })
  hl("CmpItemKindText",        { fg = c.teal_br })
  hl("CmpItemKindSnippet",     { fg = c.teal })

  -- Notify
  hl("NotifyERRORBorder", { fg = c.red, bg = c.bg_float })
  hl("NotifyWARNBorder",  { fg = c.orange, bg = c.bg_float })
  hl("NotifyINFOBorder",  { fg = c.cyan_br, bg = c.bg_float })
  hl("NotifyDEBUGBorder", { fg = c.fg_dark, bg = c.bg_float })
  hl("NotifyTRACEBorder", { fg = c.purple, bg = c.bg_float })
  hl("NotifyERRORIcon",   { fg = c.red })
  hl("NotifyWARNIcon",    { fg = c.orange })
  hl("NotifyINFOIcon",    { fg = c.cyan_br })
  hl("NotifyERRORTitle",  { fg = c.red, bold = true })
  hl("NotifyWARNTitle",   { fg = c.orange, bold = true })
  hl("NotifyINFOTitle",   { fg = c.cyan_br, bold = true })

  -- Terminal colors (for :terminal)
  vim.g.terminal_color_0  = c.bg_alt
  vim.g.terminal_color_1  = c.red
  vim.g.terminal_color_2  = c.teal
  vim.g.terminal_color_3  = c.yellow
  vim.g.terminal_color_4  = c.blue
  vim.g.terminal_color_5  = c.magenta
  vim.g.terminal_color_6  = c.cyan
  vim.g.terminal_color_7  = c.fg_dim
  vim.g.terminal_color_8  = c.bg_visual
  vim.g.terminal_color_9  = c.red_br
  vim.g.terminal_color_10 = c.teal_br
  vim.g.terminal_color_11 = c.yellow_br
  vim.g.terminal_color_12 = c.blue_br
  vim.g.terminal_color_13 = c.purple_br
  vim.g.terminal_color_14 = c.cyan_br
  vim.g.terminal_color_15 = c.fg
end

return M
