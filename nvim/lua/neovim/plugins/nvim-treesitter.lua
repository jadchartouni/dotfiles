require('nvim-treesitter.configs').setup({
    ensure_installed = {
        "json",
        "javascript",
        "yaml",
        "html",
        "css",
        "scss",
        "regex",
        "comment",
        "markdown",
        "bash",
        "lua",
        "vim",
        "dockerfile",
        "gitignore",
        "php",
        "phpdoc",
        "vue",
    },
    auto_install = true,
    highlight = {
        enable = true,
        disable = { "NvimTree" },
        additional_vim_regex_highlighting = true,
    },
    indent = {
        enable = true,
    },
    autotag = {
        enable = true,
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["if"] = "@function.inner",
                ["af"] = "@function.outer",
                ["ic"] = "@class.inner",
                ["ac"] = "@class.outer",
                ["ia"] = '@parameter.inner',
                ["aa"] = '@parameter.outer',
            },
        },
    },
    context_commentstring = {
        enable = true,
    },
})
