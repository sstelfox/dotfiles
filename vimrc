" Reference: http://vimdoc.sourceforge.net/vimum.html
"""""""""""""""""""""""""""""""""""""""""""""""""
" GENERAL CONFIGURATION
"""""""""""""""""""""""""""""""""""""""""""""""""

" Sets how many lines of history VIM has to remember
set history=500

" Turn off vi compatibility mode
set nocompatible

" When vimrc is edited, reload it
autocmd! bufwritepost vimrc source ~/.vimrc

" Check the first 10 lines of a file for vim settings
set modeline
set modelines=10

" Set to auto read when a file is changed from the outside
set autoread

" Configure spell checking, but leave it disabled by default
setlocal nospell spelllang=en_us

highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn', '\%81v', 100)

" When encrypting any file, use the much stronger blowfish algorithm
set cryptmethod=blowfish

" If there is a key set for the file, disable things like swap files, backups,
" temporary files, and history.
autocmd BufReadPost * if &key != "" | set noswapfile nowritebackup viminfo= nobackup noshelltemp history=0 secure | endif

"""""""""""""""""""""""""""""""""""""""""""""""""
" PLUGINS SETUP
"""""""""""""""""""""""""""""""""""""""""""""""""

" Apparently required for the vundle setup
"filetype off
"
"" Require and initialize vundle
"set rtp+=~/.vim/bundle/vundle/
"call vundle#rc()
"
"" Let Vundle manage itself so it can get updated with
"" all the rest
"Bundle 'gmarik/vundle'
"
"" The bundles I want to use, these are git repositories and can take three
"" forms:
""   * Bundle 'name'       => Installs plugin 'name' from the vim-scripts github
""   repo (https://github.com/vim-scripts)
""   * Bundle 'user/name'  => Installs plugin 'name' from the 'user' github
""   repo (https://github.com/<user>
""   * Bundle 'git://git.example.com/plugin.git'  => Installs plugin from a git
""   repository that isn't located on git hub (The same can be done with an
""   http path)
"
"Bundle 'godlygeek/tabular'
"Bundle 'kchmck/vim-coffee-script'
"Bundle 'tpope/vim-fugitive'
"Bundle 'tpope/vim-git'
"Bundle 'tpope/vim-rails'
"Bundle 'sstelfox/vim-markdown'
"Bundle 'Lokaltog/vim-powerline'

" Enable filetype plugin
"filetype indent plugin on

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

" Don't display line numbers
set nonumber

" When opening files automatically background the active buffer rather than
" closing it
set hidden

" Give a little bit of room on the command section for error messages and 
" responses
set cmdheight=2

set nostartofline
set confirm
set pastetoggle=<F11>
nnoremap <C-L> :nohl<CR><C-L>

" Disable the arrow keys... yeah I'm a bit of a masochist
"inoremap  <Up>     <NOP>
"inoremap  <Down>   <NOP>
"inoremap  <Left>   <NOP>
"inoremap  <Right>  <NOP>
"noremap   <Up>     <NOP>
"noremap   <Down>   <NOP>
"noremap   <Left>   <NOP>
"noremap   <Right>  <NOP>

"""""""""""""""""""""""""""""""""""""""""""""""""
" COLORS AND FONTS
"""""""""""""""""""""""""""""""""""""""""""""""""

" Turn on syntax highlighting
syntax on
set ai

set encoding=utf8
try
  lang en_US
catch
endtry

"colorscheme vividchalk

" Default file types
set ffs=unix,dos,mac

"""""""""""""""""""""""""""""""""""""""""""""""""
" Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""

" Expand tabs into spaces
set expandtab
set shiftwidth=2 tabstop=2
set smarttab

" What can I say? I'm old school who needs lines longer than 80 characters?
" NEVER MIND - pain in my ass...
" set textwidth=80

set autoindent
set smartindent
set nowrap

" When wrapping break on spaces rather than in the middle of a word
set lbr

" Highlight tabs and trailing spaces
set listchars=tab:>-,trail:-
set list

"""""""""""""""""""""""""""""""""""""""""""""""""
" Files, backups, and undo
"""""""""""""""""""""""""""""""""""""""""""""""""

" Setup backups in the scratch directory
try
  set backup
  set backupdir=~/.dotfiles/vim-scratch//
  set writebackup
catch
endtry

" Keep swapfiles in the scratch directory 
try
  set directory=~/.dotfiles/vim-scratch//
  set swapfile
catch
endtry

" Keep persistant undo files in the scratch directory
try
  set undodir=~/.dotfiles/vim-scratch//
  set undofile
catch
endtry

"""""""""""""""""""""""""""""""""""""""""""""""""
" Status line
"""""""""""""""""""""""""""""""""""""""""""""""""

" Always show the statusline
set laststatus=2

" Format the statusline
"set statusline=\ %F%m%r%h\ %w\ %r%h\ \ \ Line:\ %l/%L:%c

" Format the statusline
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{CurDir()}%h\ \ \ Line:\ %l/%L:%c

function! CurDir()
    let curdir = substitute(getcwd(), '/home/sstelfox/', "~/", "g")
    return curdir
endfunction

function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    else
        return ''
    endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""
" Mapped triggers
"""""""""""""""""""""""""""""""""""""""""""""""""
map \t :w\|!rspec %<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""

" Add in support for per-directory vim configurations
if filereadable(".vim.custom")
  so .vim.custom
endif
