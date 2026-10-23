return {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
        {
            "<leader>gh",
            function()
                if require("diffview.lib").get_current_view() then
                    vim.cmd("DiffviewClose")
                else
                    vim.cmd("DiffviewFileHistory %")
                end
            end,
            desc = "Toggle git history do arquivo atual",
        },
        {
            "<leader>gs",
            function()
                local text
                if vim.fn.mode():match("[vV\22]") then
                    local region = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
                    text = table.concat(region, "\n")
                    vim.api.nvim_feedkeys(vim.keycode("<esc>"), "nx", false)
                else
                    text = vim.fn.input("Buscar no histórico: ", vim.fn.expand("<cword>"))
                end
                if text == "" then return end
                require("diffview").file_history(nil, { vim.fn.expand("%:p"), "-S" .. text })
            end,
            mode = { "n", "x" },
            desc = "Git history: commits que adicionaram/removeram texto",
        },
    },
}
