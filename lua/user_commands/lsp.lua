
vim.api.nvim_create_user_command(
  'LSPAttached',
  function()
        local clients = vim.lsp.buf_get_clients()
        local client_names = {}
        for _, client in pairs(clients) do
          table.insert(client_names, client.name)
        end
        print(table.concat(client_names, ", "))
  end,
  {}
)



