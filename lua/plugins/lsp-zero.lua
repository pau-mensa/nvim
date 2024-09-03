return {
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    lazy = true,
    config = false,
    init = function()
      -- Disable automatic setup, we are doing it manually
      vim.g.lsp_zero_extend_cmp = 0
      vim.g.lsp_zero_extend_lspconfig = 0
    end
  },
  {
    'williamboman/mason.nvim',
    build = ':MasonUpdate',
    lazy = false,
    config = true,
  },
  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {'L3MON4D3/LuaSnip'},
      {'rafamadriz/friendly-snippets'}
    },
    config = function()
	local lsp_zero = require('lsp-zero')
    	lsp_zero.extend_cmp()

        require('luasnip.loaders.from_vscode').lazy_load()

        local cmp = require('cmp')
        local cmp_action = require('lsp-zero.cmp').action()

        cmp.setup({
           completion = {
           autocomplete = { cmp.TriggerEvent.TextChanged },
        },
        formatting = lsp_zero.cmp_format({details = true}),
        mapping = {
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-f>'] = cmp_action.luasnip_jump_forward(),
          ['<C-b>'] = cmp_action.luasnip_jump_backward(),
        },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
          { name = 'luasnip' },
        },
      })
    end
  },

  -- LSP
      {
  'neovim/nvim-lspconfig',
  cmd = {'LspInfo', 'LspInstall', 'LspStart'},
  event = {'BufReadPre', 'BufNewFile'},
  dependencies = {
    {'hrsh7th/cmp-nvim-lsp'},
    {'williamboman/mason-lspconfig.nvim'},
  },
  config = function()
    -- Initialize lsp-zero
    local lsp_zero = require('lsp-zero')
    lsp_zero.extend_lspconfig()

    -- Default keymaps for LSP
    lsp_zero.on_attach(function(client, bufnr)
      lsp_zero.default_keymaps({buffer = bufnr})
    end)

    -- Format on save settings
    lsp_zero.format_on_save({
      format_opts = {
        async = false,
        timeout_ms = 10000,
      },
      servers = {
        ['eslint'] = {'javascript', 'typescript', 'typescriptreact'},
        ['rust_analyzer'] = {'rust'},
        ['pyright'] = {'python'},
      }
    })

    -- Capabilities setup for nvim-cmp
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    -- Mason LSP configuration
    require('mason-lspconfig').setup({
      ensure_installed = {
        'pyright',
        'eslint',
        'tsserver',
        'rust_analyzer',
      },
      handlers = {
        function(server_name)
          require('lspconfig')[server_name].setup({
            capabilities = capabilities,
          })
        end,
        lua_ls = function()
          local lua_opts = lsp_zero.nvim_lua_ls()
          require('lspconfig').lua_ls.setup(lua_opts)
        end,
        tsserver = function()
          local util = require('lspconfig/util')
          require('lspconfig').tsserver.setup({
            auto_start = true,
            single_file_support = false,
            flags = {
              debounce_text_changes = 150
            },
            root_dir = function (pattern)
              local cwd  = vim.loop.cwd()
              local root = util.root_pattern("package.json", "tsconfig.json", ".git")(pattern)
              return root or cwd
            end,
            capabilities = capabilities,
          })
        end,
        eslint = function()
          require('lspconfig').eslint.setup({
            on_attach = function(_, bufnr)
              vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                command = "EslintFixAll",
              })
            end,
            capabilities = capabilities
          })
        end,
        pyright = function()
          require('lspconfig').pyright.setup({
            on_init = function(client)
              local project_root = client.config.root_dir
              local venv_path = project_root .. '/.venv'

              -- Check if the .venv exists, otherwise use system Python
              if vim.fn.isdirectory(venv_path) == 1 then
                client.config.settings = client.config.settings or {}
                client.config.settings.python = client.config.settings.python or {}
                client.config.settings.python.pythonPath = venv_path .. '/bin/python'
              else
                client.config.settings = client.config.settings or {}
                client.config.settings.python = client.config.settings.python or {}
                client.config.settings.python.pythonPath = vim.fn.exepath('python3')
              end
            end,
            settings = {
              python = {
                analysis = {
                  autoSearchPaths = true,
                  useLibraryCodeForTypes = true,
                },
              },
            },
            root_dir = require('lspconfig').util.find_git_ancestor or require('lspconfig').util.path.dirname,
            capabilities = capabilities,
          })
        end,
      },
    })

      -- this is for diagnositcs signs on the line number column
      -- use this to beautify the plain E W signs to more fun ones
      -- !important nerdfonts needs to be setup for this to work in your terminal
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl= hl, numhl = hl })
      end

      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics,
          {
            virtual_text = true,
            signs = true,
            update_in_insert = false,
            underline = true,
          }
      )
    end
  }
}
