return
{
  "folke/which-key.nvim",
  event = "VeryLazy",
  ---@module "which-key"
  ---@type wk.Opts
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below

  },

  config =function ()
	  local which =require("which-key")
	  which.setup({
		  delay=2000
	  })
  	
  end,
  
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
