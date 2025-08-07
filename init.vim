call plug#begin('~/.local/share/nvim/plugged')

Plug 'jiangmiao/auto-pairs'
Plug 'lewis6991/gitsigns.nvim'
Plug 'tpope/vim-fugitive'
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
Plug 'tibabit/vim-templates'
Plug 'nvim-orgmode/orgmode'
Plug 'projekt0n/github-nvim-theme'
Plug 'cormacrelf/dark-notify'
Plug 'jbyuki/instant.nvim'
Plug 'chipsenkbeil/distant.nvim', { 'branch': 'v0.3' }
Plug 'stevearc/conform.nvim'
Plug 'lervag/vimtex'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'goerz/jupytext.nvim'
Plug 'jiaoshijie/undotree'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'rcarriga/nvim-notify'
Plug 'simrat39/symbols-outline.nvim'
Plug 'github/copilot.vim'
Plug 'CopilotC-Nvim/CopilotChat.nvim', { 'branch': 'canary' }
Plug 'jcha0713/cmp-tw2css'
Plug 'David-Kunz/cmp-npm'
Plug 'saecki/crates.nvim', { 'tag': 'stable' }
Plug 'hat0uma/csvview.nvim'
Plug 'brianhuster/live-preview.nvim'
Plug 'Okerew/depramanager-nvim'

call plug#end()

" === SETTINGS ===
let mapleader = " "             " Use space as leader (I prefer space, changed from comma for consistency)
set clipboard=unnamedplus      " Use system clipboard
set number                    " Show line numbers
colorscheme github_light      " Default colorscheme
:setlocal spell
:setlocal spelllang=en_us
autocmd BufReadPost,BufNewFile * Copilot disable

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
noremap <leader>u :lua require('undotree').toggle()<CR>
noremap <leader>l :Telescope live_grep<CR>
noremap <leader>o :SymbolsOutline<CR>
noremap <leader>p :LivePreview start<CR>

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

lua require('crates').setup()
lua require('cmp-npm').setup({})

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
    { name = "buffer", priority = 400, keyword_length = 3 },
    { name = "cmp-tw2css" },
    { name = "npm" },
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
  timeout = 500,
  
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

local blocked_prefixes = {
  "config.mappings.show_system_prompt",
  "config.mappings.show_user_selection",
  "'canary' branch is deprecated",
}

