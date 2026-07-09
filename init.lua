
vim.opt.termguicolors = true
vim.opt.wrap = false

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.relativenumber = true


-- cursor line
vim.opt.cursorline = true


require("config.lazy")
require("config.keybinds")


vim.cmd.colorscheme "catppuccin"

require("config.clipboard")
--vim.opt.clipboard = "unnamedplus"


-- space indentation
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.autoindent = true

-- remove tab winbar
vim.opt.showtabline = 0


-- Dap adapters are configured lazily inside the nvim-dap plugin spec
-- (lua/plugins/vim_dap.lua), loaded on first <leader>d keypress.


--auto CMD
require("autocmds.autocmd")

-- commands User
require('user_commands.lsp')

-- extra lsp config
require("config.lsp_configs")

vim.filetype.add({
  extension = {
    sqlx = 'sql', -- Tell Neovim to treat .sqlx as sql
    jsonl = 'json'
  },
})


--vue setup
require("config.vue_config")

vim.cmd("packadd nvim.undotree")
vim.keymap.set("n", "<leader>uu", require("undotree").open)
