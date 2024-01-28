-- Use the very convenient spacebar as our leaders, lazy recommends calling this
-- before calling its own setup.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable perl before it ever gets a chance to load
vim.g.loaded_perl_provider = 0

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
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

-- Preview incremental substitutions in the file
opt.inccommand = "nosplit"

-- When searching, don't take case into account unless capitals are present
opt.ignorecase = true
opt.smartcase = true

-- Show the line number, relative to the current line, and always include the
-- sign/line status column so the sidebar doesn't resize.
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"

-- Show invisible characters
opt.list = true

opt.mouse = ""

-- Size of an indent, and how many spaces a tab should take up, rounding any
-- indents to the nearest correct value, and inserting them automatically
opt.shiftwidth = 2
opt.tabstop = 2
opt.shiftround = true
opt.smartindent = true

-- Number of lines/characters of context to always keep visible near the edges
opt.scrolloff = 5
opt.sidescrolloff = 8

-- Disable line wrapping
opt.wrap = false

-- Highlight the currently active line
opt.cursorline = tre

-- After running commands in a terminal don't show the exit status
opt.laststatus = 0

-- Spelling configuration
opt.spelllang = { "en" }

-- Enable true color support
opt.termguicolors = true

-- When splitting windows, split down and to the right
opt.splitbelow = true
opt.splitright = true

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

-- Command line completion mode
opt.wildmode = "longest:full,full"

-- Minimum window width
opt.winminwidth = 5

-- The built in mouse support is incredibly frustrating
opt.mouse = ""
