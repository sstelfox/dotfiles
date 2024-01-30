return {
	{
		"nvim-treesitter/nvim-treesitter",

		opts = {
			ensure_installed = {
				"bash",
				"html",
				"javascript",
				--"json",
				"lua",
				"markdown",
				"markdown_inline",
				"python",
				--"query",
				--"regex",
				"ruby",
				"rust",
				"tsx",
				"typescript",
				"vim",
				"yaml",
			},
		},
	},
	{ "nvim-treesitter/nvim-treesitter-refactor" },
}
