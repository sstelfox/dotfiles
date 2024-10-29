return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"rafi/neoconf-venom.nvim",
		},
		config = function(_, opts)
			require("venom").setup()
		end,
	},
	{
		"rafi/neoconf-venom.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "folke/neoconf.nvim" },
	},
}
