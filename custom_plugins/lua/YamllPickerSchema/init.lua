local M = {}

--- Verifica se o ambiente atende aos pré-requisitos do plugin
---@return boolean
local function check_version()
  if vim.fn.has("nvim-0.12") ~= 1 then
    vim.notify(
      "[YamllPickerSchema] Este plugin requer Neovim 0.12+ (para suporte nativo ao comando :restart).",
      vim.log.levels.WARN,
      { title = "YamllPickerSchema" }
    )
    return false
  end
  return true
end

--- Executa o fluxo de busca e aplicação do schema
---@param force_refresh boolean? Força o re-download do SchemaStore
function M.add_yaml_schema(force_refresh)
  if not check_version() then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local schemastore = require("YamllPickerSchema.schemastore")
  local picker = require("YamllPickerSchema.picker")

  schemastore.get_schemas(force_refresh or false, function(schemas, err)
    if err then
      vim.notify(err, vim.log.levels.ERROR, { title = "YamllPickerSchema" })
      return
    end

    if not schemas or #schemas == 0 then
      vim.notify("Nenhum schema encontrado no catálogo.", vim.log.levels.WARN, {
        title = "YamllPickerSchema",
      })
      return
    end

    picker.open(bufnr, schemas)
  end)
end

--- Inicializa o plugin YamllPickerSchema
---@param opts table?
function M.setup(opts)
  if not check_version() then
    return
  end

  -- Inicializa o detector automático de schema ao abrir arquivos YAML
  local detector = require("YamllPickerSchema.detector")
  detector.setup()

  local command_opts = {
    bang = true,
    desc = "Abre o picker de schemas do SchemaStore para o arquivo YAML atual",
  }

  -- Registra tanto :AddYamlSchema quanto :YamllPickerSchema
  vim.api.nvim_create_user_command("AddYamlSchema", function(cmd_opts)
    M.add_yaml_schema(cmd_opts.bang)
  end, command_opts)

  vim.api.nvim_create_user_command("YamllPickerSchema", function(cmd_opts)
    M.add_yaml_schema(cmd_opts.bang)
  end, command_opts)
end

return M
