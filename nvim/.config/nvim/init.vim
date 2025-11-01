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
set updatetime=64

"⚡️ Leader key timeout adjustment ⚡️"
set timeoutlen=300  " Reduce delay after leader key press
set clipboard+=unnamedplus  " System clipboard integration

"Plugins"
call plug#begin('~/.vim/plugged')
Plug 'gruvbox-community/gruvbox'
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'
Plug 'kkoomen/vim-doge', { 'do': { -> doge#install() } }
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
call plug#end()

"Python docstring gen
let g:doge_doc_standard_python = 'numpy'

"Gruvbox theme"
let g:gruvbox_bold=1 
let g:gruvbox_contrast_dark='hard'
set background=dark
autocmd vimenter * ++nested colorscheme gruvbox
autocmd ColorScheme gruvbox highlight ColorColumn ctermbg=0 guibg=lightgrey
set colorcolumn=88

if executable('rg')
    set grepprg=rg\ -n\ \"$*\"
    let g:rg_derive_root='true'
endif

"⚡️ Explicit leader definition ⚡️"
let mapleader = "\<Space>"  " Explicit space leader
let g:netrw_browse_split = 3
let g:netrw_winsize = 25
let g:netrw_banner = 0

"Key remappings"
inoremap jj <ESC>

"⚡️ Improved window mappings with descriptions ⚡️"
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>
nnoremap <leader>s :wincmd s<CR>
nnoremap <leader>v :wincmd v<CR>
nnoremap <leader>q :wincmd q<CR>
nnoremap <leader>u :UndotreeShow u<CR>
nnoremap <leader>pv :wincmd v<bar> :Ex <bar> :vertical resize 30<CR>

"⚡️ Global Ivo's mom mapping ⚡️"
nnoremap <leader>im :echo "Ivo's mom"<CR>

"Clipboard integration ⚡️"
vnoremap <leader>y "+y
nnoremap <leader>Y "+yg_
nnoremap <leader>y "+y

"Language servers"
lua << EOF
-- Wrap in pcall to avoid errors during initial plugin installation
local success, lsp_installer = pcall(require, "nvim-lsp-installer")
if not success then
  return
end

local util_success, util = pcall(require, 'lspconfig/util')
if not util_success then
  return
end

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  local opts = { noremap=true, silent=true }

  -- LSP mappings
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_lsp_success, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if cmp_lsp_success then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

local servers = {
    pyright = {
        settings = {
            python = {
                analysis = {
                    typeCheckingMode = "off",
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    diagnosticMode = "openFilesOnly",
                }
            }
        },
        capabilities = capabilities,
        root_dir = function(fname)
            local root_files = {
                'pyproject.toml',
                'setup.py',
                'setup.cfg',
                'requirements.txt',
                'Pipfile',
                'pyrightconfig.json',
                'venv',
                }
            return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname) or util.path.dirname(fname)
        end
    },
    ccls = {},
    rust_analyzer = {
        settings = {}
    }
}

-- ⚡️ Safer server setup ⚡️
lsp_installer.on_server_ready(function(server)
    local success, _ = pcall(function()
        server:setup(servers[server.name])
    end)
    if not success then
        vim.notify("Failed to setup server: " .. server.name, vim.log.levels.WARN)
    end
end)

-- nvim-cmp setup
local cmp_success, cmp = pcall(require, 'cmp')
if not cmp_success then
  return
end

cmp.setup {
  snippet = {
    expand = function(args)
      local luasnip_success, luasnip = pcall(require, 'luasnip')
      if luasnip_success then
        luasnip.lsp_expand(args.body)
      end
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
  },
}
EOF

"Github copilot"
imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true
