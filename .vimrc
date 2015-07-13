call pathogen#infect()
Helptags

syntax on
"set synmaxcol=120
filetype plugin indent on

set nocompatible
set number ruler smartindent
set wrap linebreak nolist nojoinspaces
set nobackup noswapfile nowritebackup
set history=2000
set tabstop=8 shiftwidth=8
set textwidth=78 formatoptions-=t
set laststatus=2 showcmd hidden
set autoread magic matchtime=2
set background=dark

" Annoying stuff
nnoremap <F1> <nop>
nnoremap Q <nop>
nnoremap K <nop>
set shortmess+=I
set backspace=eol,start,indent
set noerrorbells novisualbell t_vb=
set timeoutlen=500

set shell=/bin/bash\ -i

set wildignore=*.swp,*.bak,*.pyc,*.o,*.so
au BufNewFile,BufRead *.md set filetype=markdown
au BufNewFile,BufRead *.gradle set filetype=groovy
au BufNewFile,BufRead *.pl set filetype=prolog
au BufNewFile,BufRead ~/sites/* set filetype=nginx
au BufReadPost fugitive://* set bufhidden=delete
set diffopt+=iwhite

set incsearch ignorecase smartcase showmatch hlsearch

" Remove all highlighting
nnoremap <space> :noh<cr>:echo<cr><esc>

" This shall be used further on
let mapleader = ","
let g:mapleader = ","

nnoremap <leader>t :tabn<cr>

" ex command for toggling hex mode - define mapping if desired
command -bar Hexmode call ToggleHex()

" helper function to toggle hex mode
function ToggleHex()
  let l:modified=&mod
  let l:oldreadonly=&readonly
  let &readonly=0
  let l:oldmodifiable=&modifiable
  let &modifiable=1
  if !exists("b:editHex") || !b:editHex
    let b:oldft=&ft
    let b:oldbin=&bin
    setlocal binary
    let &ft="xxd"
    let b:editHex=1
    %!xxd
  else
    let &ft=b:oldft
    if !b:oldbin
      setlocal nobinary
    endif
    let b:editHex=0
    %!xxd -r
  endif
  let &mod=l:modified
  let &readonly=l:oldreadonly
  let &modifiable=l:oldmodifiable
endfunction

" Split window shortcuts
nnoremap <F9> 3<C-W><
nnoremap <F10> 3<C-W>+
nnoremap <F11> 3<C-W>-
nnoremap <F12> 3<C-W>>
inoremap <F9> 3<C-O><C-W><
inoremap <F10> 3<C-O><C-W>+
inoremap <F11> 3<C-O><C-W>-
inoremap <F12> 3<C-O><C-W>>

" E-mail text wrapping
au BufRead mutt-* silent setl formatoptions+=t textwidth=72
" Remove the last signature
au BufRead mutt-* silent g/^> [> ]*-- *$/,?^-- $?-2d
" Start at the first empty line where we'll write
au BufRead mutt-* silent /^$

au BufRead *.txt silent setl et sw=4
au BufRead ~/git/tor/*.[ch] silent setl et sw=2
au BufRead ~/git/fcl/* silent setl et sw=4

inoremap jj <esc>

inoremap <F8> Daniel Martí <mvdan@mvdan.cc>
ab mv@ mvdan@mvdan.cc
