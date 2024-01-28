-- vim: set ts=2 sw=2 expandtab ai :

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  -- bootstrap the package manager
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end

vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

-- Some of these options need to be configured before we start sourcing plugin
-- modules to ensure they're correctly applied, such as mapleader and
-- maplocalleader.
require("options")

require("autocmds")
require("keymaps")

require("lazy").setup({
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
    }
  },

  -- Define all the plugins I want to use and their specific configurations,
  -- this doesn't necessarily load them
  spec = {
    -- Lets start with my preferred theme, no extra functionality or keybinds
    {
      'folke/tokyonight.nvim',

      -- I always want this and its very high priority
      lazy = false,
      priority = 1000,

      -- To actually make use of the theme we need to enable it, but we can't do
      -- it until its loaded. This function gets called as soon as its ready and
      -- switches us over to our theme.
      config = function()
        vim.cmd([[colorscheme tokyonight]])
      end,

      opts = { style = 'moon' },
    },

    -- This plugin defines common entrypoints into the NeoVIM UI allowing them
    -- to be customized at a common layer shared by other plugins for a
    -- consistent UI experience throughout NeoVIM.
    { 'stevearc/dressing.nvim', lazy = true, opts = {} },
  },
})
