return
{
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
    },
    config = function()
        require("fidget").setup {
            notification = {
                window = {
                    winblend = 0,
                },
            }
        }
    end
}
