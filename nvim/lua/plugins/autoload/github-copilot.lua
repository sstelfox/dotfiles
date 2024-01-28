return {
	"zbirenbaum/copilot.lua",

	-- From the plugin page:
	--
	-- > ...the copilot server takes some time to start up, it is recommend that
	-- > you lazy load copilot.
	cmd = "Copilot",
	event = "InsertEnter",
	config = function()
		require("copilot").setup({})
	end,
}
