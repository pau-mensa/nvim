return {
  'rcarriga/nvim-dap-ui',
  dependencies = {
    'mfussenegger/nvim-dap',
    'nvim-neotest/nvim-nio'
  },
  init = function()
    -- This will run before the plugin loads
    -- We'll let the plugin use its default setup
  end,
}
