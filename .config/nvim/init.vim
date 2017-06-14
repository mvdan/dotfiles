call pathogen#infect()

syntax off
set synmaxcol=200
filetype plugin indent on

set encoding=utf-8
set number ruler smartindent
set wrap linebreak nolist nojoinspaces
set nobackup noswapfile nowritebackup
set noexpandtab tabstop=8 softtabstop=8 shiftwidth=8
set textwidth=72 formatoptions-=t
set showcmd showmode hidden
set magic matchtime=2 lazyredraw
set incsearch ignorecase smartcase showmatch
set mouse=
set rulerformat=%17(%l,%c%V\ %o\ %p%%%)

set t_Co=16
set background=dark
colorscheme solarized

noremap <F1> <nop>
noremap Q <nop>
noremap K <nop>

set shortmess+=I
set noerrorbells novisualbell t_vb=

imap ^? ^H

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
au BufEnter mutt-* silent setl fo+=tn comments+=fb:*
au BufEnter mutt-* silent /^$

au BufEnter *.txt   silent setl et sw=4
au BufEnter *.hs    silent setl et sw=4
au BufEnter *.cabal silent setl et sw=4

au BufEnter ~/git/fcl/* silent setl et sw=4

nnoremap <space> :noh<cr>:echo<cr><esc>

vnoremap <leader>y "+y
nnoremap <leader>p "+p

inoremap <F8> Daniel Martí <mvdan@mvdan.cc>
