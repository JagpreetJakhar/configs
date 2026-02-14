if has('termguicolors')
  set termguicolors
endif
set nocompatible            " disable compatibility to old-time vi
set showmatch               " show matching 
set ignorecase              " case insensitive 
set mouse=v                 " middle-click paste with 
set hlsearch                " highlight search 
set incsearch               " incremental search
set tabstop=4               " number of columns occupied by a tab 
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set number                  " add line numbers
set wildmode=longest,list   " get bash-like tab completions
set cc=80                   " set an 80 column border for good coding style
set cindent
filetype plugin indent on   "allow auto-indenting depending on file type
syntax on                   " syntax highlighting
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
filetype plugin on
set cursorline              " highlight current cursorline
set ttyfast 
set winminwidth=1
set winminheight=1
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1
nnoremap <C-n> :NvimTreeToggle<CR>

" CoC configuration for better C++/clangd integration
set updatetime=300          " Faster completion and diagnostics
set signcolumn=yes          " Always show the signcolumn for diagnostics
set shortmess+=c            " Don't pass messages to ins-completion-menu

call plug#begin()
    " List your plugins here
    Plug 'rebelot/kanagawa.nvim'
    Plug 'tpope/vim-sensible'
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'ryanoasis/vim-devicons'
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'
    Plug 'nvim-tree/nvim-tree.lua'
    Plug 'nvim-tree/nvim-web-devicons'
    Plug 'preservim/nerdcommenter'
    Plug 'mhinz/vim-startify'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'neoclide/coc.nvim', {'branch':'release'}
call plug#end()

lua << EOF
require('nvim-tree').setup({
  hijack_cursor = true,
  sync_root_with_cwd = true,
  view = {
    width = 30,
  },
  actions = {
    open_file = {
      quit_on_open = true,
    },
  },
})

-- Fixed TreeSitter configuration to avoid errors
local status_ok, treesitter_configs = pcall(require, 'nvim-treesitter.configs')
if status_ok then
  treesitter_configs.setup {
    ensure_installed = { "c", "cpp", "lua", "python", "javascript", "html", "css","cuda","rust" },
    auto_install = false,  -- Disable auto-install to prevent errors
    sync_install = false,
    ignore_install = {},
    highlight = {
      enable = true,
      disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
      disable = { "python" },  -- Python indenting can be problematic
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },
  }
else
  vim.notify("nvim-treesitter not installed. Run :PlugInstall", vim.log.levels.WARN)
end

-- Set colorscheme
vim.cmd([[colorscheme kanagawa]])
EOF

" Enhanced CoC mappings for clangd integration
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
inoremap <expr> <Esc> coc#pum#visible() ? "\<C-e>" : "\<Esc>"
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" GoTo code navigation (essential for C++ development)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
