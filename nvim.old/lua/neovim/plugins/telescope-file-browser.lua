require("telescope").setup {
    extensions = {
        file_browser = {
            -- Disables netrw and use telescope-file-browser in its place
            hijack_netrw = true,
            mappings = {
                ["i"] = {

                },
                ["n"] = {

                },
            },
        },
    },
}

require("telescope").load_extension "file_browser"
