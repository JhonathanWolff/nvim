return {
  name = "YamllPickerSchema",
  dir = vim.fn.stdpath("config") .. "/custom_plugins",
  lazy = false,
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  opts = {},
  config = function(_, opts)
    require("YamllPickerSchema").setup(opts)
  end,
}
