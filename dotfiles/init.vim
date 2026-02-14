" =========================
" BASIC SETTINGS
" =========================

if has('termguicolors')
  set termguicolors
endif

set nocompatible
set showmatch
set ignorecase
set hlsearch
set incsearch
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=4
set autoindent
set number
set wildmode=longest,list
set cc=80
set cindent
set mouse=a
set clipboard=unnamedplus
set cursorline
set signcolumn=yes
set winminwidth=1
set winminheight=1

filetype plugin indent on
syntax on

" Disable netrw (for nvim-tree)
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

nnoremap <C-n> :NvimTreeToggle<CR>

" =========================
" PLUGINS
" =========================

call plug#begin()

Plug 'rebelot/kanagawa.nvim'
Plug 'tpope/vim-sensible'
Plug 'christoomey/vim-tmux-navigator'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'preservim/nerdcommenter'
Plug 'mhinz/vim-startify'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Native LSP + Completion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'

call plug#end()

" =========================
" LUA CONFIGURATION
" =========================
lua << EOF

-- =====================
-- NVIM TREE
-- =====================
require("nvim-tree").setup({
  hijack_cursor = true,
  sync_root_with_cwd = true,
  view = { width = 30 },
  actions = {
    open_file = { quit_on_open = true }
  }
})

-- =====================
-- TREE-SITTER
-- =====================
local ts_ok, ts_configs = pcall(require, "nvim-treesitter.configs")
if ts_ok then
  ts_configs.setup({
    ensure_installed = { "c", "cpp", "lua", "python", "javascript", "html", "css", "rust" },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
    },
  })
end

-- =====================
-- NATIVE LSP (Neovim 0.11+)
-- =====================

vim.lsp.config("clangd", {
  cmd = { "/usr/bin/clangd",
"--header-insertion=never",
"--function-arg-placeholders=false"},
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_markers = {
    "compile_commands.json",
    "CMakeLists.txt",
    ".git",
  },
})

vim.lsp.enable("clangd")

-- LSP Keymaps
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'gr', vim.lsp.buf.references)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation)
vim.keymap.set('n', 'K', vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
vim.keymap.set('n', '<leader>f', function()
  vim.lsp.buf.format({ async = true })
end)

-- Let semantic tokens override treesitter
vim.highlight.priorities.semantic_tokens = 200

-- =====================
-- COMPLETION (nvim-cmp)
-- =====================

local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
    window = {
    completion = {
      border = 'rounded',
      winhighlight = 'Normal:CmpNormal,FloatBorder:CmpFloatBorder,CursorLine:CmpCursorLine,Search:None',
    },
    documentation = {
      border = 'rounded',
      winhighlight = 'Normal:CmpNormal,FloatBorder:CmpFloatBorder',
    },
  },
    completion = {
    autocomplete = false,  -- This disables auto-popup
  },
  mapping = {
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
  },
})

-- =====================
-- COLORSCHEME
-- =====================
vim.cmd("colorscheme kanagawa")
vim.cmd([[
  highlight CmpNormal guibg=#1F1F28 guifg=#DCD7BA
  highlight CmpFloatBorder guifg=#54546D guibg=#1F1F28
  highlight CmpCursorLine guibg=#2D4F67
  highlight CmpItemAbbr guifg=#DCD7BA guibg=NONE
  highlight CmpItemAbbrMatch guifg=#7E9CD8 guibg=NONE gui=bold
  highlight CmpItemAbbrMatchFuzzy guifg=#7E9CD8 guibg=NONE
  highlight CmpItemKind guifg=#7FB4CA guibg=NONE
  highlight CmpItemMenu guifg=#727169 guibg=NONE
  highlight PmenuSel guibg=#2D4F67 guifg=#DCD7BA
]])


EOF
