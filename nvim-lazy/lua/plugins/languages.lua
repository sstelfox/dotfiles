local lspconfig = require("lspconfig")

lspconfig.rust_analyzer.setup({
    settings = {
        ["rust-analyzer"] = {},
    },
})

return {
    -- extra typescript setup
    { import = "lazyvim.plugins.extras.lang.typescript" },

    { "folke/neoconf.nvim" },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "bash",
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
    },
}
