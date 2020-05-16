" John Liu's vimrc
"
" Some general instructions:
" - Requires `vim-plug` (https://github.com/junegunn/vim-plug)
" - Run `:PlugInstall` on first run.

" Critical Configurations
" =======================

" Leader Key
let mapleader = ","


" Plugins
" =======

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" Languages and Syntax
Plug 'othree/html5.vim'
Plug 'elixir-editors/vim-elixir'

" UI Upgrades
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'vim-airline/vim-airline'
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'altercation/vim-colors-solarized'
Plug 'godlygeek/csapprox'

" Editing Upgrades
Plug 'scrooloose/nerdcommenter'
Plug 'Raimondi/delimitMate'
Plug 'tpope/vim-surround'

" Misc Upgrades
Plug 'mattn/gist-vim'
Plug 'mattn/webapi-vim'

call plug#end()

" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" scrooloose/nerdtree
let g:NERDTreeNodeDelimiter = "\u00a0"
let g:NERDTreeShowHidden = 1

" scrooloose/nerdcommenter
let g:NERDSpaceDelims = 1

" scrooloose/syntastic
let g:syntastic_quiet_messages = { 'level': 'warnings' }
let g:syntastic_check_on_open = 1
let g:syntastic_error_symbol = '✗'
let g:syntastic_warning_symbol = '⚠'
let g:syntastic_auto_loc_list = 0

" vim-airline/vim-airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'default'

" Raimondi/delimitMate
let delimitMate_balance_matchpairs = 1

" mattn/gist-vim
let g:gist_clip_command = 'pbcopy'
let g:gist_detect_filetype = 1
let g:gist_show_privates = 1
let g:gist_post_private = 1

" altercation/vim-colors-solarized
set background=dark
let g:solarized_termtrans = 1
let g:solarized_termcolors = 256
let g:solarized_constrast = "normal"
let g:solarized_visibility = "normal"
colorscheme solarized

" Set font for GUI vim.
if has("gui_running")
  set guifont=Monaco:h14
  set guioptions-=T
  set guioptions-=r
  set guioptions-=R
  set guioptions-=l
  set guioptions-=L
endif

" Key Remappings
" ==============

" Plugin Mappings

" scrooloose/nerdtree
nnoremap <silent> <leader>n :NERDTreeToggle<cr>

" junegunn/fzf.vim
nnoremap <C-f> :Rg<cr>
nnoremap <C-t> :FZF<cr>

" Other Mappings

" Quickly edit vimrc.
nnoremap <leader>e :e! ~/.vimrc<cr>

" Force save read only files.
cnoremap w!! %!sudo tee > /dev/null %

" Clears highlighting.
nnoremap <leader><space> :noh<cr>

" Reselect visual block after indent/outdent
vnoremap < <gv
vnoremap > >gv

" Disable arrow keys by default, turn them into something useful (switch buffer).
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> :bp<cr>
nnoremap <right> :bn<cr>

" Disable shift + K opening man pages.
nnoremap <s-k> <nop>

" Don't need shift for commands.
nnoremap ; :
vnoremap ; :

" Leader to reselect pasted
nnoremap <leader>v V`]

" Remap split window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Fix save typos.
:ca WQ wq
:ca Wq wq
:ca QA qa
:ca Qa qa
:ca W w
:ca Q q

" Leader to toggle list chars
nnoremap <leader>l :set list!<cr>


" Misc Settings
" =============

" Remember 700 lines of history.
set history=700

" Allow per project vimrc
set exrc
set secure

" Enable filetype plugin and indent files
filetype plugin on
filetype indent on

" Disable modelines (security exploits)
set modelines=0

" Show line with cursor
set cursorline

" Fast terminal
set ttyfast

" Set to auto read when a file is changed from the outside
set autoread

" Speed up <shift>O
set timeoutlen=500
set ttimeoutlen=50

" Better copy and paste
set pastetoggle=<F2>
set clipboard=unnamed

" Add mouse scrolling.
set mouse=a

" Start scrolling 7 lines before the top/bottom
set scrolloff=14

" Turn on enhanced completions, and set completion options
set wildmenu
set wildmode=list:longest
set completeopt=menuone,longest

" Command bar height
set cmdheight=2

" Change buffers without saving (allow hidden buffers).
set hidden

" Set backspace config
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase
set smartcase

" Highlight search results
set hlsearch

" Make search act like in modern browsers
set incsearch

" Default global substitution
set gdefault

" Do not redraw when executing macros
set nolazyredraw

" Magic for regular expressions
set magic

" Show matching bracket indicator when text indicator is over them
set showmatch
set matchtime=2

" No sound on errors
set noerrorbells
set visualbell
set t_vb=

" Attempt to turn on encoding
set encoding=utf8
try
  lang en_US
catch
endtry

" Show the line number
set number

" Enable syntax highlighting
syntax enable

" Set invisible characters
set listchars=eol:¬,tab:▸·,trail:·

" Turn backup off (mostly using git, etc anyway)
set nobackup
set nowb
set noswapfile

" Tab settings
set expandtab
set smarttab
set shiftwidth=2
set tabstop=2
set softtabstop=2

set linebreak
set textwidth=0
set colorcolumn=100
set wrap

" Format options
set formatoptions=qrn1

" Indentation settings
set autoindent
set smartindent
au! FileType python setl nosmartindent

" Always hide the status line
set laststatus=2
