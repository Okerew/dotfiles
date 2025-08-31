call plug#begin('~/.local/share/nvim/plugged')

Plug 'tpope/vim-surround'
Plug 'lewis6991/gitsigns.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/nvim-cmp'
Plug 'dense-analysis/ale'
Plug 'shaunsingh/nord.nvim'
Plug 'stevearc/conform.nvim'
Plug 'lervag/vimtex'
Plug 'jiaoshijie/undotree'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'rcarriga/nvim-notify'
Plug 'jcha0713/cmp-tw2css'
Plug 'brianhuster/live-preview.nvim'
Plug 'Okerew/depramanager-nvim'
Plug 'ThePrimeagen/harpoon', { 'branch': 'harpoon2' }
Plug 'rafamadriz/friendly-snippets'
Plug 'L3MON4D3/LuaSnip', {'tag': 'v2.*', 'do': 'make install_jsregexp'} 
Plug 'saadparwaiz1/cmp_luasnip' 
Plug 'ThePrimeagen/refactoring.nvim'
Plug 'folke/which-key.nvim'
Plug 'Okerew/od.nvim'

call plug#end()

" === SETTINGS ===
let mapleader = " "             " Use space as leader (I prefer space, changed from comma for consistency)
colorscheme nord     " Default colorscheme
set fillchars=eob:\ 
:setlocal spell
:setlocal spelllang=en_us

" === KEYMAPS ===
" Buffer navigation
nnoremap gt :bnext<CR>
nnoremap gT :bprev<CR>

" Disable 'Q' in normal mode (usually ex mode, to avoid mistakes)
nnoremap Q <nop>

