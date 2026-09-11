return
{
  "mosheavni/yaml-companion.nvim",
    config =function ()
    local cfg = require("yaml-companion").setup({ })
    vim.lsp.config("yamlls", cfg)
    vim.lsp.enable("yamlls")
  end
}
