if vim.fn.has("wsl") == 1 then
	vim.g.clipboard = {
		name = "win32yank",
		copy = {
			["+"] = "win32yank.exe -i --crlf",
			["*"] = "win32yank.exe -i --crlf",
		},
		paste = {
			["+"] = "win32yank.exe -o --lf",
			["*"] = "win32yank.exe -o --lf",
		},
		cache_enabled = true,
	}


    vim.keymap.set({ "n", "x", "v" }, "<leader>y", '"+y', { desc = "Yank para clipboard Windows" })
    vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank linha para clipboard Windows" })
    vim.keymap.set({ "n", "x", "v" }, "<leader>p", '"+p', { desc = "Paste do clipboard Windows" })
    vim.keymap.set({ "n", "x", "v" }, "<leader>P", '"+P', { desc = "Paste antes do cursor" })

end

-- vim.opt.clipboard = "unnamedplus"
