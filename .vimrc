call pathogen#infect()
Helptags

syntax on
set synmaxcol=500
filetype plugin indent on

set encoding=utf-8
set nocompatible
set number ruler smartindent
set wrap linebreak nolist nojoinspaces
set nobackup noswapfile nowritebackup
set history=2000
set noexpandtab tabstop=8 shiftwidth=8
set textwidth=72 formatoptions-=t formatoptions+=j
set laststatus=2 showcmd hidden wildmenu
set autoread magic matchtime=2
set fileformats+=mac
set background=dark
set incsearch ignorecase smartcase showmatch hlsearch
set lazyredraw

nnoremap <F1> <nop>
nnoremap Q <nop>
nnoremap K <nop>
vnoremap Q <nop>
vnoremap K <nop>
set shortmess+=I
set backspace=eol,start,indent
set complete-=i
set noerrorbells novisualbell t_vb=

set display+=lastline
set nrformats-=octal
set ttimeout
set timeoutlen=300

set wildignore=*.swp,*.bak,*.pyc,*.o,*.so,*.a
au BufNewFile,BufRead *.md set filetype=markdown
au BufNewFile,BufRead *.gradle set filetype=groovy
au BufNewFile,BufRead *.pl set filetype=prolog
au BufNewFile,BufRead ~/sites/* set filetype=nginx
au BufReadPost fugitive://* set bufhidden=delete
set diffopt+=iwhite

nnoremap <space> :noh<cr>:echo<cr><esc>

let mapleader = ","
let g:mapleader = ","

command -bar Hexmode call ToggleHex()
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

nnoremap <F9> 3<C-W><
nnoremap <F10> 3<C-W>+
nnoremap <F11> 3<C-W>-
nnoremap <F12> 3<C-W>>

au BufRead mutt-* silent setl formatoptions+=t
au BufRead mutt-* silent g/^[> ]\+-- *$/,?^-- $?-2d
au BufRead mutt-* silent setl mod
au BufRead mutt-* silent /^$

au BufNewFile,BufRead *.txt silent setl et sw=4
au BufNewFile,BufRead ~/git/tor/*.[ch] silent setl et sw=2
au BufNewFile,BufRead ~/git/fcl/* silent setl et sw=4
au BufNewFile,BufRead ~/git/macfuzzer/* silent setl et sw=4
au BufNewFile,BufRead ~/git/qksms/* silent setl et sw=4

inoremap jj <esc>

noremap <leader>y :silent w !xsel -bi<cr>
noremap <leader>p o<esc>:set paste<cr>:.!xsel -bo<cr>:set nopaste<cr>
noremap <leader>P o<esc>:set paste<cr>:.!xsel -po<cr>:set nopaste<cr>

inoremap <F8> Daniel Martí <mvdan@mvdan.cc>
