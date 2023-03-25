-- [[ opts.lua ]]

local opt = vim.opt

-- [[ Context ]]
opt.colorcolumn = '120'     -- str:  Show col for max line length
opt.cursorline = true       -- bool: Enable highlighting of the current line
opt.mouse = "a"             -- str:  Enable mouse mode in all modes
opt.number = true           -- bool: Show line numbers
opt.relativenumber = true   -- bool: Show relative line numbers
opt.scrolloff = 5           -- int:  Min num lines of context
opt.showmode = false        -- bool: Dont show mode since we have a statusline
opt.sidescrolloff = 8       -- num:  Columns of context
opt.signcolumn = "yes"      -- str:  Show the sign column
opt.winminwidth = 5         -- num:  Minimum window width

-- [[ Filetypes ]]
opt.encoding = 'utf8'       -- str:  String encoding to use
opt.fileencoding = 'utf8'   -- str:  File encoding to use

-- [[ Theme ]]
opt.spelllang = { "en" }    -- map:  List of languages to be used
opt.syntax = "on"           -- str:  Allow syntax highlighting
opt.termguicolors = true    -- bool: If term supports ui color then enable

vim.cmd.colorscheme("habamax") -- cmd: configure the theme to use, lazyvim uses a different plugin called 'tokyonight' which I might want to look into...

-- [[ Search ]]
opt.completeopt = "menu,menuone,preview"   -- str:  During completions always pop-up a menu of options and force the user to make a selection.
opt.hlsearch = false    -- bool: Highlight search matches
opt.ignorecase = true   -- bool: Ignore case in search patterns
opt.incsearch = true    -- bool: Use incremental search
opt.pumblend = 10       -- num: Create a slight transparency in pop-up windows
opt.pumheight = 10      -- num: Maximum number of items in pop-up windows
opt.smartcase = true    -- bool: Override ignorecase if search contains capitals
opt.wildmode = "lastused,full"          -- str:  Ordering of completion entries

-- [[ Whitespace ]]
opt.expandtab = true    -- bool: Use spaces instead of tabs
opt.list = true         -- bool: Show some invisible characters (tabs...
opt.shiftwidth = 4      -- num:  Size of an indent
opt.smartindent = true  -- bool: Insert indents automatically
opt.tabstop = 4         -- num:  Number of spaces tabs count for

-- [[ Splits ]]
opt.splitright = true   -- bool: Place new window to right of current one
opt.splitbelow = true   -- bool: Place new window below the current one

-- [[ Undo / History / Clipboard ]]
opt.clipboard = "unnamedplus"               -- str:  Sync with system clipboard
opt.undofile = true                         -- bool: Persist change history in files
opt.undolevels = 10000                      -- num:  The count of historical changes tracked

-- [[ Formatting ]]
opt.formatoptions = "jcroqlnt"  -- str:  Options for the auto-format handlers (order matters):
                                -- * j: remove comment leader when joining lines
                                -- * c: auto-wrap comments using textwidth
                                -- * r: automatically insert comment leader on returns
                                -- * o: automatically insert comment leader in append insertions
                                -- * q: allow formatting comments
                                -- * l: long lines are not broken in insert mode
                                -- * n: recognize numbered lists and wrap internally to them
                                -- * t: auto-wrap text using textwidth
opt.inccommand = "nosplit"      -- str:  preview incremental substitute in the buffer
opt.laststatus = 0      -- num:  Don't show any status-line ever, we'll use a plugin for that
opt.shiftround = true   -- bool: Round indent to a multiple of shiftwidth
opt.signcolumn = "yes"  -- str:  Always show the sign-column in the numeric column, otherwise it
                        --       would shift the text each time.
opt.wrap = false        -- bool: Disable line wrapping

-- [[ Timeouts ]]
opt.timeoutlen = 300    -- num:  Time to wait for mapped sequences to wait
opt.updatetime = 200    -- num:  After this many milliseconds without anything being typed, the
                        --       swapfile will be saved.

-- Some other options I might want later on...
-- opt.conceallevel = 3 -- num:  Hide * markup for bold and italic
-- opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
-- opt.shortmess:append { W = true, I = true, c = true }