vim.notify = function(msg, level, opts)
  for _, prefix in ipairs(blocked_prefixes) do
    if msg:sub(1, #prefix) == prefix then
      return
    end
  end
  vim.schedule(function()
    vim.api.nvim_echo({{msg}}, true, {})
  end)
end

EOF

lua << EOF
local opts = {
  highlight_hovered_item = true,
  show_guides = true,
  auto_preview = false,
  position = 'right',
  relative_width = true,
  width = 25,
  auto_close = false,
  show_numbers = false,
  show_relative_numbers = false,
  show_symbol_details = true,
  preview_bg_highlight = 'Pmenu',
  autofold_depth = nil,
  auto_unfold_hover = true,
  fold_markers = { '', '' },
  wrap = false,
  keymaps = { -- These keymaps can be a string or a table for multiple keys
    close = {"<Esc>", "q"},
    goto_location = "<Cr>",
    focus_location = "o",
    hover_symbol = "<C-space>",
    toggle_preview = "K",
    rename_symbol = "r",
    code_actions = "a",
    fold = "h",
    unfold = "l",
    fold_all = "W",
    unfold_all = "E",
    fold_reset = "R",
  },
  lsp_blacklist = {},
  symbol_blacklist = {},
  symbols = {
    File = { icon = "", hl = "@text.uri" },
    Module = { icon = "", hl = "@namespace" },
    Namespace = { icon = "", hl = "@namespace" },
    Package = { icon = "", hl = "@namespace" },
    Class = { icon = "𝓒", hl = "@type" },
    Method = { icon = "ƒ", hl = "@method" },
    Property = { icon = "", hl = "@method" },
    Field = { icon = "", hl = "@field" },
    Constructor = { icon = "", hl = "@constructor" },
    Enum = { icon = "ℰ", hl = "@type" },
    Interface = { icon = "ﰮ", hl = "@type" },
    Function = { icon = "", hl = "@function" },
    Variable = { icon = "", hl = "@constant" },
    Constant = { icon = "", hl = "@constant" },
    String = { icon = "𝓐", hl = "@string" },
    Number = { icon = "#", hl = "@number" },
    Boolean = { icon = "⊨", hl = "@boolean" },
    Array = { icon = "", hl = "@constant" },
    Object = { icon = "⦿", hl = "@type" },
    Key = { icon = "🔐", hl = "@type" },
    Null = { icon = "NULL", hl = "@type" },
    EnumMember = { icon = "", hl = "@field" },
    Struct = { icon = "𝓢", hl = "@type" },
    Event = { icon = "🗲", hl = "@type" },
    Operator = { icon = "+", hl = "@operator" },
    TypeParameter = { icon = "𝙏", hl = "@parameter" },
    Component = { icon = "", hl = "@function" },
    Fragment = { icon = "", hl = "@constant" },
  },
}
require("symbols-outline").setup(opts)
EOF

nnoremap <leader>cce :CopilotChatExplain<CR>
nnoremap <leader>ccr :CopilotChatReview<CR>
nnoremap <leader>ccf :CopilotChatFix<CR>
nnoremap <leader>cco :CopilotChatOptimize<CR>
nnoremap <leader>ccd :CopilotChatDocs<CR>
nnoremap <leader>cct :CopilotChatTests<CR>
nnoremap <leader>ccq :CopilotChatClose<CR>
vnoremap <leader>cc :CopilotChatVisual<CR>
vnoremap <leader>cce :CopilotChatExplain<CR>
command! -nargs=* Cc CopilotChat <args> 

" Add this Lua configuration block after your other Lua configs
lua << EOF
require("CopilotChat").setup {
  debug = false, -- Enable debugging
  
  -- See Configuration section for rest
  model = 'gpt-4', -- GPT model to use, 'gpt-3.5-turbo' or 'gpt-4'
  
  -- System prompts
  system_prompt = "You are a helpful AI assistant. You explain code, suggest improvements, and help with programming tasks.",
  
  -- Chat window configuration
  window = {
    layout = 'vertical', -- 'vertical', 'horizontal', 'float', 'replace'
    width = 0.5, -- fractional width of parent, or absolute width in columns when > 1
    height = 0.5, -- fractional height of parent, or absolute height in rows when > 1
    -- Options below only apply to floating windows
    relative = 'editor', -- 'editor', 'win', 'cursor', 'mouse'
    border = 'single', -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
    row = nil, -- row position of the window, default is centered
    col = nil, -- column position of the window, default is centered
    title = 'Copilot Chat', -- title of chat window
    footer = nil, -- footer of chat window
    zindex = 1, -- determines if window is on top or below other floating windows
  },

  -- Chat configuration
  chat = {
    welcome_message = "Hello! I'm your AI coding assistant. How can I help you today?",
    loading_text = "Loading, please wait ...",
    question_sign = "", -- 🙂
    answer_sign = "ﮧ", -- 🤖
    border_follow_highlight = true, -- follow color of border
    error_header = "Error: ",
    separator = " ", -- separator to use in chat
    show_folds = true, -- Shows folds for sections in chat
    show_help = true, -- Shows help message as virtual lines when waiting for user input
    auto_follow_cursor = true, -- Auto-follow cursor in chat
    auto_insert_mode = false, -- Automatically enter insert mode when opening window and if auto follow cursor is enabled on new prompt
    insert_at_end = false, -- Move cursor to end of buffer when inserting text
    clear_chat_on_new_prompt = false, -- Clears chat on every new prompt
    highlight_selection = true, -- Highlight selection in the source buffer when in the chat window
  },

  -- Context configuration
  context = 'buffer', -- Default context to use, 'buffers', 'buffer' or none (can be specified manually in prompt via @).
  history_path = vim.fn.stdpath('data') .. '/copilotchat_history', -- Default path to stored history
  callback = nil, -- Callback to use when ask response is received

  -- default selection (visual or line)
  selection = function(source)
    return require("CopilotChat.select").visual(source) or require("CopilotChat.select").line(source)
  end,

  -- default prompts
  prompts = {
    Explain = {
      prompt = '/COPILOT_EXPLAIN Write an explanation for the active selection as paragraphs of text.',
    },
    Review = {
      prompt = '/COPILOT_REVIEW Review the selected code.',
      callback = function(response, source)
        -- see config.lua for implementation
      end,
    },
    Fix = {
      prompt = '/COPILOT_GENERATE There is a problem in this code. Rewrite the code to show it with the bug fixed.',
    },
    Optimize = {
      prompt = '/COPILOT_GENERATE Optimize the selected code to improve performance and readablilty.',
    },
    Docs = {
      prompt = '/COPILOT_GENERATE Please add documentation comment for the selection.',
    },
    Tests = {
      prompt = '/COPILOT_GENERATE Please generate tests for my code.',
    },
    FixDiagnostic = {
      prompt = 'Please assist with the following diagnostic issue in file:',
      selection = require('CopilotChat.select').diagnostics,
    },
    Commit = {
      prompt = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
      selection = require('CopilotChat.select').gitdiff,
    },
    CommitStaged = {
      prompt = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
      selection = function(source)
        return require('CopilotChat.select').gitdiff(source, true)
      end,
    },
  },

  -- default mappings
  mappings = {
    complete = {
      detail = 'Use @<Tab> or /<Tab> for options.',
      insert ='<Tab>',
    },
    close = {
      normal = 'q',
      insert = '<C-c>'
    },
    reset = {
      normal ='<C-l>',
      insert = '<C-l>'
    },
    submit_prompt = {
      normal = '<CR>',
      insert = '<C-s>'
    },
    accept_diff = {
      normal = '<C-y>',
      insert = '<C-y>'
    },
    show_diff = {
      normal = 'gd'
    },
    show_system_prompt = {
      normal = 'gp'
    },
    show_user_selection = {
      normal = 'gs'
    },
  },
}
EOF

lua require('csvview').setup()

" Depramanager setup

lua << EOF
local depramanager = require('depramanager')

-- Enable auto-highlighting
depramanager.setup()

-- Bind telescope functions to keys
vim.keymap.set('n', '<leader>dp', depramanager.python_telescope, { desc = 'Outdated Python packages' })
vim.keymap.set('n', '<leader>dg', depramanager.go_telescope, { desc = 'Outdated Go modules' })
vim.keymap.set('n', '<leader>dn', depramanager.npm_telescope, { desc = 'Outdated npm packages' })
vim.keymap.set('n', '<leader>dvp', depramanager.python_vulnerabilities_telescope, { desc = 'Outdated Python packages' })
vim.keymap.set('n', '<leader>dvg', depramanager.go_vulnerabilities_telescope, { desc = 'Outdated Go modules' })
vim.keymap.set('n', '<leader>dvn', depramanager.npm_vulnerabilities_telescope, { desc = 'Outdated npm packages' })
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
    
    -- Code actions
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format({ async = true })
    end, opts)
    
    -- Diagnostics
    vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
  end,
  
  flags = {
    debounce_text_changes = 150,
  },
  
  -- Enhanced capabilities
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

