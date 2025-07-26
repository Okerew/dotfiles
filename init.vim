call plug#begin('~/.local/share/nvim/plugged')

Plug 'jiangmiao/auto-pairs'
Plug 'lewis6991/gitsigns.nvim'
Plug 'tpope/vim-fugitive'
Plug 'phaazon/hop.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-lualine/lualine.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/nvim-cmp'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'romgrk/barbar.nvim'
Plug 'dense-analysis/ale'
Plug 'kkvh/vim-docker-tools'
Plug 'tibabit/vim-templates'
Plug 'nvim-orgmode/orgmode'
Plug 'projekt0n/github-nvim-theme'
Plug 'cormacrelf/dark-notify'
Plug 'jbyuki/instant.nvim'
Plug 'chipsenkbeil/distant.nvim', { 'branch': 'v0.3' }
Plug 'stevearc/conform.nvim'
Plug 'lervag/vimtex'
Plug 'olimorris/codecompanion.nvim'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'goerz/jupytext.nvim'
Plug 'jiaoshijie/undotree'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'rcarriga/nvim-notify'
Plug 'MunifTanjim/nui.nvim'
Plug 'kndndrj/nvim-dbee'

call plug#end()

" === SETTINGS ===
let mapleader = " "             " Use space as leader (I prefer space, changed from comma for consistency)
set clipboard=unnamedplus      " Use system clipboard
set number                    " Show line numbers
colorscheme github_light      " Default colorscheme
:setlocal spell
:setlocal spelllang=en_us

" === KEYMAPS ===
" Buffer navigation
nnoremap gt :bnext<CR>
nnoremap gT :bprev<CR>

" Disable 'Q' in normal mode (usually ex mode, to avoid mistakes)
nnoremap Q <nop>

" Move selected lines up/down in visual mode
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

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

" Location list navigation centered
nnoremap <leader>k :lnext<CR>zz
nnoremap <leader>j :lprev<CR>zz

" Substitute word under cursor globally and ignore case
nnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>

" Delete without yank (blackhole)
nnoremap <leader>d "_d
vnoremap <leader>d "_d

" Surround text with '=' (for example)
nnoremap =ap ma=ap'a

" Paste over visual selection without yanking replaced text
xnoremap <leader>p "_dP

" Shortcuts
noremap <leader>f :Telescope find_files<CR>
noremap <leader>t :NvimTreeOpen<CR>
noremap <leader>[ :tab new<CR>
noremap <leader>] :bd<CR>
nnoremap <leader>m :CodeCompanion<CR>
noremap <leader>u :lua require('undotree').toggle()<CR>
noremap <leader>tl :Telescope live_grep<CR>
noremap <leader>db :lua require("dbee").toggle()<CR>
noremap <leader>dbc :lua require("dbee").store("query", "default", vim.api.nvim_buf_get_lines(0, 0, -1, false))<CR>

" Command alias for Gitsigns
command! -nargs=* Gits Gitsigns <args>
command! -nargs=* Ha HopAnywhere <args> 

let g:auto_pairs_map = {'(': ')', '[': ']', '{': '}', '"': '"', "'": "'"}

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

" Hop.nvim setup
lua << EOF
require('hop').setup()
EOF

" Lualine setup
lua << EOF
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_c = {'filename'},
    lualine_x = {'location'},
  },
}
EOF

" Orgmode setup
lua << EOF
require('orgmode').setup({
  org_agenda_files = {'~/Dropbox/org/*', '~/my-orgs/**/*'},
  org_default_notes_file = '~/Dropbox/org/refile.org',
})
EOF

" Dark Notify setup
lua << EOF
local dn = require('dark_notify')

dn.run({
  schemes = {
    dark = {
      colorscheme = "github_dark",
    },
    light = {
      colorscheme = "github_light",
    }
  }
})

dn.run()
EOF

lua << EOF
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.metal",
  callback = function()
    vim.bo.filetype = "cpp"
  end,
})
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


lua << EOF
require("distant"):setup()
EOF

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


lua <<EOF
local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      -- Neovim 0.10+ built-in snippet expansion
      vim.snippet.expand(args.body)
    end,
  },

  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    -- Add Tab and Shift-Tab for better navigation
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
  }),

  sources = cmp.config.sources({
    { name = "nvim_lsp", priority = 1000 },
    { name = "nvim_lsp_signature_help", priority = 800 },
    { name = "path", priority = 600 },  
  }, {
    { name = "buffer", priority = 400, keyword_length = 3 },
  }),

  -- Performance settings
  performance = {
    debounce = 60,
    throttle = 30,
    fetching_timeout = 500,
    confirm_resolve_timeout = 80,
    async_budget = 1,
    max_view_entries = 200,
  },
})

