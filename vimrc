"""""""""""""""""""""""""""""""""""""""""""""""""
" GENERAL CONFIGURATION
"""""""""""""""""""""""""""""""""""""""""""""""""

" Turn off vi compatibility mode
set nocompatible

" Sets how many lines of history VIM has to remember
set history=500

" Enable filetype plugin
filetype indent plugin on

" Set to auto read when a file is changed from the outside
set autoread

" When vimrc is edited, reload it
autocmd! bufwritepost vimrc source ~/.vim_runtime/vimrc

"""""""""""""""""""""""""""""""""""""""""""""""""
" USER INTERFACE CONFIGURATION
"""""""""""""""""""""""""""""""""""""""""""""""""

" Turn on WiLd menu
set wildmenu
set showcmd
set hlsearch
set incsearch

"""""""""""""""""""""""""""""""""""""""""""""""""
" COLORS AND FONTS
"""""""""""""""""""""""""""""""""""""""""""""""""

"Turn on syntax highlighting
syntax on

set encoding=utf8
try
	lang en_US
catch
endtry

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

set magic

set hidden

" Show matching brackets when text indicator is over them
set showmatch

" How many tenths of a second to blink
set mat=2

set nomodeline

set ignorecase
set smartcase

set backspace=indent,eol,start

set nostartofline
set ruler
set laststatus=2
set confirm
set visualbell
set t_vb=
set cmdheight=2
set number
set notimeout ttimeout ttimeoutlen=200
set pastetoggle=<F11>

nnoremap <C-L> :nohl<CR><C-L>
