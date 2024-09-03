vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.wo.number = true
vim.wo.relativenumber = true
vim.opt.termguicolors = true

vim.o.expandtab = true
vim.o.smartindent = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2

vim.opt.colorcolumn = "80"
vim.opt.updatetime = 800

vim.opt.clipboard = 'unnamedplus'
vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.cursorline = true
vim.opt.smartindent = true
vim.opt.clipboard = 'unnamedplus'

vim.on_key(function(char)
  if vim.fn.mode() == "n" then
    local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
    if vim.opt.hlsearch:get() ~= new_hlsearch then vim.opt.hlsearch = new_hlsearch end
  end
end, vim.api.nvim_create_namespace "auto_hlsearch")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = " "

-- Setup lazy.nvim
require("lazy").setup('plugins')

-- Setup keymaps
vim.keymap.set("v", "<S-Up>", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "<S-Down>", ":m '>+1<CR>gv=gv")

vim.keymap.set("n", "<leader>ww", ":wa<CR>")
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader><esc>", ":quitall!<CR>")
vim.keymap.set("n", "<leader>q", ":bd<CR>", { nowait = true, silent = true })

vim.keymap.set("n", "<leader>cr", ':lua vim.lsp.buf.rename()<CR>')
vim.keymap.set("n", "<leader>ca", ':lua vim.lsp.buf.code_action()<CR>')
vim.keymap.set("n", "<C-space>", ':lua vim.lsp.buf.hover()<CR>', { silent = true })
-- Keybinding for jumping to definition
vim.keymap.set("n", '<leader>gd', ':lua vim.lsp.buf.definition()<CR>')

-- Keybinding for showing references
vim.keymap.set("n", "<leader>gr", ':lua vim.lsp.buf.references()<CR>')

vim.keymap.set("n", "<tab>", ":BufferLinePick<CR>", { silent = true })

vim.keymap.set("n", "b", "<C-W>", { noremap = true, silent = true })
vim.keymap.set("n", "<F9>", ":LspRestart<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>dd", ':bd<CR>', {})
vim.keymap.set("n", "<leader>nt", ':bnext<CR>', {})
vim.keymap.set("n", "<leader>pt", ':bprev<CR>', {})

-- Setup theme
vim.g.everforest_background = 'soft'
vim.g.everforest_better_performance = 1
vim.g.everforest_diagnostic_text_highlight = 1
vim.cmd [[ colorscheme everforest ]]

vim.api.nvim_create_user_command('W', function()
  vim.cmd("w")
end, {nargs = 0})

-- Setup Treesitter
require('nvim-treesitter.configs').setup({
  ensure_installed = {
    "c", "python", "lua", "vim", "vimdoc", "query", "rust", "javascript", "typescript", "html", "css", "scss"
  },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})

-- Setup Indent-Blankline (ibl)
require("ibl").setup()

-- DAP Setup
local dap, dapui = require("dap"), require("dapui")
dapui.setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

vim.keymap.set("n", "<leader>sb", ":DapToggleBreakpoint<CR>")
vim.keymap.set("n", "<leader>sd", ":DapContinue<CR>")

dap.adapters.codelldb = {
  type = 'server',
  port = "${port}",
  executable = {
    command = vim.fn.stdpath('data') .. '/mason/bin/codelldb',
    args = {"--port", "${port}"},
  }
}

dap.configurations.rust = {
  {
    name = "Rust debug",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = true,
  },
}

vim.api.nvim_set_hl(0, 'DapBreakpoint', { ctermbg = 0, fg = '#993939', bg = '#31353f' })
vim.api.nvim_set_hl(0, 'DapLogPoint', { ctermbg = 0, fg = '#61afef', bg = '#31353f' })
vim.api.nvim_set_hl(0, 'DapStopped', { ctermbg = 0, fg = '#98c379', bg = '#31353f' })

vim.fn.sign_define('DapBreakpoint', { text='', texthl='DapBreakpoint', linehl='DapBreakpoint', numhl='DapBreakpoint' })
vim.fn.sign_define('DapBreakpointCondition', { text='ﳁ', texthl='DapBreakpoint', linehl='DapBreakpoint', numhl='DapBreakpoint' })
vim.fn.sign_define('DapBreakpointRejected', { text='', texthl='DapBreakpoint', linehl='DapBreakpoint', numhl= 'DapBreakpoint' })
vim.fn.sign_define('DapLogPoint', { text='', texthl='DapLogPoint', linehl='DapLogPoint', numhl= 'DapLogPoint' })
vim.fn.sign_define('DapStopped', { text='', texthl='DapStopped', linehl='DapStopped', numhl= 'DapStopped' })

require('dap-python').setup('/usr/local/bin/python3')

