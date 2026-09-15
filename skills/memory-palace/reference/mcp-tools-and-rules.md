# MCP tools e regras inegociáveis

Referência de `memory-palace`. Volte ao [índice](../SKILL.md) para o quando-invocar.

## MCP tools

O MemPalace expõe 29 tools via MCP — leitura/escrita do palace, knowledge graph temporal, navegação cross-wing, gerência de drawers, diários de agentes.

Lista completa: `mempalaceofficial.com/reference/mcp-tools`.

No harness, as tools mais usadas são:

- `mempalace_search` — busca semântica
- `mempalace_add_drawer` — registrar memória verbatim
- `mempalace_wake_up` — contexto recente no início da sessão
- `mempalace_list_wings` / `mempalace_list_rooms` — descobrir estrutura existente

## Regras inegociáveis

- Nada de secret (token, password, chave de API) em drawer. Use `env` room só para **ponteiros** (ex.: "DATABASE_URL fica no 1Password vault `acme-prod`").
- Não parafraseie ao salvar — guarde o texto literal do dev, do cliente, do log. MemPalace existe exatamente para evitar a perda em LLM summarization.
- Wing de projeto = nome da pasta, sempre. Não duplique sob outro slug.
- Antes de propor decisão arquitetural, **search**. Se houver decisão prévia, exiba-a.
- Drawer não substitui `.gsd/progress/` — progresso de sprint vive em `.gsd/`, memória cross-sessão vive no palace.