-- Setup nvim-cmp for autocompletion
local cmp_status, cmp = pcall(require, 'cmp')
if cmp_status then
  cmp.setup({
    sources = cmp.config.sources({
      { name = 'nvim_lsp', priority = 1000 },
      { name = 'buffer', priority = 500 },
      { name = 'path', priority = 250 }
    }),
    formatting = {
      format = function(entry, vim_item)
        vim_item.menu = ({
          nvim_lsp = "[LSP]",
          buffer = "[Buffer]",
          path = "[Path]"
        })[entry.source.name]
        return vim_item
      end
    },
    experimental = {
      ghost_text = true,
    }
  })
end

-- Metal file type detection and configuration
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"*.metal"},
  callback = function()
    vim.bo.filetype = "metal"
    vim.bo.commentstring = "// %s"
    vim.bo.expandtab = true
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
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

-- Auto-format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.metal",
  callback = function()
      vim.lsp.buf.format({ async = false })
  end,
})

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
          -- These types and modifiers match what your Go server provides.
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
    vim.bo.expandtab = true
    vim.bo.shiftwidth = 4 -- Common for GML
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
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

-- Setup nvim-cmp for autocompletion
local cmp_status, cmp = pcall(require, 'cmp')
if cmp_status then
  cmp.setup({
    sources = cmp.config.sources({
      { name = 'nvim_lsp', priority = 1000 },
      { name = 'buffer', priority = 500 },
      { name = 'path', priority = 250 }
    }),
    experimental = {
      ghost_text = true,
    }
  })
end
EOF
