-- vim: set ts=2 sw=2 expandtab ai :

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	-- bootstrap the package manager
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end

vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

-- The core initial plugins, and the Lazy package manager configuration have been
-- split into two independent files. See the appropriate ones for more details.
local lazy_spec = require("plugins/core")
local lazy_settings = require("config/lazy_settings")

-- Lazy recommends having these set before it gets loaded. LazyVim does handle
-- this but I'm tearing that apart and don't want something so basic to break.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Kick of the plugin loading process
require("lazy").setup(lazy_spec, lazy_settings)
