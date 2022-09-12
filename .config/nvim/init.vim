call plug#begin()

Plug 'ajgrf/parchment', {'branch': 'HEAD'}

Plug 'ojroques/vim-oscyank', {'branch': 'HEAD'}

Plug 'numToStr/Comment.nvim', {'branch': 'HEAD'}

Plug 'neovim/nvim-lspconfig', {'branch': 'HEAD'}

Plug 'tpope/vim-fugitive', {'branch': 'HEAD'}

Plug 'junegunn/fzf.vim', {'branch': 'HEAD'}

call plug#end()

lua <<EOF

	require('Comment').setup()

	-- Mappings.
	-- See `:help vim.diagnostic.*` for documentation on any of the below functions
	local opts = { noremap=true, silent=true }
	vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
	vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
	vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
	vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

	-- Use an on_attach function to only map the following keys
	-- after the language server attaches to the current buffer
	local on_attach = function(client, bufnr)
		-- Enable completion triggered by <c-x><c-o>
		vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

		-- Enable go-to-definition with <C-]> as well.
		vim.api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")

		-- Mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local bufopts = { noremap=true, silent=true, buffer=bufnr }
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
		vim.keymap.set('n', '<C-i>', vim.lsp.buf.signature_help, bufopts) -- instead of <C-k>
		vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
		vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
		vim.keymap.set('n', '<space>wl', function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, bufopts)
		vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
		vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
		vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
		vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
	end

	require('lspconfig').gopls.setup{
		cmd = {"gopls", "-remote=auto", "-remote.listen.timeout=5m", "serve"},
		on_attach = on_attach,
		flags = lsp_flags,
	}

	function OrgImports(wait_ms)
		local params = vim.lsp.util.make_range_params()
		params.context = {only = {"source.organizeImports"}}
		local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
		for _, res in pairs(result or {}) do
			for _, r in pairs(res.result or {}) do
				if r.edit then
					vim.lsp.util.apply_workspace_edit(r.edit, "UTF-8")
				else
					vim.lsp.buf.execute_command(r.command)
				end
			end
		end
	end

EOF

" add missing imports for Go
autocmd BufWritePre *.go lua OrgImports(1000)
" gofmt or equivalent on save
autocmd BufWritePre * lua vim.lsp.buf.formatting_sync()

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

set nobackup noswapfile nowritebackup
set undofile

set mouse=a

set smartindent
set wrap linebreak nolist

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

let mapleader = ","

" Copy the selection into the clipboard via OSC52.
vnoremap <leader>y :OSCYank<CR>

" Paste from the system clipboard.
" TODO: would be nice if this used OSC52 as well.
noremap <leader>p "+p

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

au FileType gitcommit setlocal ts=4 " otherwise the builtin default of 8 kicks in

au FileType mail silent setl ft=mail tw=72 fo+=tn comments+=fb:*
au FileType mail silent /^$

au FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

au BufEnter testdata/*.txt silent setl ft=sh

nnoremap <space> :noh<cr>:echo<cr><esc>

inoremap <F8> Daniel Martí <mvdan@mvdan.cc>
