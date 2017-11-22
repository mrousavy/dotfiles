set nocompatible
filetype indent plugin on
syntax on
set hidden
set wildmenu
set showcmd
set hlsearch
set ignorecase
set smartcase
set backspace=indent,eol,start
set autoindent
set nostartofline
set ruler
set laststatus=2
set confirm
set visualbell
set t_vb=
set cmdheight=2
set relativenumber
set number
set cursorline
"set shiftwidth=4
"set softtabstop=4
"set expandtab
set shiftwidth=4
set tabstop=4
map Y y$
nnoremap <C-L> :nohl<CR><C-L>
execute pathogen#infect()
cnoreabbrev nt NERDTree
map <F2> :NERDTree<CR>
