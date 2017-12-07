set history=500
filetype plugin on
filetype indent on

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
set cmdheight=2

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
noremap <F3> <C-C>za

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

" Paste mode toggle
map <leader>pp :setlocal paste!<cr>

set cursorline

" Plugins
execute pathogen#infect()

" Open NERDTree if no file is open
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Shortcut and abbreviation
cnoreabbrev nt NERDTree
map <F2> :NERDTreeToggle<CR>
