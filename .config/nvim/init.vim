call plug#begin()

Plug 'ajgrf/parchment', {'branch': 'HEAD'}

Plug 'ojroques/nvim-osc52', {'branch': 'HEAD'}

Plug 'numToStr/Comment.nvim', {'branch': 'HEAD'}

Plug 'neovim/nvim-lspconfig', {'branch': 'HEAD'}

Plug 'tpope/vim-fugitive', {'branch': 'HEAD'}

Plug 'junegunn/fzf.vim', {'branch': 'HEAD'}

call plug#end()

let mapleader = ","
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }

lua <<EOF

	require('Comment').setup()

	-- Copy the selection into the clipboard via OSC52.
	vim.keymap.set('n', '<leader>y', require('osc52').copy_operator, {expr = true})
	vim.keymap.set('n', '<leader>yy', '<leader>y_', {remap = true})
	vim.keymap.set('x', '<leader>y', require('osc52').copy_visual)

	vim.keymap.set('n', '<leader>f', ":GFiles<CR>", {silent = true}) -- all git files
	vim.keymap.set('n', '<leader>F', ":Files<CR>", {silent = true}) -- all files
	vim.keymap.set('n', '<leader>g', ":call fzf#run(fzf#wrap({'source': 'git diff --name-only refs/remotes/origin/HEAD', 'sink': 'e'}))<CR>", {silent = true}) -- changed git files
	vim.keymap.set('n', '<leader>l', ":Lines<CR>", {silent = true})
	vim.keymap.set('n', '<leader>r', ":Rg<space>")

	-- Mappings.
	-- See `:help vim.diagnostic.*` for documentation on any of the below functions
	local opts = { noremap=true, silent=true }
	-- vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
	-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
	-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
	vim.keymap.set('n', '[q', ":cprev<CR>", opts)
	vim.keymap.set('n', ']q', ":cnext<CR>", opts)
	vim.keymap.set('n', '<space>q', vim.diagnostic.setqflist, opts)

	-- Use an on_attach function to only map the following keys
	-- after the language server attaches to the current buffer
	local on_attach = function(client, bufnr)
		-- Mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local bufopts = { noremap=true, silent=true, buffer=bufnr }
		vim.keymap.set('n', 'gD', vim.lsp.buf.type_definition, bufopts)
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
		vim.keymap.set('n', '<C-i>', vim.lsp.buf.signature_help, bufopts) -- instead of <C-k>
		vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
		vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
		vim.keymap.set('n', '<space>wl', function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, bufopts)
		vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
		vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
		vim.keymap.set('n', '<space>f', vim.lsp.buf.format, bufopts)
	end

	require('lspconfig').gopls.setup{
		cmd = {"gopls", "-remote=auto", "-remote.listen.timeout=5m", "serve"},
		-- Uncomment to debug gopls:
		-- cmd = {"gopls", "-logfile=auto", "-rpc.trace", "serve"},
		on_attach = on_attach,
		flags = lsp_flags,
		settings = {
			gopls = {
				staticcheck = true,
			},
		},
	}

	vim.api.nvim_create_autocmd('BufWritePre', {
		pattern = '*.go',
		callback = function()
			vim.lsp.buf.format()
			vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
		end
	})

EOF

" gofmt or equivalent on save
" TODO: is it conflicting with organizeImports above?
" autocmd BufWritePre * lua vim.lsp.buf.format()

function! SynGroup()
	let l:s = synID(line('.'), col('.'), 1)
	echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfun
map gm :call SynGroup()<CR>

" Parchment, similar to Acme or solarized-light with fewer colors.
set background=light
colorscheme parchment
highlight clear Type " not a big fan, plus incomplete for Go

" not really Special
highlight link shOption NONE
highlight link shCommandSub NONE
highlight link shTestPattern NONE

set nobackup noswapfile nowritebackup
set undofile

set mouse=a

set smartindent
set wrap linebreak

set noexpandtab tabstop=4 softtabstop=4 shiftwidth=4
set textwidth=80 formatoptions-=t formatoptions+=j
set magic matchtime=2 lazyredraw
set ignorecase smartcase showmatch
set rulerformat=%22(%l,%c%V\ %o\ %p%%%)

set termguicolors " truecolor support.

noremap <F1> <nop>
noremap Q <nop>
noremap K <nop>

set shortmess+=I " no intro message
" set noerrorbells novisualbell t_vb=

" imap ^? ^H

" set ttimeout timeoutlen=300 ttimeoutlen=0
set scrolloff=4

set wildignore=*.pyc,*.o,*.so,*.a

" Paste from the system clipboard.
" TODO: would be nice if this used OSC52 as well.
noremap <leader>p "+p

" resize splits
nnoremap <F9> 3<C-W><
nnoremap <F10> 3<C-W>+
nnoremap <F11> 3<C-W>-
nnoremap <F12> 3<C-W>>

" navigate splits
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

set pastetoggle=<F3>
nnoremap <F5> :%!xxd -g 1<CR>
nnoremap <F6> :%!xxd -g 1 -r<CR>

au FileType gitcommit setlocal ts=4 " otherwise the builtin default of 8 kicks in

au FileType mail silent setl ft=mail tw=72 fo+=tn comments+=fb:*
au FileType mail silent /^$

au FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

au BufEnter testdata/*.txt silent setl ft=sh
au BufEnter *.txtar silent setl ft=sh

nnoremap <silent> <space> :noh<cr>:echo<cr><esc>

inoremap <F8> Daniel Martí <mvdan@mvdan.cc>
