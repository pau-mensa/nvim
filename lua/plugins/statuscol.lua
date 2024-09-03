return {
  "luukvbaal/statuscol.nvim",
  dependencies = {
    {
      "lewis6991/gitsigns.nvim",
      tag = "v0.6",
    },
  },
  config = function()
    local gitsigns = require("gitsigns")
    gitsigns.setup({
      on_attach = function(bufnr)

        -- Setup keymaps
        vim.api.nvim_buf_set_keymap(
          bufnr,
          'n',
          ']',
          '<cmd>lua require"gitsigns".next_hunk()<CR>',
          {nowait = true, noremap = true, silent = true}
        )

        vim.api.nvim_buf_set_keymap(
          bufnr,
          'n',
          '[',
          '<cmd>lua require"gitsigns".prev_hunk()<CR>',
          {nowait = true, noremap = true, silent = true}
        )

      end,
    })

    -- Folding options
    vim.opt.foldlevel = 99
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    vim.wo.foldcolumn = "1"
    vim.o.statuscolumn = "%l%s%C"

    vim.opt.list = true;
    local builtin = require("statuscol.builtin")
    require("statuscol").setup({
      segments = {
        { text = { "%s" }, click = "v:lua.ScSa" },
        { text = { builtin.lnumfunc }, click = "v:lua.ScLa", },
        {
          text = { " ", builtin.foldfunc, " " },
          condition = { builtin.not_empty, true, builtin.not_empty },
          click = "v:lua.ScFa"
        },
      },
    })
  end
}
