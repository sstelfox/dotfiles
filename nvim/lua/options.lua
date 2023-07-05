-- Use the very convenient spacebar as our leaders
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.completeopt = "menu,menuone,noselect"

-- Hide '*' markup for bold and italic
opt.conceallevel = 3

-- Confirm saving before exiting a modified buffer instead of just aborting the exit
opt.confirm = true

-- Enable highlighting of the current line
opt.cursorline = true

-- Use spaces instead of tabs
opt.expandtab = true

-- TODO: document this and validate these options are what I want
opt.formatoptions = "jcroqlnt"

-- Use ripgrep instead of the standard one
opt.greprg = "rg --vimgrep"

-- Preview incremental substitutions in the file
opt.grepformat = "%f:%l:%c:%m"

-- When searching, don't take case into account unless capitals are present
opt.ignorecase = true
opt.smartcase = true

-- Show the line number, relative to the current line
opt.number = true
opt.relativenumber = true

-- Show invisible characters
opt.list = true

-- Size of an indent, and how many spaces a tab should take up, rounding any
-- indents to the nearest correct value
opt.shiftwidth = 2
opt.tabstop = 2
opt.shiftround = true

-- Number of lines of context to always keep visible near the edges
opt.scrolloff = 5

-- Disable line wrapping
opt.wrap = false
