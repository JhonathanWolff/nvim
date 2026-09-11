# custom_plugins

Diretório raiz para plugins Neovim customizados locais.

## Plugins disponíveis:

### `YamllPickerSchema` (`custom_plugins/lua/YamllPickerSchema/`)
Plugin para detecção automática e seleção de schemas YAML via SchemaStore com integração com `yamlls` (YAML Language Server).

#### Funcionalidades:
- **Detecção de Schema**:
  - Quando um schema for detectado pelo `yamlls` ou por modeline, exibe:
    ```
    Schema <Nome> Loaded
    ```
  - Se nenhum schema for identificado para o arquivo YAML aberto, avisa:
    ```
    Schema not found add Manually
    ```
- **Comandos**:
  - `:AddYamlSchema` ou `:YamllPickerSchema`: abre o Telescope com pesquisa exclusiva pelo `name` do JSON e visualização prévia da configuração completa do schema em JSON na lateral.
  - Ao selecionar o schema com `<CR>`:
    - Adiciona `# yaml-language-server: $schema=<URL>` na primeira linha (deslocando o conteúdo para baixo).
    - Salva o arquivo (`:write`).
    - Reinicia o editor através do comando nativo `:restart` do Neovim 0.12+.
  - `:AddYamlSchema!` ou `:YamllPickerSchema!`: força o re-download do catálogo do SchemaStore ignorando o cache local.
