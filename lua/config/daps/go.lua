local dap = require("dap")

dap.adapters.delve = {
	type = "server",
	port = "${port}",
	executable = {
		command = vim.fn.stdpath("data") .. "/mason/bin/dlv",
		args = { "dap", "-l", "127.0.0.1:${port}" },
	},
}

dap.configurations.go = {
	{ type = "delve", name = "Debug file", request = "launch", program = "${file}" },
	{ type = "delve", name = "Debug package", request = "launch", program = "${fileDirname}" },
	{ type = "delve", name = "Debug test", request = "launch", mode = "test", program = "${file}" },
	{ type = "delve", name = "Debug test (package)", request = "launch", mode = "test", program = "${fileDirname}" },
}
