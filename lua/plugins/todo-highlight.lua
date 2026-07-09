return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	event = { "BufReadPost", "BufNewFile" },
	cmd = { "TodoTelescope", "TodoQuickFix", "TodoTrouble" },
	opts = {
        highlight = {
             pattern = [[.*<(KEYWORDS)\s*\s]]
        },
		search = {
			-- regex that will be used to match keywords.
			-- don't replace the (KEYWORDS) placeholder
			-- pattern = [[\b(KEYWORDS):]], -- ripgrep regex
			pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
		},
	},
}
