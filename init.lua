--[[
=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================
--]]

-- ============================================================
-- SECTION 1: OPTIONS
-- Core Neovim settings, leaders, options
-- ============================================================
do
  vim.loader.enable()

  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '
  vim.g.have_nerd_font = false

  vim.o.number = true
  vim.o.mouse = 'a'
  vim.o.showmode = false

  -- SCHEDULED CLIPBOARD FIX: Defers Windows clipboard checking to drop load times
  vim.schedule(function()
    vim.o.clipboard = 'unnamedplus'
  end)

  vim.o.breakindent = true
  vim.o.undofile = true
  vim.o.ignorecase = true
  vim.o.smartcase = true
  vim.o.signcolumn = 'yes'
  vim.o.updatetime = 250
  vim.o.timeoutlen = 300
  vim.o.splitright = true
  vim.o.splitbelow = true
  vim.o.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
  vim.o.inccommand = 'split'
  vim.o.cursorline = true
  vim.o.scrolloff = 10
  vim.o.confirm = true
end

-- ============================================================
-- SECTION 2: KEYMAPS & AUTOCMDS
-- basic keymaps, basic autocmds
-- ============================================================
do
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

  vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },
    virtual_text = true,
    virtual_lines = false,
    jump = {
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float {
          bufnr = bufnr,
          scope = 'cursor',
          focus = false,
        }
      end,
    },
  }

  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
  vim.keymap.set('x', 's', 'c', { noremap = true, silent = true, desc = 'Change selection' })
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

  vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
  vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
  vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
  vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

  vim.keymap.set("i", "<C-h>", "<Left>", { desc = "Move left" }, { noremap = true, silent = true })
  vim.keymap.set("i", "<C-j>", "<Down>", { desc = "Move down" }, { noremap = true, silent = true })
  vim.keymap.set("i", "<C-k>", "<Up>", { desc = "Move up" }, { noremap = true, silent = true })
  vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Move right" }, { noremap = true, silent = true })

  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
  })
end

-- ============================================================
-- SECTION 3: PLUGIN MANAGER INTRO
-- lazy.nvim bootstrap
-- ============================================================
-- We declare a master 'plugins' table. Every section below will insert into this table.
local plugins = {}
do
  local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
    if vim.v.shell_error ~= 0 then
      error('Error cloning lazy.nvim:\n' .. out)
    end
  end
  vim.opt.rtp:prepend(lazypath)
end

