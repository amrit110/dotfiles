syntax on
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nu rnu
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set wildmenu
set wildmode=longest,list,full

set colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=lightgrey

"Plugins"
call plug#begin('~/.vim/plugged')
Plug 'gruvbox-community/gruvbox'
Plug 'ambv/black'
Plug 'neovim/nvim-lspconfig'
Plug 'kabouzeid/nvim-lspinstall'
Plug 'mbbill/undotree'
Plug 'kien/ctrlp.vim'
Plug 'rust-lang/rust.vim'
Plug 'nvim-lua/completion-nvim'
call plug#end()

"Language servers"
lua << EOF
local nvim_lsp = require('lspconfig')
-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'pyright' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = require'completion'.on_attach,
  }
end
EOF

"Autocomplete"
set completeopt=menuone,noinsert,noselect
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']

"Gruvbox theme biatch"
let g:gruvbox_bold=1 
let g:gruvbox_contrast_dark='hard'
autocmd vimenter * ++nested colorscheme gruvbox
set background=dark

if executable('rg')
    let g:rg_derive_root='true'
endif
let mapleader = " "
let g:netrw_browse_split = 3
let g:netrw_winsize = 25
let g:netrw_banner = 0

"Key remappings"
inoremap jj <ESC>
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>
nnoremap <leader>s :wincmd s<CR>
nnoremap <leader>v :wincmd v<CR>
nnoremap <leader>q :wincmd q<CR>
nnoremap <leader>u :UndotreeShow u<CR>
nnoremap <leader>pv :wincmd v<bar> :Ex <bar> :vertical resize 30<CR>
