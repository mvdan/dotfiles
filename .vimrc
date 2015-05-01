call pathogen#infect()
Helptags

syntax on
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

set shell=/bin/bash\ -i

set wildignore=*.swp,*.bak,*.pyc,*.o,*.so
au BufNewFile,BufRead *.md set filetype=markdown
au BufNewFile,BufRead *.pl set filetype=prolog
au BufNewFile,BufRead *.PKGBUILD set filetype=sh
au BufNewFile,BufRead ~/sites/* set filetype=nginx
au BufReadPost fugitive://* set bufhidden=delete
set diffopt+=iwhite

set incsearch ignorecase smartcase showmatch hlsearch

" Remove all highlighting
nnoremap <space> :noh<cr>:echo<cr><esc>

" No sound on errors
set noerrorbells novisualbell t_vb=
set timeoutlen=500

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
au BufRead mutt-* silent setl formatoptions+=t textwidth=72
" Remove the last signature
au BufRead mutt-* silent g/^> [> ]*-- *$/,?^-- $?-2d
" Start at the first empty line where we'll write
au BufRead mutt-* silent /^$

au BufRead *.txt silent setl et
au BufRead ~/git/tor/*.[ch] silent setl et sw=2
au BufRead ~/git/fcl/* silent setl et sw=4
au BufRead ~/git/bunked-web/*.py silent setl noet sw=4 ts=4

inoremap jj <esc>
set backspace=eol,start,indent

" Copy/pasting via xsel
noremap <leader>y :silent w !xsel -bi<cr>
noremap <leader>Y :silent w !xsel -pi<cr>
noremap <leader>p o<esc>:set paste<cr>:.!xsel -bo<cr>:set nopaste<cr>:silent! %s/ / /g<cr>
noremap <leader>P o<esc>:set paste<cr>:.!xsel -po<cr>:set nopaste<cr>:silent! %s/ / /g<cr>

inoremap <F8> Daniel Martí <mvdan@mvdan.cc>
ab mv@ mvdan@mvdan.cc
au BufRead,BufNewFile *.pddl setf lisp
au BufNewFile,BufRead *.gradle set filetype=groovy
