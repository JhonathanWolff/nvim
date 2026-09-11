local M = {}

local checked_buffers = {}

--- Formata o nome do schema para exibição limpa
---@param raw_name string?
---@return string?
local function format_schema_name(raw_name)
  if not raw_name or raw_name == "" then
    return nil
  end
  return raw_name:gsub("%.schema%.json$", ""):gsub("%.json$", "")
end

--- Extrai o nome do schema a partir da resposta do LSP yamlls
---@param result table
---@return string?
local function get_schema_name_from_result(result)
  if not result or not result[1] then
    return nil
  end
  local s = result[1]
  if s.name and s.name ~= "" and s.name ~= "none" then
    return s.name
  end
  if s.description and s.description ~= "" then
    return s.description
  end
  if s.uri and s.uri ~= "" and s.uri ~= "none" then
    local file = s.uri:match("([^/]+)$") or s.uri
    return format_schema_name(file)
  end
  return nil
end

--- Extrai o nome do schema se houver modeline explícita no arquivo
---@param bufnr number
---@return string?
local function get_modeline_schema_name(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return nil
  end
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 10, false)
  for _, line in ipairs(lines) do
    local url = line:match("^#%s*yaml%-language%-server:%s*%$schema=(%S+)")
      or line:match("^#%s*%$schema:%s*(%S+)")
    if url then
      local file = url:match("([^/]+)$") or url
      return format_schema_name(file) or url
    end
  end
  return nil
end

--- Verifica se o buffer é um arquivo YAML válido
---@param bufnr number
---@return boolean
local function is_yaml_buffer(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local buftype = vim.bo[bufnr].buftype
  if buftype ~= "" then
    return false
  end

  local ft = vim.bo[bufnr].filetype
  if ft == "yaml" or ft:match("^yaml%.") then
    return true
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name:match("%.ya?ml$") then
    return true
  end

  return false
end

--- Agenda a verificação de schema via yamlls com polling resiliente
---@param bufnr number
function M.check_buffer(bufnr)
  if checked_buffers[bufnr] then
    return
  end

  if not is_yaml_buffer(bufnr) then
    return
  end

  local attempts = 0
  local max_attempts = 4
  local delay_ms = 350

  local function poll()
    if not vim.api.nvim_buf_is_valid(bufnr) or checked_buffers[bufnr] then
      return
    end

    attempts = attempts + 1
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "yamlls" })

    if #clients == 0 then
      if attempts < max_attempts then
        vim.defer_fn(poll, delay_ms)
      else
        local modeline_name = get_modeline_schema_name(bufnr)
        checked_buffers[bufnr] = true
        if modeline_name then
          vim.notify(string.format("Schema %s Loaded", modeline_name), vim.log.levels.INFO, {
            title = "YamllPickerSchema",
          })
        else
          vim.notify("Schema not found add Manually", vim.log.levels.WARN, {
            title = "YamllPickerSchema",
          })
        end
      end
      return
    end

    local client = clients[1]
    client:request("yaml/get/jsonSchema", { vim.uri_from_bufnr(bufnr) }, function(err, result)
      if not vim.api.nvim_buf_is_valid(bufnr) or checked_buffers[bufnr] then
        return
      end

      -- Se yamlls retornou um schema válido associado ao arquivo
      if result and #result > 0 and result[1].uri and result[1].uri ~= "none" then
        checked_buffers[bufnr] = true
        local schema_name = get_schema_name_from_result(result)
          or get_modeline_schema_name(bufnr)
          or "YAML"
        vim.notify(string.format("Schema %s Loaded", schema_name), vim.log.levels.INFO, {
          title = "YamllPickerSchema",
        })
        return
      end

      -- Caso ainda haja tentativas restantes, aguarda um pouco mais
      if attempts < max_attempts then
        vim.defer_fn(poll, delay_ms)
      else
        checked_buffers[bufnr] = true
        local modeline_name = get_modeline_schema_name(bufnr)
        if modeline_name then
          vim.notify(string.format("Schema %s Loaded", modeline_name), vim.log.levels.INFO, {
            title = "YamllPickerSchema",
          })
        else
          vim.notify("Schema not found add Manually", vim.log.levels.WARN, {
            title = "YamllPickerSchema",
          })
        end
      end
    end, bufnr)
  end

  vim.defer_fn(poll, 300)
end

--- Limpa o buffer do cache quando for fechado
---@param bufnr number
function M.clear_buffer(bufnr)
  checked_buffers[bufnr] = nil
end

--- Configura os autocomandos para detecção automática
function M.setup()
  local augroup = vim.api.nvim_create_augroup("YamllPickerSchemaDetector", { clear = true })

  -- Ao abrir ou ler um arquivo YAML
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    group = augroup,
    pattern = { "*.yaml", "*.yml" },
    callback = function(args)
      M.check_buffer(args.buf)
    end,
  })

  -- Ao definir o filetype como yaml
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "yaml", "yaml.*" },
    callback = function(args)
      M.check_buffer(args.buf)
    end,
  })

  -- Quando o yamlls se anexa a um buffer
  vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == "yamlls" then
        M.check_buffer(args.buf)
      end
    end,
  })

  -- Limpeza quando o buffer for deletado
  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = augroup,
    callback = function(args)
      M.clear_buffer(args.buf)
    end,
  })
end

return M
