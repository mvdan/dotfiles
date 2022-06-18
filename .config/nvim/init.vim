syntax off
set synmaxcol=200
filetype plugin indent on

set nocompatible
set nobackup noswapfile nowritebackup

set encoding=utf-8
set ruler autoindent smartindent
set wrap linebreak nolist nojoinspaces

set noexpandtab tabstop=4 softtabstop=4 shiftwidth=4
set textwidth=80 formatoptions-=t formatoptions+=j
set showcmd showmode hidden
set magic matchtime=2 lazyredraw
set incsearch ignorecase smartcase showmatch hlsearch
set rulerformat=%22(%l,%c%V\ %o\ %p%%%)
set autoread laststatus=2

" if &t_Co == 8 && $TERM !~# '^linux\|^Eterm'
" 	set t_Co=16
" endif
" if (empty($TMUX))
"   if (has("termguicolors"))
"     set termguicolors
"   endif
" endif

" Truecolor support.
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors

set background=light
" let g:gruvbox_contrast_light='hard'
" colorscheme gruvbox

noremap <F1> <nop>
noremap Q <nop>
noremap K <nop>

set shortmess+=I
set noerrorbells novisualbell t_vb=

imap ^? ^H

set ttimeout timeoutlen=300 ttimeoutlen=0
set scrolloff=4

set wildignore=*.pyc,*.o,*.so,*.a
au BufReadPost fugitive://* set bufhidden=delete

let mapleader = ","

" Copy the selection into the clipboard via OSC52.
vnoremap <leader>y :OSCYank<CR>

" Paste from Wayland, until Vim supports it natively.
" See: https://github.com/vim/vim/issues/5157
noremap <leader>p o<esc>:set paste<cr>:.!wl-paste<cr>:set nopaste<cr>

nnoremap <F9> 3<C-W><
nnoremap <F10> 3<C-W>+
nnoremap <F11> 3<C-W>-
nnoremap <F12> 3<C-W>>

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

set pastetoggle=<F3>
nnoremap <F5> :%!xxd -g 1<CR>
nnoremap <F6> :%!xxd -g 1 -r<CR>

au FileType gitcommit silent syntax on
au FileType gitcommit setlocal ts=4 " otherwise the builtin default of 8 kicks in

au FileType mail silent syntax on
au FileType mail silent setl ft=mail tw=72 fo+=tn comments+=fb:*
au FileType mail silent /^$

au FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

au BufEnter testdata/*.txt silent setl ft=sh
let g:airline#extensions#whitespace#skip_indent_check_ft = {'go': ['mixed-indent-file']}
let g:airline_theme='gruvbox'

nnoremap <space> :noh<cr>:echo<cr><esc>

inoremap <F8> Daniel Martí <mvdan@mvdan.cc>
