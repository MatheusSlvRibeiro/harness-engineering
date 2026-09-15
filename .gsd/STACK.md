# STACK.md

Identificação do projeto: qual stack este código usa, como validar, que ambiente ele precisa.

Este arquivo é **preenchido pela entrevista de bootstrap** e **nunca é sobrescrito por scripts de sincronia**.
As convenções de código (folder layout, componentes, testes, schemas) **não** vão aqui — vêm da skill `stack-<archetype>` que combina com esta stack (ver `skills/harness-index`).

> Este repo é o próprio harness-engineering-template — não uma aplicação. Aqui "código" é o conjunto de scripts bash, skills em Markdown e contratos JSON que outros projetos consomem.

---

## Stack

- Runtime / framework: N/A — não é uma aplicação executável, é um scaffolding de arquivos
- Linguagem: Bash (scripts em `scripts/`), Markdown (skills, `AGENTS.md`, docs), JSON (contratos `.harness/`), PowerShell (equivalentes `.ps1` para Windows)
- Banco / ORM: N/A
- Estilização: N/A
- Testes: N/A — não há suite automatizada; a validação é estrutural (schema/CI, ver abaixo)
- Gerenciador de pacotes: N/A — dependências são binários de sistema (`bash`, `git`, `jq`; `gh` e `uv`/MCPs opcionais)
- Deploy: N/A — distribuído via `git clone` + symlink (`scripts/setup.sh`), consumido por outros repos via `harness-init.sh` / `harness-sync.sh`

**Archetype de projeto correspondente:** nenhum — este repo não roda `project-multitenant` nem `project-spa`; ele é quem define esses archetypes e os skills atômicos `frontend/*`/`backend/*` que eles combinam.

---

## Validação (rodar antes de cada commit)

```bash
bash scripts/check-harness.sh
```

O que ele roda, em sequência:

1. Valida schema/integridade de `.harness/feature_list.json` e `.harness/baseline.json` (se existirem — neste repo eles não existem, só os `.example.json`, então a passada 1 emite warning, não erro)
2. Diff contra a ref base (`preview`/`main`): campos congelados (`title`, `criteria[]`) não mudaram em features existentes, nenhuma feature foi removida
3. Diff de `baseline.json`: nenhuma métrica regrediu

**Uma tarefa só está completa quando este comando passa com zero erros.**
Nunca considere uma tarefa pronta com base apenas no seu próprio julgamento.

Este é o mesmo comando que roda no CI (`.github/workflows/harness-gate.yml`) em todo PR para `main` ou `preview`.

---

## Setup do zero

```bash
git clone <repo>
export HARNESS_TEMPLATE="$(pwd)"     # ou o path onde clonou
./scripts/setup.sh                   # symlink de skills/, RTK, MCPs (mempalace/openspace)
./scripts/doctor.sh                  # verifica se tudo foi instalado
```

Não há `.env` — este repo não fala com serviços externos diretamente (RTK, mempalace e openspace são ferramentas locais, não credenciais).

Este repo não precisa de GitHub Project próprio para funcionar como template, mas se for usado também como projeto de trabalho ativo (issues, PRs de melhorias no harness), siga a skill `workflow-project-board`.

---

## Variáveis de ambiente

| Variável | Descrição |
| -------- | --------- |
| `HARNESS_TEMPLATE` | Path para este repo, usado por `harness-init.sh`/`harness-sync.sh` rodando em *outros* projetos para encontrar o template |
| `HARNESS_NO_PULL` | `1` para pular o `git pull --ff-only` automático em `harness-sync.sh`/`harness-init.sh` |
| `SKIP_MCP` | `1` para `scripts/setup.sh` pular a instalação dos MCPs (mempalace/openspace) |
| `FORCE` | `1` para `scripts/setup.sh` recriar o symlink de skills mesmo se já existir |

---

## Notas específicas do projeto

- Este repo é meta: ele **é** o harness, não um projeto que **usa** o harness. `.gsd/` e `.harness/` aqui existem para dogfooding (demonstrar o próprio fluxo), não porque este repo tem features de produto no sentido usual.
- `templates/` guarda os skeletons que `harness-init.sh`/`harness-sync.sh` copiam para projetos novos — são a fonte de verdade para o texto default de `STACK.md`, `SPEC.md`, `ROADMAP.md`. Mudanças de texto universal devem ser feitas lá, não só aqui.
- Skills vivem em `skills/` neste repo e são symlinkadas para `~/.claude/skills/harness/` por `scripts/setup.sh` — qualquer edição de skill é feita direto neste repo, nunca no destino do symlink.
