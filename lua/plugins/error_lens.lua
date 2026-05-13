-- return {
--     "chikko80/error-lens.nvim",
--     event = "BufRead",
--     dependencies = {
--         "nvim-telescope/telescope.nvim"
--     },
--     opts = {
--         -- your options go here
--         enabled = true
--     },
-- }

return {
	"rachartier/tiny-inline-diagnostic.nvim",
	event = "VeryLazy",
	priority = 1000,
	config = function()
		require("tiny-inline-diagnostic").setup({

            preset = "classic",
            transparent_bg = true,
			options = {
				multilines = {
					enabled = true,
				},
			},
		})
		vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
	end,
}
