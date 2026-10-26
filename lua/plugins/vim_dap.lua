-- breakpoints persistidos por arquivo entre sessões do nvim
local bp_file = vim.fn.stdpath("data") .. "/dap_breakpoints.json"

local function read_bps()
	local ok, data = pcall(function() return vim.json.decode(table.concat(vim.fn.readfile(bp_file), "\n")) end)
	return ok and type(data) == "table" and data or {}
end

local function save_bps(bufs)
	local data = read_bps()
	local all = require("dap.breakpoints").get()
	for _, buf in ipairs(bufs) do
		local name = vim.api.nvim_buf_get_name(buf)
		if name ~= "" then
			local lines = vim.tbl_map(function(bp) return bp.line end, all[buf] or {})
			data[name] = #lines > 0 and lines or nil
		end
	end
	vim.fn.writefile({ vim.json.encode(data) }, bp_file)
end

local function toggle_bp()
	require("dap").toggle_breakpoint()
	save_bps({ vim.api.nvim_get_current_buf() })
end

return {
	"mfussenegger/nvim-dap",
	init = function()
		vim.api.nvim_create_autocmd("BufReadPost", {
			callback = function(ev)
				local lines = read_bps()[vim.api.nvim_buf_get_name(ev.buf)]
				if not lines then return end
				local bps = require("dap.breakpoints")
				for _, line in ipairs(lines) do
					if line <= vim.api.nvim_buf_line_count(ev.buf) then bps.set({}, ev.buf, line) end
				end
			end,
		})
		-- salva de novo ao sair pra acompanhar linhas que mudaram de posição
		vim.api.nvim_create_autocmd("VimLeavePre", {
			callback = function()
				if package.loaded["dap"] then save_bps(vim.api.nvim_list_bufs()) end
			end,
		})
	end,
	dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "theHamsta/nvim-dap-virtual-text",
        "mfussenegger/nvim-dap-python"
    },
	keys = {
		{ "<leader>dt", toggle_bp, desc = "Dap Toggle BreakPoint" },
		{ "<leader>dd", function() require("dap").continue() end, desc = "DAP Continue" },
		{ "<leader>do", function() require("dap").step_over() end, desc = "DAP Step Over" },
		{ "<leader>di", function() require("dap").step_into() end, desc = "DAP Step Into" },
		{ "<leader>dO", function() require("dap").step_out() end, desc = "DAP Step Out" },
		{ "<leader>ds", function() require("dap").disconnect() end, desc = "DAP Disconnect" },
		{ "<leader>dvc", function() require("dapui").toggle() end, desc = "DAP UI Toggle" },
		{ "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "DAP Eval" },
		{ "<F5>", function() require("dap").continue() end, desc = "DAP Continue" },
		{ "<S-F5>", function() require("dap").terminate() end, desc = "DAP Stop" },
		{ "<F9>", toggle_bp, desc = "DAP Toggle BreakPoint" },
		{ "<F10>", function() require("dap").step_over() end, desc = "DAP Step Over" },
		{ "<F11>", function() require("dap").step_into() end, desc = "DAP Step Into" },
		{ "<S-F11>", function() require("dap").step_out() end, desc = "DAP Step Out" },
		{ "<leader>db", function()
			require("dap").list_breakpoints(false)
			require("telescope.builtin").quickfix({ prompt_title = "Breakpoints" })
		end, desc = "DAP List Breakpoints" },
		{ "<leader>dvv", "<cmd>DapVirtualTextToggle<CR>", desc = "DAP Text View Toggle" },
	},
	config = function()

		local dap = require("dap")
        require('dap-python').setup()
        require("config.daps.javascript") -- js/ts adapter config
        require("config.daps.go")

        require("nvim-dap-virtual-text").setup({
            enabled=false
        })

        local dapui = require("dapui")
        -- layout estilo VSCode: painel lateral esquerdo + console embaixo
        dapui.setup({
            layouts = {
                {
                    elements = {
                        { id = "scopes", size = 0.4 },
                        { id = "watches", size = 0.2 },
                        { id = "stacks", size = 0.25 },
                        { id = "breakpoints", size = 0.15 },
                    },
                    position = "left",
                    size = 45,
                },
                {
                    elements = {
                        { id = "repl", size = 0.5 },
                        { id = "console", size = 0.5 },
                    },
                    position = "bottom",
                    size = 12,
                },
            },
        })

        dap.listeners.before.attach.dapui_config = dapui.open
        dap.listeners.before.launch.dapui_config = dapui.open
        local close = function() dapui.close() end
        dap.listeners.before.event_terminated.dapui_config = close
        dap.listeners.before.event_exited.dapui_config = close
        dap.listeners.before.disconnect.dapui_config = close
        dap.listeners.before.terminate.dapui_config = close

        --vim.fn.sign_define('DapBreakpoint', {text='🔴', texthl='', linehl='', numhl=''})
        --vim.fn.sign_define('DapBreakpoint', {text='•', texthl='red', linehl='', numhl=''})
        --
        vim.api.nvim_set_hl(0, "blue",   { fg = "#3d59a1" })
        vim.api.nvim_set_hl(0, "green",  { fg = "#9ece6a" })
        vim.api.nvim_set_hl(0, "yellow", { fg = "#FFFF00" })
        vim.api.nvim_set_hl(0, "orange", { fg = "#f09000" })


        vim.fn.sign_define('DapBreakpoint', { text='🔺', texthl='', linehl='', numhl='' })
        vim.fn.sign_define('DapStopped', { text='', texthl='yellow', linehl='yellow', numhl= 'yellow' })

	end,
}
