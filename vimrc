set nocompatible

filetype indent plugin on

" When vimrc is edited, reload it
autocmd! bufwritepost .vimrc source ~/.vimrc

syntax on

set hidden
set wildmenu
set showcmd
set hlsearch
set nomodeline

" For searching
set ignorecase
set smartcase

" Allow Ctrl+PgUp/PgDn in tmux
set t_kN=[6;*~
set t_kP=[5;*~

set autoindent

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

set backspace=indent,eol,start
set shiftwidth=2 tabstop=2
set smarttab
set expandtab

nnoremap <C-L> :nohl<CR><C-L>