-- ============================================================
-- SECTION 4: UI / CORE UX PLUGINS
-- guess-indent, gitsigns, which-key, colorscheme, todo-comments, mini modules
-- ============================================================
do
  table.insert(plugins, {
    'NMAC427/guess-indent.nvim',
    config = function()
      require('guess-indent').setup {}
    end,
  })

  table.insert(plugins, {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local gitsigns = require 'gitsigns'
      gitsigns.setup {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        on_attach = function(bufnr)
          vim.keymap.set('n', ']c', function()
            if vim.wo.diff then vim.cmd.normal { ']c', bang = true } else gitsigns.nav_hunk 'next' end
          end, { desc = 'Jump to next git [c]hange', buf = bufnr })
          vim.keymap.set('n', '[c', function()
            if vim.wo.diff then vim.cmd.normal { '[c', bang = true } else gitsigns.nav_hunk 'prev' end
          end, { desc = 'Jump to previous git [c]hange', buf = bufnr })
          -- Actions
          vim.keymap.set('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git [s]tage hunk', buf = bufnr })
          vim.keymap.set('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git [r]eset hunk', buf = bufnr })
          vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk', buf = bufnr })
          vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk', buf = bufnr })
          vim.keymap.set('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer', buf = bufnr })
          vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer', buf = bufnr })
          vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk', buf = bufnr })
          vim.keymap.set('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = 'git preview hunk [i]nline', buf = bufnr })
          vim.keymap.set('n', '<leader>hb', function() gitsigns.blame_line { full = true } end, { desc = 'git [b]lame line', buf = bufnr })
          vim.keymap.set('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index', buf = bufnr })
          vim.keymap.set('n', '<leader>hD', function() gitsigns.diffthis '~' end, { desc = 'git [D]iff against last commit', buf = bufnr })
          vim.keymap.set('n', '<leader>hQ', function() gitsigns.setqflist 'all' end, { desc = 'git hunk [Q]uickfix list (all files in repo)', buf = bufnr })
          vim.keymap.set('n', '<leader>hq', gitsigns.setqflist, { desc = 'git hunk [q]uickfix list (all changes in this file)', buf = bufnr })
          vim.keymap.set('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line', buf = bufnr })
          vim.keymap.set('n', '<leader>tw', gitsigns.toggle_word_diff, { desc = '[T]oggle git intra-line [w]ord diff', buf = bufnr })
          vim.keymap.set({ 'o', 'x' }, 'ih', gitsigns.select_hunk, { desc = 'text object [i]nside [h]unk', buf = bufnr })
        end,
      }
    end,
  })

  table.insert(plugins, {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
      require('which-key').setup {
        delay = 0,
        icons = { mappings = vim.g.have_nerd_font },
        spec = {
          { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
          { '<leader>t', group = '[T]oggle' },
          { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
          { 'gr', group = 'LSP Actions', mode = { 'n' } },
        },
      }
    end,
  })

  table.insert(plugins, {
    'folke/tokyonight.nvim',
    lazy = false, -- Make sure theme loads immediately to avoid flashing
    priority = 1000,
    config = function()
      require('tokyonight').setup {
        styles = { comments = { italic = false } },
      }
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  })

  table.insert(plugins, {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  })

  table.insert(plugins, {
    'nvim-mini/mini.nvim',
    config = function()
      if vim.g.have_nerd_font then
        require('mini.icons').setup()
        MiniIcons.mock_nvim_web_devicons()
      end
      require('mini.ai').setup { mappings = { around_next = 'aa', inside_next = 'ii' }, n_lines = 500 }
      require('mini.pairs').setup()
      require('mini.surround').setup({
        mappings = { add = 'gza', delete = 'gzd', find = 'gzf', find_left = 'gzF', highlight = 'gzh', replace = 'gzr', update_n_lines = 'gzn' },
      })
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      statusline.section_location = function() return '%2l:%-2v' end
      require('mini.bufremove').setup()
    end,
  })

  table.insert(plugins, {
    'akinsho/toggleterm.nvim',
    keys = { { '<M-h>', '<cmd>ToggleTerm direction=horizontal<cr>', desc = 'Toggle Terminal' } },
    config = function()
      require('toggleterm').setup {
        open_mapping = [[<M-h>]],
        direction = 'horizontal',
      }
    end,
  })
  
  table.insert(plugins, {
    'akinsho/bufferline.nvim',
    event = 'VimEnter',
    config = function()
      require('bufferline').setup {}
      require('bufferline').sort_by('extension')
      vim.keymap.set('n', '<S-q>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev Buffer' })
      vim.keymap.set('n', '<S-t>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next Buffer' })
      vim.keymap.set('n', '<leader>x', '<cmd>lua MiniBufremove.delete()<cr>', { desc = 'Delete Buffer' })
    end,
  })
end

-- ============================================================
-- SECTION 5: SEARCH & NAVIGATION
-- Telescope setup, keymaps, LSP picker mappings
-- ============================================================
do
  table.insert(plugins, {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function() return vim.fn.executable 'make' == 1 end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
    },
    config = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = { require('telescope.themes').get_dropdown() },
        },
      }
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
      end, { desc = '[S]earch [/] in Open Files' })

      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  })
end

