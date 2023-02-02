require("nvim-tree").setup({
    update_focused_file = {
        enable = true,
    },
    view = {
        width = 35,
    },
    git = {
        ignore = false,
    },
    renderer = {
        highlight_opened_files = "1",
        group_empty = true,
        icons = {
            show = {
                folder_arrow = false,
            },
        },
        indent_markers = {
            enable = true,
        },
    },
})

vim.cmd([[
    highlight NvimTreeIndentMarker guifg=#30323E
    augroup NvimTreeHighlights
    autocmd ColorScheme * highlight NvimTreeIndentMarker guifg=#30323E
    augroup end
]])
