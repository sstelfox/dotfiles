--[[ init.lua ]]

local g = vim.g

-- [[ Leader ]]

-- Used to access most shortcuts and mapped key commands, space is a very fast and convenient
-- command leader
g.mapleader = " "
g.localleader = " "

-- [[ Imports ]]

require('vars')      -- Global variables used by other scripts
require('opts')      -- Vim specific options
require('keys')      -- Keymaps, binds, and quick commands
require('plugins')   -- Base container for any plugin installation, setup, and configuration
require('fixes')     -- Fixes for various weird behaviors or problems in plugins
