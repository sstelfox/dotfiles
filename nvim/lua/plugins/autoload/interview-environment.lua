return {
	--{ "hrsh7th/nvim-cmp", opts = { completion = { autocomplete = false } } },
	{ "zbirenbaum/copilot.lua", enabled = false },
	{ "rcarriga/nvim-notify", enabled = false },
	{
		"folke/noice",
		enabled = false,
		opts = {
			notify = {
				enabled = false,
			},
		},
	},
}