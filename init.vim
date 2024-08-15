call plug#begin('~/.local/share/nvim/plugged')
Plug 'Exafunction/codeium.vim', { 'branch': 'main' }
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}
Plug 'ms-jpq/coq.thirdparty', {'branch': '3p'}
Plug 'jiangmiao/auto-pairs'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'lewis6991/gitsigns.nvim'
Plug 'romgrk/barbar.nvim'
Plug 'dense-analysis/ale'
Plug 'preservim/nerdtree'
Plug 'mfussenegger/nvim-dap'
Plug 'nvim-neotest/nvim-nio'
Plug 'rcarriga/nvim-dap-ui'
Plug 'mfussenegger/nvim-dap-python'
Plug 'tpope/vim-fugitive'
Plug 'kkvh/vim-docker-tools'
Plug 'tibabit/vim-templates'
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install --frozen-lockfile --production',
  \ 'branch': 'release/0.x'
  \ }
Plug 'rebelot/kanagawa.nvim'
Plug 'nvim-orgmode/orgmode'
Plug 'projekt0n/github-nvim-theme'
Plug 'cormacrelf/dark-notify'

call plug#end()
let g:coq_settings ={'auto_start': 'shut-up'}
let g:ale_completion_enabled = 1
let mapleader = ","
let g:codeium_disable_bindings = 1

set clipboard=unnamedplus
set number
colorscheme github_light

noremap <C-s> :Telescope find_files<CR>
noremap <C-b> :NERDTreeToggle<CR>
noremap <leader>t :terminal<CR>
noremap <leader>[ :tab new<CR>
nnoremap <silent> <leader>gg :LazyGit<CR>

imap <script><silent><nowait><expr> <C-g> codeium#Accept()
imap <C-;>   <Cmd>call codeium#CycleCompletions(1)<CR>
imap <C-,>   <Cmd>call codeium#CycleCompletions(-1)<CR>
imap <C-x>   <Cmd>call codeium#Clear()<CR>
imap <C-l>   <Cmd>call codeium#Chat()<CR>

let g:auto_pairs_map = {'(': ')', '[': ']', '{': '}', '"': '"', "'": "'"}
lua << END
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
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
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}

END

lua << EOF

require('orgmode').setup({
  org_agenda_files = {'~/Dropbox/org/*', '~/my-orgs/**/*'},
  org_default_notes_file = '~/Dropbox/org/refile.org',
})


EOF

lua << EOD
local dn = require('dark_notify')

-- Configure
dn.run({
    schemes = {
      dark  = {
	colorscheme = "github_dark",
	      },
      light = {
        colorscheme = "github_light",
      }
    }
})


dn.run()

EOD
