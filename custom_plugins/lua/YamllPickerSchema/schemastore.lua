local M = {}

local CATALOG_URL = "https://www.schemastore.org/api/json/catalog.json"
local CACHE_FILE = vim.fn.stdpath("cache") .. "/schemastore_catalog.json"

local memory_cache = nil

--- Lê o catálogo em cache no disco se disponível
---@return table|nil schemas
local function read_disk_cache()
  local f = io.open(CACHE_FILE, "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()

  if not content or content == "" then
    return nil
  end

  local ok, data = pcall(vim.json.decode, content)
  if ok and data and data.schemas and type(data.schemas) == "table" then
    return data.schemas
  end
  return nil
end

--- Salva o catálogo baixado no disco
---@param json_str string
local function write_disk_cache(json_str)
  local f = io.open(CACHE_FILE, "w")
  if f then
    f:write(json_str)
    f:close()
  end
end

--- Normaliza e filtra a lista de schemas
---@param raw_schemas table[]
---@return table[]
local function sanitize_schemas(raw_schemas)
  local result = {}
  for _, item in ipairs(raw_schemas) do
    if item.url and item.url ~= "" and item.name and item.name ~= "" then
      table.insert(result, {
        name = item.name,
        description = item.description or "",
        url = item.url,
        fileMatch = item.fileMatch or {},
      })
    end
  end

  -- Ordena alfabeticamente pelo name
  table.sort(result, function(a, b)
    return a.name:lower() < b.name:lower()
  end)

  return result
end

--- Obtém a lista de schemas (da memória, do cache ou baixando do SchemaStore)
---@param force_refresh boolean
---@param callback fun(schemas: table[]|nil, err: string|nil)
function M.get_schemas(force_refresh, callback)
  -- Se não for force_refresh, tenta usar memória ou disco
  if not force_refresh then
    if memory_cache then
      callback(memory_cache, nil)
      return
    end

    local disk_schemas = read_disk_cache()
    if disk_schemas then
      memory_cache = sanitize_schemas(disk_schemas)
      callback(memory_cache, nil)
      return
    end
  end

  vim.notify("Baixando catálogo de schemas do SchemaStore...", vim.log.levels.INFO, {
    title = "YamllPickerSchema",
  })

  -- Baixa assincronamente usando curl
  vim.system({ "curl", "-sSL", CATALOG_URL }, { text = true }, function(obj)
    vim.schedule(function()
      if obj.code ~= 0 or not obj.stdout or obj.stdout == "" then
        local err_msg = "Falha ao baixar do SchemaStore: " .. (obj.stderr or "código " .. obj.code)
        local disk_schemas = read_disk_cache()
        if disk_schemas then
          vim.notify("Erro no download. Usando cache local do SchemaStore.", vim.log.levels.WARN, {
            title = "YamllPickerSchema",
          })
          memory_cache = sanitize_schemas(disk_schemas)
          callback(memory_cache, nil)
          return
        end
        callback(nil, err_msg)
        return
      end

      local ok, data = pcall(vim.json.decode, obj.stdout)
      if not ok or not data or not data.schemas then
        callback(nil, "Falha ao decodificar JSON do SchemaStore.")
        return
      end

      write_disk_cache(obj.stdout)
      memory_cache = sanitize_schemas(data.schemas)
      callback(memory_cache, nil)
    end)
  end)
end

return M
