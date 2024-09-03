return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function()
      require("neo-tree").setup({
        sources = {
          "filesystem",
          "buffers",
          "git_status",
          -- "document_symbols",
        },
        filesystem = {
          filtered_items = {
            visible = true,
            hide_dotfiles = true,
            hide_gitignore = true,
          }
        },
        window = {
          position = "float"
        },
        close_if_last_window = true,
        default_source = "filesystem",
        use_libuv_file_watcher = true,
      })

      vim.keymap.set("n", "<leader>1", ":Neotree reveal float<CR>", { silent = true })
      vim.keymap.set("n", "<leader>2", ":Neotree git_status float<CR>", { silent = true })

      vim.cmd([[nnoremap \ :Neotree close<cr>]])
    end,
}
