return {
	"mfussenegger/nvim-dap",
	dependencies = {
        "igorlfs/nvim-dap-view",
        "theHamsta/nvim-dap-virtual-text",
        "mfussenegger/nvim-dap-python"
    },
	keys = {
		{ "<leader>dt", function() require("dap").toggle_breakpoint() end, desc = "Dap Toggle BreakPoint" },
		{ "<leader>dd", function() require("dap").continue() end, desc = "DAP Continue" },
		{ "<leader>do", function() require("dap").step_over() end, desc = "DAP Step Over" },
		{ "<leader>di", function() require("dap").step_into() end, desc = "DAP Step Into" },
		{ "<leader>dO", function() require("dap").step_out() end, desc = "DAP Step Out" },
		{ "<leader>ds", function() require("dap").disconnect() end, desc = "DAP Disconnect" },
		{ "<leader>dvc", function() require("dap-view").toggle() end, desc = "DAP View Toggle" },
		{ "<leader>dvv", "<cmd>DapVirtualTextToggle<CR>", desc = "DAP Text View Toggle" },
	},
	config = function()

		local dap = require("dap")
        require('dap-python').setup()
        require("config.daps.javascript") -- js/ts adapter config

        require("nvim-dap-virtual-text").setup({
            enabled=false
        })

        local dapview = require("dap-view")
        dapview.setup() -- Ensure dap-view is set up

        -- Autocmd to open dap-view automatically when a debugging session is initiated
        dap.listeners.before.attach.dapview_config = function()
          dapview.open()
        end
        dap.listeners.before.launch.dapview_config = function()
          dapview.open()
        end

        -- Optional: Autocmd to close dap-view automatically when the session terminates or exits
        dap.listeners.before.event_terminated.dapview_config = function()
          dapview.close()
        end

        dap.listeners.before.event_exited.dapview_config = function()
          dapview.close()
        end

        dap.listeners.after.event_terminated.dapview_config = function ()
            dapview.close()
        end

        dap.listeners.after.event_exited.dapview_config = function ()
            dapview.close()
        end

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
