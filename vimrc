" Reference: http://vimdoc.sourceforge.net/vimum.html
"""""""""""""""""""""""""""""""""""""""""""""""""
" GENERAL CONFIGURATION
"""""""""""""""""""""""""""""""""""""""""""""""""

" Sets how many lines of history VIM has to remember
set history=500

" Turn off vi compatibility mode
set nocompatible

" Enable filetype plugin
filetype indent plugin on

" Set to auto read when a file is changed from the outside
set autoread

" When vimrc is edited, reload it
autocmd! bufwritepost vimrc source ~/.vim_runtime/vimrc

"""""""""""""""""""""""""""""""""""""""""""""""""
" USER INTERFACE CONFIGURATION
"""""""""""""""""""""""""""""""""""""""""""""""""

" Start scrolling up when the cursor is 5 lines away from the top
set scrolloff=5

" Turn on WiLd menu
set wildmenu

" Always show the current position
set ruler

" The command bar height
set cmdheight=2

" Change buffer without saving
set hid

" How backspace behaves
set backspace=indent,eol,start

" Ignore case when searching unless we used a capital
set ignorecase
set smartcase

" Highlight searched strings
set hlsearch

" Make search act like in modern browsers
set incsearch

" Set magic on for regular expression
set magic

" Show matching brackets when text indicator is over them
set showmatch

" How many tenths of a second to blink
set mat=2

" No sound on errors, but flash the screen
set noerrorbells
set visualbell
set t_vb=
set notimeout ttimeout ttimeoutlen=200

" Display any incomplete commands in the status bar
set showcmd

" Display line numbers
set number

"""""""""""""""""""""""""""""""""""""""""""""""""
" COLORS AND FONTS
"""""""""""""""""""""""""""""""""""""""""""""""""

" Turn on syntax highlighting
syntax on

set encoding=utf8
try
	lang en_US
catch
endtry

" Default file types
set ffs=unix,dos,mac

"""""""""""""""""""""""""""""""""""""""""""""""""
" Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""

" Expand tabs into spaces
set expandtab
set shiftwidth=2 tabstop=2
set smarttab

"set lbr
"set tw=500

set autoindent
set smartindent
set wrap

"""""""""""""""""""""""""""""""""""""""""""""""""
" Files, backups, and undo
"""""""""""""""""""""""""""""""""""""""""""""""""

" Turn backup off, everything is in git anyway
set nobackup
set nowritebackup

" Damn these things...
set noswapfile

" Setup a persistant undo file
try
  set undodir=~/.dotfiles/vim-undodir
  set undofile
catch
endtry

"""""""""""""""""""""""""""""""""""""""""""""""""

set hidden

set nomodeline

set nostartofline
set laststatus=2
set confirm

set cmdheight=2
set pastetoggle=<F11>

nnoremap <C-L> :nohl<CR><C-L>
