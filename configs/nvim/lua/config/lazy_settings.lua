-- This file contains all the configuration settings for the Lazy.nvim package manager. Do not specify plugins in this file, the initial core set of plugins loaded

return {
	-- If our neovim config gets changed, load it up automatically in open
	-- sessions and let us know that happened. Unlike plugin updates, these are
	-- actions we've taken and want our editor to reflect them.
	change_detection = {
		enabled = true,
		notify = true,
	},

	-- We don't want to automatically check for plugin updates, this doesn't add
	-- much overhead but once I get things working I don't want it unexpectedaly
	-- breaking on me.
	checker = {
		enabled = false,
	},

	-- These are default settings for individual plugins, not Lazy settings themselves
	defaults = {
		-- Not all plugins are happy about being lazily loaded, we will enable lazy
		-- loading on a per-plugin basis to make sure we don't break anything.
		lazy = false,

		-- This is based on a Lazy recommendation since a lot of plugins that do
		-- support versioning haven't performed a release in a while and have fixes
		-- in their master branch.
		version = false,
	},

	dev = {
		path = "~/.dotfiles/nvim/dev",
	},

	install = {
		-- Install missing plugins on startup, if they're already present this
		-- doesn't increase startup time.
		missing = true,

		-- During start-up lazy may be missing some number of plugins, if it does it
		-- will attempt to switch to these color schemes in order if they're present.
		colorscheme = { "tokyonight" },
	},

	performance = {
		-- Enable Lazy's package cache to improve performance
		cache = { enabled = true },

		-- Apparently reseting the package path improves the startup time (accoding
		-- to LazyVim). Seems weird but I don't know better...
		reset_packpath = true,

		-- Settings related to the runtime path
		rtp = {
			-- Also from LazyVim, resets the runtime path to $VIMRUNTIME and my config
			-- directory
			reset = true,

			-- Disable various run time path plugins for performance
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},

	-- The 'spec' field is explicitly omitted as that is passed as the first
	-- argument to the actual Lazy setup. This file is simply the config for the lazy package manager.
}