-- ============================================================
-- SECTION 6: LSP
-- LSP keymaps, server configuration, Mason tools installations
-- ============================================================
do
  table.insert(plugins, {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' }, -- Lazy-loading: Keeps startup fast, loads LSP only when a file opens
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          
          -- Telescope integrations
          local builtin = require('telescope.builtin')
          map('grr', builtin.lsp_references, '[G]oto [R]eferences')
          map('gri', builtin.lsp_implementations, '[G]oto [I]mplementation')
          map('grd', builtin.lsp_definitions, '[G]oto [D]efinition')
          map('gO', builtin.lsp_document_symbols, 'Open Document Symbols')
          map('gW', builtin.lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
          map('grt', builtin.lsp_type_definitions, '[G]oto [T]ype Definition')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method('textDocument/documentHighlight', event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client:supports_method('textDocument/inlayHint', event.buf) then
            map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      local servers = {
        clangd = {
          cmd = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--header-insertion=iwyu',
            '--completion-style=detailed',
            '--function-arg-placeholders',
            '--fallback-style=llvm',
          },
          init_options = { usePlaceholders = true, completeUnimported = true, clangdFileStatus = true },
        },
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              cargo = { allFeatures = true },
              check = { command = 'clippy' },
            },
          },
        },
        stylua = {},
        lua_ls = {
          on_init = function(client)
            client.server_capabilities.documentFormattingProvider = false
            if client.workspace_folders then
              local path = client.workspace_folders[1].name
              if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
            end
            client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
              runtime = { version = 'LuaJIT', path = { 'lua/?.lua', 'lua/?/init.lua' } },
              workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file('', true) },
            })
          end,
          settings = { Lua = { format = { enable = false } } },
        },
      }

      require('mason').setup()
      local ensure_installed = vim.tbl_keys(servers or {})
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }
      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  })
end

-- ============================================================
-- SECTION 7: FORMATTING
-- conform.nvim setup and keymap
-- ============================================================
do
  table.insert(plugins, {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function() require('conform').format { async = true, lsp_fallback = true } end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    config = function()
      require('conform').setup {
        notify_on_error = false,
        format_on_save = function(bufnr)
          local enabled_filetypes = {}
          if enabled_filetypes[vim.bo[bufnr].filetype] then
            return { timeout_ms = 500, lsp_format = 'fallback' }
          end
        end,
        formatters_by_ft = {},
      }
    end,
  })
end

-- ============================================================
-- SECTION 8: AUTOCOMPLETE & SNIPPETS
-- blink.cmp and luasnip setup
-- ============================================================
do
  table.insert(plugins, {
    'L3MON4D3/LuaSnip',
    version = 'v2.*',
    config = function()
      require('luasnip').setup {}
    end,
  })

  table.insert(plugins, {
    'saghen/blink.cmp',
    version = 'v0.*',
    event = 'InsertEnter', -- Lazy loads autocomplete engine only when you start typing
    dependencies = { 'L3MON4D3/LuaSnip' },
    config = function()
      require('blink.cmp').setup {
        keymap = {
          preset = 'super-tab',
          ['<C-k>'] = { 'fallback' },
          ['<C-s>'] = { 'show_signature', 'hide_signature', 'fallback' }, 
        },
        appearance = { nerd_font_variant = 'mono' },
        completion = { documentation = { auto_show = false, auto_show_delay_ms = 500 } },
        sources = { default = { 'lsp', 'path', 'snippets' } },
        snippets = { preset = 'luasnip' },
        fuzzy = { implementation = 'lua' },
        signature = { enabled = true },
      }
    end,
  })
end

-- ============================================================
-- SECTION 9: TREESITTER
-- Parser installation, syntax highlighting, folds, indentation
-- ============================================================
do
  table.insert(plugins, {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPost', 'BufNewFile' }, -- Lazy-loading: Keeps startup fast
    build = ':TSUpdate',
    config = function()
      local configs = require('nvim-treesitter.configs')
      configs.setup({
        ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
        sync_install = false,
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  })
end


do
  table.insert(plugins, {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    keys = {
      { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
    },
    opts = {
      filesystem = {
        window = {
          mappings = {
            ['\\'] = 'close_window',
          },
        },
      },
    },
  })
end


-- ============================================================
-- SECTION 10: LAZY.NVIM INITIALIZATION
-- Pass everything to lazy at the end
-- ============================================================
require('lazy').setup(plugins, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})