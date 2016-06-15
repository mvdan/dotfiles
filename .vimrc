call pathogen#infect()

set synmaxcol=1000
filetype plugin indent on

set encoding=utf-8 nocompatible
set number ruler smartindent
set wrap linebreak nolist nojoinspaces
set nobackup noswapfile nowritebackup
set history=1000
set noexpandtab tabstop=8 shiftwidth=8
set textwidth=72 formatoptions-=t formatoptions+=j
set laststatus=2 showcmd hidden wildmenu
set autoread magic matchtime=2
set background=dark lazyredraw
set incsearch ignorecase smartcase showmatch hlsearch

noremap <F1> <nop>
noremap Q <nop>
noremap K <nop>

set shortmess+=I
set backspace=eol,start,indent
set complete-=i
set noerrorbells novisualbell t_vb=

set display+=lastline
set nrformats-=octal
set ttimeout timeoutlen=300
set scrolloff=4

set wildignore=*.pyc,*.o,*.so,*.a
au BufNewFile,BufRead ~/sites/* set filetype=nginx
au BufReadPost fugitive://* set bufhidden=delete

let mapleader = ","

nnoremap <F9> 3<C-W><
nnoremap <F10> 3<C-W>+
nnoremap <F11> 3<C-W>-
nnoremap <F12> 3<C-W>>

au BufRead mutt-* silent setl fo+=t
au BufRead mutt-* silent /^$

au BufNewFile,BufRead *.tex   silent setl fo+=t
au BufNewFile,BufRead *.txt   silent setl et sw=4
au BufNewFile,BufRead *.hs    silent setl et sw=4
au BufNewFile,BufRead *.cabal silent setl et sw=4

au BufNewFile,BufRead ~/git/fcl/*       silent setl et sw=4
au BufNewFile,BufRead ~/git/workcraft/* silent setl et sw=4
au BufNewFile,BufRead ~/git/macfuzzer/* silent setl et sw=4

inoremap jj <esc>
nnoremap <space> :noh<cr>:echo<cr><esc>

noremap <leader>y :silent w !xsel -bi<cr>
noremap <leader>p o<esc>:set paste<cr>:.!xsel -bo<cr>:set nopaste<cr>
noremap <leader>P o<esc>:set paste<cr>:.!xsel -po<cr>:set nopaste<cr>

inoremap <F8> Daniel Martí <mvdan@mvdan.cc>
