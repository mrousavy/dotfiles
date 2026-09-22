" Color code according to the file's syntax.
syntax on

" Detect file types and load their settings and indentation rules.
filetype plugin indent on

" Enable bundled comment toggling: gcc for a line, gc for a selection or motion.
packadd comment

" Show absolute line numbers on every line.
set number norelativenumber

" Disable highlighting of the cursor's line.
set nocursorline

" Keep five lines of vertical context around the cursor.
set scrolloff=5

" Search without case sensitivity unless the pattern contains uppercase letters.
set ignorecase smartcase

" Preview search matches while typing and highlight all matches.
set incsearch
set hlsearch

" Insert spaces for Tab and use two-space indentation and editing steps.
set expandtab
set shiftwidth=2
set softtabstop=2

" Allow Backspace over indentation, line breaks, and the start of an insertion.
set backspace=indent,eol,start

" Keep unsaved buffers in memory when switching to another file.
set hidden

" Show completion suggestions automatically while typing colon commands.
set wildmenu
set wildoptions+=pum
" Show choices without inserting one until you select it.
set wildmode=noselect:lastused,full
augroup CommandLineSuggestions
  autocmd!
  autocmd CmdlineChanged : call wildtrigger()
augroup END

" Open new vertical splits to the right and horizontal splits below.
set splitright
set splitbelow

" Always show a status line, even with only one window.
set laststatus=2

" Use Space as the leader key; Space then h clears search highlighting.
" GitGutter also uses Space h p/s/u to preview/stage/undo a hunk.
let mapleader = " "
nnoremap <leader>h :nohlsearch<CR>

" GitGutter loads automatically from ~/.vim/pack/airblade/start/vim-gitgutter.
" Keep the change-marker column visible so code does not shift horizontally.
set signcolumn=yes

" Refresh Git change markers after 100 ms of inactivity.
" This also controls Vim's idle delay before writing its swap file.
set updatetime=100

" Toggle the file-browser sidebar with Space then e in Normal mode.
nnoremap <silent> <leader>e :Lexplore<CR>

" Follow macOS light/dark appearance at startup and while Vim is open.
" vim-lumen loads automatically and runs its Swift helper only with Vim.
let g:lumen_startup_overwrite = 1

" Use full RGB colors for the One Light and One Dark palettes.
set termguicolors

" vim-one supplies both variants; vim-lumen selects via background=light/dark.
let g:lumen_light_colorscheme = 'one'
let g:lumen_dark_colorscheme = 'one'

" Optional machine-specific settings, never tracked in this repository.
if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
