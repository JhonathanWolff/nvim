return
{
  'stevearc/conform.nvim',
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    { "<leader>F", function() require("conform").format({ lsp_fallback = true }) end, desc = "Format file" },
  },
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {},
  config = function ()

        require("conform").setup({
          formatters_by_ft = {
            lua = { "stylua" },
            python = { "autopep8" },
            bash = {"shfmt"},
            sh = {"shfmt"},
            zsh = {"beautysh"}
            -- javascript = { "prettierd", "prettier", stop_after_first = true },
          },
        })

        vim.keymap.set("n", "<leader>F", function() require("conform").format({ lsp_fallback = true }) end, { desc = "Format file" })

  end
}