-- Set configuration for specific filetypes where path completion is especially useful
cmp.setup.filetype({ "gitcommit", "markdown" }, {
  sources = cmp.config.sources({
    { name = "path", priority = 800 },
    { name = "buffer", priority = 600 },
  })
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

lua << EOF
require("codecompanion").setup({
  strategies = {
    chat = {
      adapter = 'qwen',
    },
    inline = {
      adapter = 'qwen',
    },
  },
  adapters = {
    qwen = function()
      return require('codecompanion.adapters').extend('ollama', {
        name = 'qwen',
        schema = {
          model = {
            default = 'qwen2.5-coder:7b',
          },
        },
      })
    end,
  },
  opts = {
    log_level = 'DEBUG',
  },
  display = {
    diff = {
      enabled = true,
      close_chat_at = 240,
      layout = 'vertical',
      opts = { 'internal', 'filler', 'closeoff', 'algorithm:patience', 'followwrap', 'linematch:120' },
      provider = 'default',
    },
  },
})
EOF

lua << EOF
require("nvim-tree").setup()
EOF

lua << EOF
opts = {
  jupytext = 'jupytext',
  format = "markdown",
  update = true,
  filetype = require("jupytext").get_filetype,
  new_template = require("jupytext").default_new_template(),
  sync_patterns = { '*.md', '*.py', '*.jl', '*.R', '*.Rmd', '*.qmd' },
  autosync = true,
  handle_url_schemes = true,
}
require("jupytext").setup(opts)
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
require('orgmode').setup({
  org_agenda_files = '~/orgfiles/**/*',
  org_default_notes_file = '~/orgfiles/refile.org',
})
EOF

lua << EOF
-- nvim-notify setup
require("notify").setup({
  -- Animation style (see below for options)
  stages = "fade_in_slide_out",
  
  -- Function called when a new window is opened, use for changing win settings/config
  on_open = nil,
  
  -- Function called when a window is closed
  on_close = nil,
  
  -- Render function for notifications. See notify-render()
  render = "default",
  
  -- Default timeout for notifications
  timeout = 5000,
  
  -- For stages that change opacity this is treated as the highlight behind the window
  -- Set this to either a highlight group, an RGB hex value e.g. "#000000" or a function returning an RGB code for dynamic values
  background_colour = "Normal",
  
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

-- Set nvim-notify as the default notification handler
vim.notify = require("notify")
EOF

noremap <leader>db :lua require("dbee").toggle()<CR>
noremap <leader>dbc :lua require("dbee").store("query", "default", vim.api.nvim_buf_get_lines(0, 0, -1, false))<CR>
noremap <leader>dba :lua _G.add_postgres_connection()<CR>

lua << EOF
-- Simple function to add PostgreSQL connection
function _G.add_postgres_connection()
  local function get_input(prompt, default, secret)
    if secret then
      vim.fn.inputsave()
      local result = vim.fn.inputsecret(prompt .. ": ")
      vim.fn.inputrestore()
      return result
    else
      local result = vim.fn.input(prompt .. (default and " [" .. default .. "]: " or ": "))
      return result ~= "" and result or default
    end
  end

  -- Get connection details
  local name = get_input("Connection name", "postgres_local")
  if name == "" then
    vim.notify("Connection name is required", vim.log.levels.ERROR)
    return
  end

  local host = get_input("Host", "localhost")
  local port = get_input("Port", "5432")
  local database = get_input("Database name")
  if database == "" then
    vim.notify("Database name is required", vim.log.levels.ERROR)
    return
  end

  local username = get_input("Username")
  if username == "" then
    vim.notify("Username is required", vim.log.levels.ERROR)
    return
  end

  local password = get_input("Password", nil, true)
  if password == "" then
    vim.notify("Password is required", vim.log.levels.ERROR)
    return
  end

  -- Create connection URL
  local connection_url = string.format("postgresql://%s:%s@%s:%s/%s", username, password, host, port, database)
  
  -- Set environment variable that dbee can read
  vim.env.DBEE_CONNECTIONS = vim.json.encode({{
    id = name,
    name = name,
    type = "postgres",
    url = connection_url
  }})
  
  vim.notify("Connection '" .. name .. "' created!", vim.log.levels.INFO)
  vim.notify("Use <leader>db to open dbee", vim.log.levels.INFO)
end

-- Very minimal dbee setup - let it use defaults
local ok, dbee = pcall(require, "dbee")
if ok then
  -- Try the most basic setup possible
  pcall(function()
    dbee.setup({
      sources = {},  -- Start with empty sources to avoid registration errors
    })
  end)
else
  vim.notify("DBee plugin not found. Run :PlugInstall", vim.log.levels.WARN)
end

-- Simple commands
vim.api.nvim_create_user_command('DBConnect', function()
  local ok, dbee = pcall(require, "dbee")
  if ok then
    dbee.toggle()
  else
    vim.notify("DBee plugin not available", vim.log.levels.ERROR)
  end
end, { desc = "Toggle DBee interface" })

vim.api.nvim_create_user_command('DBAddPostgres', function()
  _G.add_postgres_connection()
end, { desc = "Add PostgreSQL connection" })

-- Alternative manual connection method
vim.api.nvim_create_user_command('DBConnectManual', function(opts)
  if opts.args == "" then
    local url = vim.fn.input("PostgreSQL URL (postgresql://user:pass@host:port/db): ")
    if url ~= "" then
      vim.env.DBEE_CONNECTIONS = vim.json.encode({{
        id = "manual",
        name = "manual",
        type = "postgres", 
        url = url
      }})
      vim.notify("Manual connection set. Use :DBConnect", vim.log.levels.INFO)
    end
  end
end, { nargs = '*', desc = "Set manual connection" })
EOF
