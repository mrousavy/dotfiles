" Disable Vi emulation
set nocompatible

" Pathogen Plugin Manager
execute pathogen#infect()

" Filetypes
set history=500

" Filetype indenting
filetype plugin indent on

" NEOVIM
" Block Cursor in INPUT
set guicursor=

" Color Theme - ONEDARK
if (empty($TMUX))
  if (has("nvim"))
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  if (has("termguicolors"))
    set termguicolors
  endif
endif
let g:onedark_termcolors=256
let g:onedark_terminal_italics=1
colorscheme onedark

" Color Theme - ONEDARK Status bar Lightline
let g:lightline = {
      \ 'colorscheme': 'onedark',
      \ }

" Auto outside-changes
set autoread

" For extra shortcuts
let mapleader = ","
let g:maploader= ","

" Quicksave
nmap <leader>w :w!<cr>

" sudo save
command W w !sudo tee % > /dev/null

" Enable wildmenu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc
set wildignore+=*/.git*

" Caret ruler
set ruler

" Command bar height
"set cmdheight=2

" Discarded buffers get hidden
set hid

" Fix backspace
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Case-insensitive and smart search
set ignorecase
set smartcase

" Find results highlighting
set hlsearch
set incsearch

" RegEx
set magic

" Bracket highlighting
set showmatch
set mat=2

" Left margin
set foldcolumn=1

" Syntax and filetype
syntax enable
set ffs=unix,dos,mac

" Disable Vim bck files
set nobackup
set nowb
set noswapfile

" Tabs
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4

" Linebreak on 500 chars
set lbr
set tw=500

" Smart auto indenting
set ai
set si
set wrap

" Always show status line
set laststatus=2

function! HasPaste()                                                                           
  if &paste             
    return 'PASTE MODE  '
  endif                 
  return ''             
endfunction

" Format statusline
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c

" Line number
set number
set relativenumber

" 0 -> First readabale character
map 0 ^

" Alt + J/K line up/down
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z

" Code folding
setlocal foldmethod=syntax
noremap <space> <C-C>za

" Delete useless whitespaces on save
fun! CleanExtraSpaces()
	let save_cursor = getpos(".")
	let old_query = getreg('/')
	silent! %s/\s\+$//e
	call setpos('.', save_cursor)
	call setreg('/', old_query)
endfun

if has("autocmd")
	autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
endif

" Windows ^M fix
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" 1/2 Page scrolling 
nnoremap <C-Down> <C-e><CR>
nnoremap <C-Up> <Up><Up><C-y><CR>

" Paste mode toggle
map <leader>pp :setlocal paste!<cr>

set cursorline

" Fix lag - render lazy
set lazyredraw

" PLUGINS
" Open NERDTree if no file is open
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Shortcut and abbreviation - Nerd Tree
cnoreabbrev nt NERDTree
map <F2> :NERDTreeToggle<CR>

" Shortcut and abbreviation - LaTeX Live Previews
autocmd Filetype tex setl updatetime=1500
let g:livepreview_previewer = 'okular'
let g:livepreview_engine = 'latexmk -pdf'
cnoreabbrev texp NERDTree
map <F5> :LLPStartPreview<CR>

" Spell check
map <F3> :setlocal spell! spelllang=en_us<CR>

