return
-- Lua
{
	"folke/persistence.nvim",
	event = "BufReadPre", -- this will only start session saving when an actual file was opened
	---@module "persistence"
	---@type Persistence.Config
	opts = {
		-- add any custom options here
	}
}
