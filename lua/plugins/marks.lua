return {
  "chentoast/marks.nvim",
  config = function()
    require("marks").setup({
      default_mappings = true,
      builtin_marks = { ".", "<", ">", "^" },
      cyclic = true,
      force_write_shada = false,
      bookmark_0 = {
        sign = "⚑",
        hl_line = "LineNr",
        hl_virt_text = "Comment",
        hl_virt_text_pos = "eol",
      },
    })
  end,
}
