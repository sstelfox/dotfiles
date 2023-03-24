return {
    -- extra typescript setup
    { import = "lazyvim.plugins.extras.lang.typescript" },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "bash",
                "c",
                "help",
                "html",
                "javascript",
                "json",
                "lua",
                "markdown",
                "markdown_inline",
                "python",
                "query",
                "regex",
                "rust",
                "tsx",
                "typescript",
                "vim",
                "yaml",
            },
        },
        -- config = function(_, opts)
        --     require("nvim-treesitter.configs").setup(opts)
        -- end,
    },
}
