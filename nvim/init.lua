-- vim: set ts=2 sw=2 expandtab ai :

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not vim.loop.fs_stat(lazypath) then
	-- bootstrap the package manager
	vim.fn.system({
		'git',
		'clone',
		'--filter=blob:none',
		'--branch=stable',
		'https://github.com/folke/lazy.nvim.git',
		lazypath,
	})
end

vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

-- Define all the plugins I want to use and their specific configurations, this
-- doesn't necessarily load them
local lazy_spec = {
  -- Still very not happy about quite a few of LazyVim's options, I've decided
  -- to inline it and gut it freely down to its minimums until I'm happy with
  -- the results.
  { 'LazyVim/LazyVim', import = 'lazyvim.plugins', dev = true },

  -- Include my own plugin systems
  { import = 'plugins' },
}

local lazy_settings = {
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
    path = '~/.dotfiles/nvim/dev',
  },

	install = {
		-- Install missing plugins on startup, if they're already present this
		-- doesn't increase startup time.
		missing = true,

		-- During start-up lazy may be missing some number of plugins, if it does it
		-- will attempt to switch to these color schemes in order if they're present.
		colorscheme = { 'tokyonight' },
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
				'gzip',
				'tarPlugin',
				'tohtml',
				'tutor',
				'zipPlugin',
			},
		},
	},

  -- This is passed separately
	spec = null,
}

require('lazy').setup(lazy_spec, lazy_settings)
