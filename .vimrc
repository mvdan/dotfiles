call pathogen#infect()

set synmaxcol=1000
filetype plugin indent on

set encoding=utf-8 nocompatible
set number ruler smartindent
set wrap linebreak nolist nojoinspaces
set nobackup noswapfile nowritebackup
set history=1000
set noexpandtab tabstop=8 softtabstop=8 shiftwidth=8
set textwidth=72 formatoptions-=t formatoptions+=j
set laststatus=2 showcmd showmode hidden wildmenu
set autoread magic matchtime=2 lazyredraw ttyfast
set incsearch ignorecase smartcase showmatch hlsearch

set t_Co=16
set background=dark
colorscheme solarized

noremap <F1> <nop>
noremap Q <nop>
noremap K <nop>

set shortmess+=I
set backspace=indent,eol,start
set complete-=i
set noerrorbells novisualbell t_vb=

imap ^? ^H

set display+=lastline
set nrformats-=octal
set ttimeout timeoutlen=300
set scrolloff=4

set wildignore=*.pyc,*.o,*.so,*.a
au BufReadPost fugitive://* set bufhidden=delete

let mapleader = ","

nnoremap <F9> 3<C-W><
nnoremap <F10> 3<C-W>+
nnoremap <F11> 3<C-W>-
nnoremap <F12> 3<C-W>>

nnoremap <F5> :%!xxd -g 1<CR>
nnoremap <F6> :%!xxd -g 1 -r<CR>

au BufEnter COMMIT_EDITMSG silent syntax on
au BufEnter mutt-* silent syntax on
au BufEnter mutt-* silent setl fo+=t
au BufEnter mutt-* silent /^$

au BufEnter *.tex   silent setl fo+=t
au BufEnter *.txt   silent setl et sw=4
au BufEnter *.hs    silent setl et sw=4
au BufEnter *.cabal silent setl et sw=4

au BufEnter ~/git/fcl/*       silent setl et sw=4
au BufEnter ~/git/workcraft/* silent setl et sw=4
au BufEnter ~/git/macfuzzer/* silent setl et sw=4

inoremap jj <esc>
nnoremap <space> :noh<cr>:echo<cr><esc>

noremap <leader>y :silent w !xsel -bi<cr>
noremap <leader>p o<esc>:set paste<cr>:.!xsel -bo<cr>:set nopaste<cr>
noremap <leader>P o<esc>:set paste<cr>:.!xsel -po<cr>:set nopaste<cr>

inoremap <F8> Daniel Martí <mvdan@mvdan.cc>
