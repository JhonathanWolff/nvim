local M = {}

--- Aplica a linha de comentário do schema no topo do arquivo YAML,
--- salva o arquivo sem sobrescrever o conteúdo (deslocando para baixo) e reinicia o Neovim.
---@param bufnr number
---@param schema { name: string, url: string, description: string, fileMatch: string[] }
function M.apply_schema(bufnr, schema)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    vim.notify("Buffer inválido ou fechado.", vim.log.levels.ERROR, { title = "YamllPickerSchema" })
    return
  end

  local schema_line = string.format("# yaml-language-server: $schema=%s", schema.url)

  -- Verifica se a primeira linha já era um comentário de schema anterior
  local first_lines = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)
  local first_line = first_lines[1] or ""

  if first_line:match("^#%s*yaml%-language%-server:%s*%$schema=") or first_line:match("^#%s*%$schema:") then
    -- Substitui o comentário de schema antigo na primeira linha
    vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, { schema_line })
  else
    -- Insere na primeira linha (linha 0), empurrando todo o conteúdo para baixo sem sobrescrever
    vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { schema_line })
  end

  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" then
    vim.notify(
      "O buffer não possui nome salvo. Salve o arquivo (:w <nome>) antes de aplicar o schema e reiniciar.",
      vim.log.levels.WARN,
      { title = "YamllPickerSchema" }
    )
    return
  end

  -- Salva o arquivo no disco
  local ok_write, err_write = pcall(function()
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd("silent write")
    end)
  end)

  if not ok_write then
    vim.notify("Erro ao salvar o arquivo: " .. tostring(err_write), vim.log.levels.ERROR, {
      title = "YamllPickerSchema",
    })
    return
  end

  vim.notify(
    string.format("Schema '%s' aplicado com sucesso! Reiniciando Neovim...", schema.name),
    vim.log.levels.INFO,
    { title = "YamllPickerSchema" }
  )

  -- Reinicia o Neovim usando o comando nativo :restart (requer Neovim 0.12+)
  vim.defer_fn(function()
    vim.cmd("restart")
  end, 150)
end

--- Abre o Telescope picker com foco de busca no 'name' do JSON e preview da descrição, URL e fileMatch
---@param bufnr number
---@param schemas table[]
local function open_telescope(bufnr, schemas)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")

  -- O valor procurado é EXCLUSIVAMENTE o name do json
  local finder = finders.new_table({
    results = schemas,
    entry_maker = function(schema)
      return {
        value = schema,
        display = schema.name or "Sem Nome",
        ordinal = schema.name or "", -- Busca estrita pelo 'name' do JSON
      }
    end,
  })

  -- Previewer lateral exibindo descrição, URL e formatos de arquivo compatíveis (fileMatch)
  local previewer = previewers.new_buffer_previewer({
    title = "Detalhes do Schema",
    define_preview = function(self, entry)
      local s = entry.value
      local lines = {
        "# " .. (s.name or "Sem Nome"),
        "",
        "**URL:**",
        "  " .. (s.url or ""),
        "",
        "**Descrição:**",
        "  " .. ((s.description and s.description ~= "") and s.description or "Sem descrição fornecida."),
      }

      if s.fileMatch and #s.fileMatch > 0 then
        table.insert(lines, "")
        table.insert(lines, "**Formatos de Arquivo Compatíveis (fileMatch):**")
        for _, pattern in ipairs(s.fileMatch) do
          table.insert(lines, "  - `" .. pattern .. "`")
        end
      end

      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
      vim.bo[self.state.bufnr].filetype = "markdown"
    end,
  })

  pickers.new({}, {
    prompt_title = "YamllPickerSchema (Busca por Nome)",
    finder = finder,
    sorter = conf.generic_sorter({}),
    previewer = previewer,
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection and selection.value then
          M.apply_schema(bufnr, selection.value)
        end
      end)
      return true
    end,
  }):find()
end

--- Fallback para vim.ui.select se o Telescope não estiver disponível
---@param bufnr number
---@param schemas table[]
local function open_ui_select(bufnr, schemas)
  vim.ui.select(schemas, {
    prompt = "YamllPickerSchema - Selecione o Schema:",
    format_item = function(item)
      return item.name
    end,
  }, function(selected)
    if selected then
      M.apply_schema(bufnr, selected)
    end
  end)
end

--- Abre o picker de schemas
---@param bufnr number
---@param schemas table[]
function M.open(bufnr, schemas)
  local has_telescope, _ = pcall(require, "telescope")
  if has_telescope then
    open_telescope(bufnr, schemas)
  else
    open_ui_select(bufnr, schemas)
  end
end

return M
