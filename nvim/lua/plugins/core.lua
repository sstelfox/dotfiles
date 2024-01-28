return {
	-- Still very not happy about quite a few of LazyVim's options, I've decided
	-- to inline it and gut it freely down to its minimums until I'm happy with
	-- the results.
	{ "LazyVim/LazyVim", import = "lazyvim.plugins", dev = true },

	-- Include all my automatically loaded plugin configs
	{ import = "plugins/autoload" },
}