" Join lines without moving cursor
nnoremap J mzJ`z

" Scroll and center cursor
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

" Search results center screen
nnoremap n nzzzv
nnoremap N Nzzzv

" Quickfix navigation centered
nnoremap <C-k> :cnext<CR>zz
nnoremap <C-j> :cprev<CR>zz

" Substitute word under cursor globally and ignore case
nnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>

" Delete without yank (blackhole)
nnoremap d "_d
vnoremap d "_d
nnoremap x "_x
vnoremap x "_x
nnoremap X "_X
vnoremap X "_X

nnoremap =ap ma=ap'a

vnoremap p "_dP

nnoremap <silent> [d :lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> ]d :lua vim.diagnostic.goto_next()<CR>

lua << EOF
-- Telescope and utilities
vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>", { desc = "Find Files" })
vim.keymap.set("n", "<leader>d", ":Telescope diagnostics<CR>", { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>l", ":Telescope live_grep<CR>", { desc = "Live Grep" })
vim.keymap.set("n", "<leader>o", ":Telescope lsp_document_symbols<CR>", { desc = "Document Symbols" })
vim.keymap.set("n", "<leader>u", ":lua require('undotree').toggle()<CR>", { desc = "Toggle Undotree" })
vim.keymap.set("n", "<leader>a", ":lua require('harpoon'):list():add()<CR>", { desc = "Add to Harpoon" })

-- Buffer operations
vim.keymap.set("n", "<leader>;", ":new<CR>", { desc = "New Buffer (Split)" })
vim.keymap.set("n", "<leader>,", ":enew<CR>", { desc = "New Buffer" })
vim.keymap.set("n", "<leader>.", ":bprevious<CR>:bd! #<CR>", { desc = "Close Buffer" })

-- Clipboard operations
vim.keymap.set({ "n", "v" }, "<leader>y", "\"+y", { desc = "Yank to System Clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>x", "\"+d", { desc = "Cut to System Clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", "\"_\"+p", { desc = "Paste from System (No Overwrite)" })
vim.keymap.set({ "n", "v" }, "<leader>v", "\"+p", { desc = "Paste from System" })
vim.keymap.set("n", "<leader>c", "d", { desc = "Delete (Yank)" })
vim.keymap.set("v", "<leader>c", "d", { desc = "Delete Selection (Yank)" })

-- Quickfix and location list navigation
vim.keymap.set("n", "<leader>j", ":lprev<CR>zz", { desc = "Previous Location" })
vim.keymap.set("n", "<leader>k", ":lnext<CR>zz", { desc = "Next Location" })

-- Visual mode specific mappings
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Selection Down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Selection Up" })
EOF

let g:vimtex_view_method = 'zathura'
let g:vimtex_view_zathura_use_synctex = 0

" Gitsigns
lua << EOF
require('gitsigns').setup {
  signs = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signcolumn = true,
  numhl      = false,
  linehl     = false,
  word_diff  = false,
  watch_gitdir = {
    follow_files = true
  },
  auto_attach = true,
  attach_to_untracked = false,
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol',
    delay = 1000,
    ignore_whitespace = false,
    virt_text_priority = 100,
    use_focus = true,
  },
  current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
  sign_priority = 6,
  update_debounce = 100,
  preview_config = {
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
}
EOF

" ALE settings
let g:ale_completion_enabled = 1

let g:ale_linters = {
\   'python': ['flake8'],
\   'javascript': ['eslint'],
\   'c': ['clangtidy'],
\   'cpp': ['clangtidy'],
\   'go': ['golangci-lint'],
\   'rust': ['clippy'],
\}


" === MASON SETUP ===
lua << EOF
-- Mason setup - must be called before lspconfig
require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

-- Mason-lspconfig setup
require("mason-lspconfig").setup({
    ensure_installed = {
        "pyright",
        "clangd", 
        "rust_analyzer",
        "ts_ls",
        "bashls",
        "cssls",
        "jsonls",
        "html",
        "lua_ls",
	"gopls",
	},
    automatic_installation = true,
})

-- Function to install additional tools
local function ensure_installed()
    local mason_registry = require("mason-registry")
    
    -- List of tools to ensure are installed
    local tools_to_install = {
        -- Python tools
        "black",
        "isort",
        "flake8",
        
        -- JavaScript/TypeScript tools
        "prettier",
        "prettierd",
        "eslint_d",
        
        -- C/C++ tools
        "clang-format",
        "clang-tidy",  -- Note: it's clang-tidy, not clangtidy
        
        -- Go tools
        "goimports",
	"golangci-lint",
        
        -- Rust tools
        "rustfmt",
        
        -- Lua tools
        "stylua",
    }
    
    -- Install tools that aren't already installed
    for _, tool in ipairs(tools_to_install) do
        if mason_registry.has_package(tool) then
            local p = mason_registry.get_package(tool)
            if not p:is_installed() then
                p:install()
            end
        end
    end
end

-- Defer the installation to avoid race conditions
vim.defer_fn(ensure_installed, 100)
EOF

lua << EOF
local ls = require("luasnip")

require("luasnip.loaders.from_vscode").lazy_load()
EOF

lua <<EOF
local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
        require("luasnip").lsp_expand(args.body) 
    end,
  },

  completion = {
    completeopt = "menu,menuone,noinsert,noselect",
  },
  preselect = cmp.PreselectMode.None,

  -- Add window configuration for consistent appearance
  window = {
    completion = cmp.config.window.bordered({
      border = 'rounded',
      winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
    }),
    documentation = cmp.config.window.bordered({
      border = 'rounded',
      winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
    }),
  },

  formatting = {
    format = function(entry, vim_item)
      -- Set the source name
      vim_item.menu = ({
        nvim_lsp = "[LSP]",
        luasnip = "[Snip]",
        buffer = "[Buf]",
        path = "[Path]",
        nvim_lsp_signature_help = "[Sig]",
      })[entry.source.name]
      
      return vim_item
    end
  },

  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    
    ["<CR>"] = cmp.mapping({
      i = function(fallback)
        if cmp.visible() and cmp.get_active_entry() then
          cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
        else
          fallback()
        end
      end,
      s = cmp.mapping.confirm({ select = false }),
    }),
    
    -- Better Tab mapping - navigates completions when visible, otherwise normal tab
    ["<Tab>"] = cmp.mapping(function(fallback)
      local luasnip = require("luasnip")
      if cmp.visible() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }), 
    
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      local luasnip = require("luasnip")
      if cmp.visible() then
        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }), 
    
    -- Alternative: Use Ctrl+j/k for explicit navigation
    ["<C-j>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      else
        fallback()
      end
    end, { "i", "s" }),
    
    ["<C-k>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
      else
        fallback()
      end
    end, { "i", "s" }),
  }),

  sources = cmp.config.sources({
    { name = "nvim_lsp", priority = 1000 },
    { name = "luasnip", priority = 900 },
    { name = "nvim_lsp_signature_help", priority = 800 },
    { name = "path", priority = 600 },  
    { name = "buffer", priority = 400, keyword_length = 3 },
    { name = "cmp-tw2css", priority = 300 },
  }),

  performance = {
    debounce = 30,        
    throttle = 15,        
    fetching_timeout = 60,
    confirm_resolve_timeout = 40,
    async_budget = 1,
    max_view_entries = 50, 
  },

  experimental = {
    ghost_text = true,    
  },

  view = {
    entries = { name = 'custom', selection_order = 'near_cursor' }
  },

  completion = {
    autocomplete = {
      cmp.TriggerEvent.TextChanged,
    },
    keyword_length = 2,  -- Require at least 2 characters before showing completions
  },
})

cmp.setup.filetype({ "gitcommit", "markdown" }, {
  sources = cmp.config.sources({
    { name = "path", priority = 800 },
    { name = "buffer", priority = 600 },
  })
})

cmp.setup.filetype('TelescopePrompt', {
  enabled = false
})
EOF

lua <<EOF
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
    rust = { "rustfmt" },
    go = { "gofmt", "goimports" },
    c = { "clang_format" },
    cpp = { "clang_format" },
    javascript = { "prettierd", "prettier", stop_after_first = true },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})
EOF

let g:python3_host_prog = $HOME . '/.local/venv/nvim/bin/python'

lua << EOF
local undotree = require('undotree')

undotree.setup({
  float_diff = true,  -- using float window previews diff, set this `true` will disable layout option
  layout = "left_bottom", -- "left_bottom", "left_left_bottom"
  position = "left", -- "right", "bottom"
  ignore_filetype = { 'undotree', 'undotreeDiff', 'qf', 'TelescopePrompt', 'spectre_panel', 'tsplayground' },
  window = {
    winblend = 30,
  },
  keymaps = {
    ['j'] = "move_next",
    ['k'] = "move_prev",
    ['gj'] = "move2parent",
    ['J'] = "move_change_next",
    ['K'] = "move_change_prev",
    ['<cr>'] = "action_enter",
    ['p'] = "enter_diffbuf",
    ['q'] = "quit",
  },
})
EOF

lua << EOF
-- nvim-notify setup
require("notify").setup({
  -- Animation style
  stages = "fade_in_slide_out",
  
  -- Function called when a new window is opened
  on_open = nil,
  
  -- Function called when a window is closed
  on_close = nil,
  
  -- Render function for notifications
  render = "default",
  
  -- Default timeout for notifications
  timeout = 3000,  -- Increased from 500ms to 3 seconds for better visibility
  
  -- Background colour
  background_colour = "#000000",
  
  -- Minimum width for notification windows
  minimum_width = 50,
  
  -- Icons for the different levels
  icons = {
    ERROR = "",
    WARN = "",
    INFO = "",
    DEBUG = "",
    TRACE = "✎",
  },
})

-- Store the original notify function
local notify = require("notify")

-- List of message prefixes to block
local blocked_prefixes = {
  "config.mappings.show_system_prompt",
  "config.mappings.show_user_selection",
  "'canary' branch is deprecated",
}

-- Custom notify function that filters unwanted messages
vim.notify = function(msg, level, opts)
  -- Check if message should be blocked
  for _, prefix in ipairs(blocked_prefixes) do
    if type(msg) == "string" and msg:sub(1, #prefix) == prefix then
      return
    end
  end
  
  -- Use nvim-notify for non-blocked messages
  notify(msg, level, opts)
end
EOF

" Depramanager setup

lua << EOF
local depramanager = require('depramanager')

-- Enable auto-highlighting
depramanager.setup()

-- Optional
-- depramanager.check_all()
-- depramanager.clear_all_highlights()
-- depramanager.refresh_cache()
-- depramanager.status()

-- === KEYBINDS ===
-- Bind telescope functions to keys
vim.keymap.set('n', '<leader>dp', depramanager.python_telescope, { desc = 'Outdated Python packages' })
vim.keymap.set('n', '<leader>dg', depramanager.go_telescope, { desc = 'Outdated Go modules' })
vim.keymap.set('n', '<leader>dn', depramanager.npm_telescope, { desc = 'Outdated npm packages' })
vim.keymap.set('n', '<leader>dph', depramanager.php_telescope, { desc = 'Outdated php packages' })
vim.keymap.set('n', '<leader>dr', depramanager.rust_telescope, { desc = 'Outdated rust packages' })
vim.keymap.set('n', '<leader>dvp', depramanager.python_vulnerabilities_telescope, { desc = 'Outdated Python packages' })
vim.keymap.set('n', '<leader>dvg', depramanager.go_vulnerabilities_telescope, { desc = 'Outdated Go modules' })
vim.keymap.set('n', '<leader>dvn', depramanager.npm_vulnerabilities_telescope, { desc = 'Outdated npm packages' })
vim.keymap.set('n', '<leader>dvph', depramanager.php_vulnerabilities_telescope, { desc = 'Outdated php packages' })
vim.keymap.set('n', '<leader>dvr', depramanager.rust_vulnerabilities_telescope, { desc = 'Outdated rust packages' })
EOF

lua << EOF
-- Metal LSP Configuration for Neovim
local lspconfig = require('lspconfig')
local configs = require('lspconfig.configs')

if not configs.metal_lsp then
  configs.metal_lsp = {
    default_config = {
      cmd = { 'gpumkat', '-lsp' },
      filetypes = { 'metal' },
      root_dir = lspconfig.util.root_pattern('.git', '.gpumkat'),
      settings = {},
      init_options = {
        enable_diagnostics = true,
        enable_completions = true,
        enable_hover = true,
        enable_formatting = true,
        enable_semantic_tokens = true,
        enable_signature_help = true
      }
    },
    docs = {
      description = 'Metal Language Server for GPU shader development'
    }
  }
end

-- Setup the Metal LSP
lspconfig.metal_lsp.setup({
  on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    
    -- Enable semantic tokens if supported
    if client.server_capabilities.semanticTokensProvider then
      vim.lsp.semantic_tokens.start(bufnr, client.id)
    end
    
    -- Mappings
    local opts = { noremap=true, silent=true, buffer=bufnr }
    
    -- Navigation
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  end,
  
  flags = {
    debounce_text_changes = 150,
  },
  
  capabilities = vim.tbl_deep_extend('force', 
    require('cmp_nvim_lsp').default_capabilities(),
    {
      textDocument = {
        semanticTokens = {
          requests = {
            range = false,
            full = {
              delta = false
            }
          },
          tokenTypes = {
            'namespace', 'type', 'class', 'enum', 'interface', 'struct',
            'typeParameter', 'parameter', 'variable', 'property', 'enumMember',
            'event', 'function', 'method', 'macro', 'keyword', 'modifier',
            'comment', 'string', 'number', 'regexp', 'operator'
          },
          tokenModifiers = {
            'declaration', 'definition', 'readonly', 'static', 'deprecated',
            'abstract', 'async', 'modification', 'documentation', 'defaultLibrary'
          }
        }
      }
    }
  )
})

-- Metal file type detection and configuration
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"*.metal"},
  callback = function()
    vim.bo.filetype = "metal"
    vim.bo.commentstring = "// %s"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "metal",
  callback = function(args)
    local bufnr = args.buf
    
    -- Define Metal-specific highlight groups that work with semantic tokens
    local highlights = {
      ["@lsp.type.keyword.metal"] = { link = "Keyword" },
      ["@lsp.type.function.metal"] = { link = "Function" },
      ["@lsp.type.method.metal"] = { link = "Function" },
      ["@lsp.type.type.metal"] = { link = "Type" },
      ["@lsp.type.struct.metal"] = { link = "Structure" },
      ["@lsp.type.variable.metal"] = { link = "Identifier" },
      ["@lsp.type.parameter.metal"] = { link = "Parameter" },
      ["@lsp.type.string.metal"] = { link = "String" },
      ["@lsp.type.number.metal"] = { link = "Number" },
      ["@lsp.type.comment.metal"] = { link = "Comment" },
      ["@lsp.type.operator.metal"] = { link = "Operator" },
      ["@lsp.mod.defaultLibrary.metal"] = { link = "Special" },
      ["@lsp.mod.readonly.metal"] = { link = "Constant" },
    }
    
    for group, opts in pairs(highlights) do
      vim.api.nvim_set_hl(0, group, opts)
    end
    
    -- Fallback to C++ syntax for non-semantic highlighting
    if vim.fn.exists('syntax_on') then
      vim.cmd('syntax clear')
      vim.cmd('runtime! syntax/cpp.vim')
      
      vim.cmd([[
        syntax keyword metalKeyword kernel vertex fragment
        syntax keyword metalKeyword device constant threadgroup thread
        syntax keyword metalKeyword texture1d texture2d texture3d texturecube
        syntax keyword metalKeyword sampler buffer array
        syntax keyword metalType float2 float3 float4 int2 int3 int4
        syntax keyword metalType uint2 uint3 uint4 half2 half3 half4
        syntax keyword metalType float2x2 float3x3 float4x4
        syntax keyword metalBuiltin dot cross normalize length distance
        syntax keyword metalBuiltin pow sin cos tan sqrt abs mix clamp
        syntax keyword metalBuiltin sample read write gather
        
        highlight link metalKeyword Keyword
        highlight link metalType Type  
        highlight link metalBuiltin Function
      ]])
    end
  end,
})

EOF

lua << EOF
-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = {
    prefix = '●',
    source = 'always',
  },
  float = {
    source = 'always',
    border = 'rounded',
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Define diagnostic signs
local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
EOF

lua << EOF
-- GML LSP Configuration for Neovim
local lspconfig = require('lspconfig')
local configs = require('lspconfig.configs')

if not configs.gml_lsp then
  configs.gml_lsp = {
    default_config = {
      -- The command to start your GML language server.
      -- Make sure 'gml_lsp' is in your system's PATH.
      cmd = { 'gml_lsp' },
      -- Filetypes this LSP should attach to.
      filetypes = { 'gml' },
      root_dir = lspconfig.util.root_pattern('.git', '*.yy'),
      settings = {},
      -- Gml lsp server doesn't use init_options, so this can be empty.
      init_options = {}
    },
    docs = {
      description = [[
        GML Language Server for GameMaker Studio 2 development.
        Provides completion, hover, and semantic highlighting.
      ]]
    }
  }
end

lspconfig.gml_lsp.setup({
  on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    
    -- Enable semantic tokens, which your server provides
    if client.server_capabilities.semanticTokensProvider then
      vim.lsp.semantic_tokens.start(bufnr, client.id)
    end
    
    -- Mappings for features SUPPORTED by gml_lsp
    local opts = { noremap=true, silent=true, buffer=bufnr }
    
    -- Show information about the symbol under the cursor (Hover)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    
  end,
  
  flags = {
    debounce_text_changes = 150,
  },
  
  -- Client capabilities, especially for semantic tokens
  capabilities = vim.tbl_deep_extend('force',  
    require('cmp_nvim_lsp').default_capabilities(),
    {
      textDocument = {
        semanticTokens = {
          requests = {
            range = false,
            full = {
              delta = false
            }
          },
          tokenTypes = {
            'namespace', 'type', 'class', 'enum', 'interface', 'struct',
            'typeParameter', 'parameter', 'variable', 'property', 'enumMember',
            'event', 'function', 'method', 'macro', 'keyword', 'modifier',
            'comment', 'string', 'number', 'regexp', 'operator'
          },
          tokenModifiers = {
            'declaration', 'definition', 'readonly', 'static', 'deprecated',
            'abstract', 'async', 'modification', 'documentation', 'defaultLibrary'
          }
        }
      }
    }
  )
})

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"*.gml"},
  callback = function()
    vim.bo.filetype = "gml"
    vim.bo.commentstring = "// %s"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "gml",
  callback = function(args)
    -- Define GML-specific highlight groups that work with your LSP's semantic tokens
    local highlights = {
      ["@lsp.type.keyword"] = { link = "Keyword" },
      ["@lsp.type.function"] = { link = "Function" },
      ["@lsp.type.method"] = { link = "Function" },
      ["@lsp.type.variable"] = { link = "Identifier" },
      ["@lsp.type.property"] = { fg = "#d08770" },
      ["@lsp.type.parameter"] = { link = "Identifier" },
      ["@lsp.type.string"] = { link = "String" },
      ["@lsp.type.number"] = { link = "Number" },
      ["@lsp.type.comment"] = { link = "Comment" },
      ["@lsp.type.operator"] = { link = "Operator" },
      ["@lsp.type.macro"] = { link = "Macro" },
    }
    
    for group, opts in pairs(highlights) do
      vim.api.nvim_set_hl(0, group, opts)
    end
  end,
})

EOF

"" More configs
lua << EOF
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = "*.cu",
    callback = function()
        vim.bo.filetype = "cpp"
    end
})
EOF

lua << EOF
-- LSP mappings

vim.keymap.set("n", "gD", ":lua vim.lsp.buf.declaration()<CR>", { desc = "Go to Declaration" })
vim.keymap.set("n", "gd", ":lua vim.lsp.buf.definition()<CR>", { desc = "Go to Definition" })
vim.keymap.set("n", "gi", ":lua vim.lsp.buf.implementation()<CR>", { desc = "Go to Implementation" })
vim.keymap.set("n", "gr", ":lua vim.lsp.buf.references()<CR>", { desc = "Go to References" })
vim.keymap.set("n", "K", ":lua vim.lsp.buf.hover()<CR>", { desc = "Hover Documentation" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP Rename" })
EOF

lua << EOF
local harpoon = require("harpoon")

harpoon:setup()

vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
 
vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
EOF

set laststatus=0

set undofile

" Set the directory where undo files will be stored
" Create the directory if it doesn't exist
if !isdirectory($HOME."/.local/share/nvim/undo")
    call mkdir($HOME."/.local/share/nvim/undo", "p", 0700)
endif
set undodir=~/.local/share/nvim/undo

" Optional: Set undo levels (default is usually fine)
set undolevels=1000         " How many undos to remember
set undoreload=10000        " Number of lines to save for undo on buffer reload
let g:markdown_fenced_languages = ['html', 'python', 'lua', 'vim', 'typescript', 'javascript']

lua << EOF
-- Store original tmux window name
local original_tmux_name = vim.fn.systemlist("tmux display-message -p '#W'")[1]

-- Update tmux window name
local function update_tmux_name()
  local filename = vim.fn.expand("%:t")
  if filename == "" then
    filename = "[No Name]"
  end

  local modified = vim.bo.modified
  local readonly = vim.bo.readonly

  local status = ""
  if modified then
    status = " [+]"  -- unsaved changes
  elseif readonly then
    status = " [RO]" -- readonly
  end

  -- Escape single quotes to avoid tmux errors
  filename = filename:gsub("'", "'\\''")

  vim.fn.system("tmux rename-window '" .. filename .. status .. "'")
end

-- Restore original tmux window name
local function restore_tmux_name()
  vim.fn.system("tmux rename-window '" .. original_tmux_name .. "'")
end

-- Autocommands
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter", "BufWritePost", "TextChanged", "TextChangedI"}, {
  pattern = "*",
  callback = update_tmux_name
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = restore_tmux_name
})

EOF

lua << EOF
vim.fn.sign_define("ODBreakpointSign", { text = "●", texthl = "ErrorSign" })
vim.fn.sign_define("ODTelescopeItem", {
		text = "▶",
		texthl = "DiagnosticSignWarn",
		numhl = "DiagnosticSignWarn",})
local od = require('od')
od:setup()

-- General OD mappings
vim.keymap.set("n", "<leader>odr", function() od:debug() end, { desc = "Run debugger" })
vim.keymap.set("n", "<leader>ode", function() od:show_errors() end, { desc = "Show errors" })
vim.keymap.set("n", "<leader>odw", function() od:show_warnings() end, { desc = "Show warnings" })
vim.keymap.set("n", "<leader>odo", function() od:show_output() end, { desc = "Show output" })
vim.keymap.set("n", "<leader>oci", function() od:clear_telescope_items() end, { desc = "Clear Telescope Items" })

-- Rust-specific
vim.keymap.set("n", "<leader>orc", function() od:rust_clippy() end, { desc = "Run Rust Clippy" })
vim.keymap.set("n", "<leader>otr", function() od:rust_test() end, { desc = "Run Rust Test" })

-- Go-specific
vim.keymap.set("n", "<leader>ogb", function() od:go_build() end, { desc = "Go Build" })
vim.keymap.set("n", "<leader>ogt", function() od:go_test() end, { desc = "Go Test" })

-- CMake
vim.keymap.set("n", "<leader>occ", function() od:cmake_configure() end, { desc = "CMake Configure" })
vim.keymap.set("n", "<leader>ocb", function() od:cmake_build() end, { desc = "CMake Build" })
vim.keymap.set("n", "<leader>otc", function() od:ctest() end, { desc = "Run CMake Test" })

-- GDB
vim.keymap.set("n", "<leader>ogdb", function() od:gdb_debug() end, { desc = "GDB Debug" })
vim.keymap.set("n", "<leader>ogr", function() od:gdb_remote() end, { desc = "GDB Remote" })

-- Copy breakpoints, watchpoints, tracepoints (You didnt think I would programm a whole dap logic now did you :)
vim.keymap.set("n", "<leader>oab", function() od:copy_breakpoint() end, { desc = "Add breakpoint" })
vim.keymap.set("n", "<leader>orb", function() od:copy_clear_breakpoint() end, { desc = "Remove breakpoint" })
vim.keymap.set("n", "<leader>oca", function() od:clear_breakpoints() end, { desc = "Clears breakpoints, watchpoints, tracepoints" })
vim.keymap.set("n", "<leader>ol", function() od:show_breakpoints_picker() end, { desc = "List brakpoints, watchpoints, tracepoints" })
vim.keymap.set("n", "<leader>oaw", function() od:copy_watchpoint() end, { desc = "Add watchpoint" })
vim.keymap.set("n", "<leader>orw", function() od:copy_clear_watchpoint() end, { desc = "Remove watchpoint" })
vim.keymap.set("n", "<leader>oat", function() od:copy_tracepoint() end, { desc = "Add tracepoint" })
vim.keymap.set("n", "<leader>ort", function() od:copy_clear_tracepoint() end, { desc = "Remove tracepoint" })

-- Test integration for python, javascript/typepescript, lua
vim.keymap.set("n", "<leader>otp", function() od:python_test() end, { desc = "Run Python Test" })
vim.keymap.set("n", "<leader>otj", function() od:js_test() end, { desc = "Run Jest Test" })
vim.keymap.set("n", "<leader>otb", function() od:busted_test() end, { desc = "Run Busted Test" })
EOF

lua << EOF
-- More settings
vim.opt.nu = true
vim.opt.relativenumber = true

vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
  callback = function()
    local col = vim.fn.col(".") -- current cursor column
    if col >= 80 then
      vim.opt.colorcolumn = "80"
    else
      vim.opt.colorcolumn = ""
    end
  end,
})

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.incsearch = true

vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
EOF

lua << EOF
require('refactoring').setup()

vim.keymap.set({ "n", "v" }, "<leader>re", ":Refactor extract<CR>", { desc = "Extract Function" })
vim.keymap.set({ "n", "v" }, "<leader>rf", ":Refactor extract_to_file<CR>", { desc = "Extract Function To File" })
vim.keymap.set({ "n", "v" }, "<leader>rv", ":Refactor extract_var<CR>", { desc = "Extract Variable" })
vim.keymap.set({ "n", "v" }, "<leader>rI", ":Refactor inline_func<CR>", { desc = "Inline Function" })
vim.keymap.set({ "n", "v" }, "<leader>ri", ":Refactor inline_var<CR>", { desc = "Inline Variable" })
vim.keymap.set("n", "<leader>rb", ":Refactor extract_block<CR>", { desc = "Extract Block" })
vim.keymap.set("n", "<leader>rbf", ":Refactor extract_block_to_file<CR>", { desc = "Extract Block To File" })
EOF

lua << EOF
local wk = require("which-key")

wk.setup({
  preset = "modern", 

  -- Delay before which-key popup shows
  delay = 175,

  -- Filter function for keymap entries
  filter = function(mapping)
    return true
  end,

  -- Spec for key mappings (replaces the old operators option)
  spec = {
    { "gc", desc = "Comments", mode = { "n", "v" } },
  },

  -- Key replacements (replaces key_labels)
  replace = {
    ["<space>"] = "SPC",
    ["<cr>"] = "RET",
    ["<tab>"] = "TAB",
  },

  -- Icon settings
  icons = {
    breadcrumb = "»",
    separator = "➜",
    group = "+",
    ellipsis = "…",
    mappings = true,
    rules = false,
    colors = true,
    keys = {
      Up = " ",
      Down = " ",
      Left = " ",
      Right = " ",
      C = "󰘴 ",
      M = "󰘵 ",
      D = "󰘳 ",
      S = "󰘶 ",
      CR = "󰌑 ",
      Esc = "󱊷 ",
      ScrollWheelDown = "󱕐 ",
      ScrollWheelUp = "󱕑 ",
      NL = "󰌑 ",
      BS = "󰁮",
      Space = "󱁐 ",
      Tab = "󰌒 ",
      F1 = "󱊫",
      F2 = "󱊬",
      F3 = "󱊭",
      F4 = "󱊮",
      F5 = "󱊯",
      F6 = "󱊰",
      F7 = "󱊱",
      F8 = "󱊲",
      F9 = "󱊳",
      F10 = "󱊴",
      F11 = "󱊵",
      F12 = "󱊶",
    },
  },

  win = {
    relative = "editor",
    anchor = "SW",  -- Adjust anchor to bottom-left for shifting slightly up and left
    row = vim.o.lines - 50, 
    col = vim.o.columns - 20, 
    width = math.floor(vim.o.columns / 6),
    height = math.floor(vim.o.lines / 3),
    border = "single",
    padding = { 0, 2 },
    title = false,
    title_pos = "center",
    zindex = 1000,

    -- Background and transparency for clean look
    wo = {
      winblend = 10,
    },
  },

  -- Layout configuration
  layout = {
    width = { min = 20, max = 50 },
    height = { min = 4, max = 25 },
    spacing = 3,
    align = "left",
  },

  keys = {
    scroll_down = "<c-d>",
    scroll_up = "<c-u>",
  },

  -- Disable certain triggers in specific modes (replaces triggers_blacklist)
  triggers = {
    { "<auto>", mode = "nixsotc" },
    { "a", mode = { "i", "n", "s" } },
    { "i", mode = { "n", "s" } },
    { "I", mode = { "n", "s" } },
    { "v", mode = { "n", "s" } },
    { "V", mode = { "n", "s" } },
    { "d", mode = { "n", "s" } },
    { "y", mode = { "n", "s" } },
    { "c", mode = { "n", "s" } },
    { "r", mode = { "n", "s" } },
    { "s", mode = { "n", "s" } },
    { "S", mode = { "n", "s" } },
    { "z", mode = { "n", "s" } },
    { "g", mode = { "n", "s" } },
    { "<c-w>", mode = { "n", "s" } },
    { "\"", mode = { "n", "s" } },
    { "'", mode = { "n", "s" } },
    { "`", mode = { "n", "s" } },
    { "<c-r>", mode = "i" },
    { "<c-w>", mode = "c" },
  },

  -- Sorting and presentation
  sort = { "local", "order", "group", "alphanum", "mod" },
  expand = 0,

  -- Show help and keys
  show_help = true,
  show_keys = true,
})

wk.add({
  -- Groups
  { "<leader>r", group = "Refactoring" },
  { "<leader>d", group = "Dependencies" },
  { "<leader>dv", group = "Vulnerabilities" },
  { "<leader>o", group = "Debugger & Tools" },
  { "<leader>od", group = "Debug" },
  { "<leader>or", group = "Remove/Clippy" },
  { "<leader>og", group = "Go/GDB" },
  { "<leader>oc", group = "CMake/Clear Items" },
  { "<leader>oa", group = "Add" },
  { "<leader>ot", group = "Tests" },
  { "ys", group = "Surround (add)" },
  { "yss", desc = "Surround entire line" },
  { "ysiw", group = "Surround word" },
  { "yS", desc = "Surround with linewise motion" },
  { "cs", group = "Change Surround" },
  { "ds", group = "Delete Surround" },
})

_G.setup_lsp_which_key = setup_lsp_which_key
EOF
