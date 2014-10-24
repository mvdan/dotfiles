call pathogen#infect()
Helptags

syntax on
filetype plugin indent on

set nocompatible
set number ruler smartindent
set wrap linebreak nolist
set nobackup noswapfile nowb
set history=2000
set tabstop=4 shiftwidth=4
set tw=78 fo-=t
set laststatus=2 showcmd hidden autoread magic mat=2
set background=dark
set nojoinspaces

set foldmethod=syntax foldnestmax=1
hi Folded ctermbg=black

set shell=/bin/bash\ -i

set wildignore=*.swp,*.bak,*.pyc,*.o,*.so
au BufNewFile,BufRead *.md set filetype=markdown
au BufNewFile,BufRead ~/sites/* set filetype=nginx
au BufReadPost fugitive://* set bufhidden=delete
set diffopt+=iwhite

set incsearch ignorecase smartcase showmatch hlsearch

" Remove all highlighting
nnoremap <space> :noh<cr>:echo<cr><esc>

" No sound on errors
set noerrorbells novisualbell t_vb=
set tm=500

" Save with sudo
command W :execute ':silent w !sudo tee % > /dev/null' | :edit!
command Wq :execute ':silent w !sudo tee % > /dev/null' | :quit!

" This shall be used further on
let mapleader = ","
let g:mapleader = ","

let g:tagbar_autoclose = 1
let g:tagbar_compact = 1

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
au BufRead mutt-* silent set formatoptions+=t textwidth=72 foldmethod=manual
" Remove the last signature
au BufRead mutt-* silent g/^> [> ]*-- *$/,?^-- $?-2d
" Start at the first empty line where we'll write
au BufRead mutt-* silent /^$

au BufRead *.txt silent set et
au BufRead ~/git/tor/*.[ch] silent set et sw=2
au BufRead ~/git/fcl/* silent set et sw=4
au BufRead ~/git/ia/* silent set et sw=4
au BufRead ~/git/whatthedish-android/* silent set et sw=4

inoremap jj <esc>
set backspace=eol,start,indent

" Copy/pasting via xsel
noremap <leader>y :silent w !xsel -bi<cr>
noremap <leader>Y :silent w !xsel -pi<cr>
noremap <leader>p o<esc>:set paste<cr>:.!xsel -bo<cr>:set nopaste<cr>:silent! %s/ / /g<cr>
noremap <leader>P o<esc>:set paste<cr>:.!xsel -po<cr>:set nopaste<cr>:silent! %s/ / /g<cr>

inoremap <F8> Daniel Martí <mvdan@mvdan.cc>
ab mv@ mvdan@mvdan.cc
