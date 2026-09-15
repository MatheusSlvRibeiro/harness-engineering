# Harness Engineering

Um scaffolding reutilizável de **skills, MCPs, prompts e tooling** que permite a um agente de IA (Claude Code ou similar) operar qualquer projeto com a mesma disciplina de workflow: branches, commits, issues, project board, validação, tracking de progresso, memória cross-projeto e skills auto-evolutivas.

Isto não é um gerador de código. É um **harness** — o contexto que o agente carrega antes de escrever qualquer código, para que o trabalho produzido seja consistente e revisável.

> **Versão atual: v2** (skills + MCPs). A v1 (AGENTS.md monolítico + scripts inline) continua suportada para projetos legados; o caminho de migração está em [`docs/harness-v2/migration.md`](docs/harness-v2/migration.md).

---

## Por que isso existe

Sem um harness, toda sessão de IA começa do zero: o agente inventa convenções, o dev corrige, e o projeto deriva. Com o harness:

- Regras universais (Conventional Commits, branching, GitHub Project board, ratchet de qualidade) são escritas uma vez como **skills** e compartilhadas entre todos os projetos.
- Decisões arquiteturais notáveis viram **drawers** no MemPalace (memória *verbatim* cross-projeto) e são recuperadas semanticamente em sessões futuras.
- Convenções de stack (folder layout, componentes, testes) vivem em skills `stack-*` e podem evoluir automaticamente via OpenSpace conforme o uso.
- Comandos de shell viram 60–90% mais baratos em tokens via RTK (CLI proxy transparente).

Default é single-repo (cobre uso solo e a maioria dos projetos). Suporte a modos umbrella/sub-repo existe como avançado, para times que compartilham produto entre vários repos.

---

## Arquitetura em uma figura

```
~/.claude/skills/harness/          ← junction → <repo>/skills/   (CURATED, versionado)
~/.claude/skills/captured/         ← skills evoluídas pelo OpenSpace   (untracked, local)
~/.claude/mcp.json                 ← mempalace + openspace
```

Documento de referência completo: [`docs/harness-v2/overview.md`](docs/harness-v2/overview.md).

---

## Pré-requisitos

| Ferramenta | Por quê |
| --- | --- |
| `git` ≥ 2.30, `gh` (GitHub CLI) | base de tudo |
| `python` ≥ 3.9, [`uv`](https://docs.astral.sh/uv/) | instalar MCPs (MemPalace, OpenSpace) em envs isolados |
| `node` ≥ 18 | Claude Code CLI |
| `bash` ≥ 4 (Linux/macOS) ou PowerShell 5.1 (Windows) | scripts de setup/doctor |
| `jq` | validar `.harness/feature_list.json` e `.harness/baseline.json` |
| [RTK](https://github.com/rtk-ai/rtk) | comprime saída de comandos antes do LLM (instalado pelo setup) |

`setup.sh` / `setup.ps1` valida tudo e oferece instalar o que falta.

### Notas de Windows

Os scripts `.sh` precisam de **bash**. Use WSL (recomendado) ou Git Bash. PowerShell sozinho não roda os `.sh`, mas existe equivalente `.ps1` para todo script principal. Para o sistema de hooks do RTK em modo completo, WSL é necessário.

---

## Setup por máquina (uma vez)

```bash
# Linux / macOS / WSL
git clone https://github.com/MatheusSlvRibeiro/harness-engineering ~/harness-engineering
cd ~/harness-engineering
./scripts/setup.sh
./scripts/doctor.sh
```

```powershell
# Windows nativo
git clone https://github.com/MatheusSlvRibeiro/harness-engineering "$HOME\harness-engineering"
cd "$HOME\harness-engineering"
.\scripts\setup.ps1
.\scripts\doctor.ps1
```

O setup faz, idempotentemente:

1. Valida dependências base.
2. Cria junction (Windows) / symlink (Unix) `~/.claude/skills/harness` → `<repo>/skills/`, e o diretório `~/.claude/skills/captured/` para skills evoluídas.
3. Instala **RTK** via Homebrew, instalador upstream ou cargo (com fallback).
4. Instala **MemPalace** (`uv tool install mempalace`) e **OpenSpace** (`uv tool install git+https://github.com/HKUDS/OpenSpace.git`); escreve `~/.claude/mcp.json` com ambos.
5. Roda `doctor` no fim para confirmar tudo OK.

**Reinicie o Claude Code** depois do setup para as skills serem carregadas.

---

## Criando um projeto novo

```bash
cd ~/projects/meu-projeto-novo
# Abra o Claude Code aqui e cole o conteúdo de:
#   ~/harness-engineering/bootstrap/prompt.md
# como primeira mensagem.
```

A entrevista de bootstrap:
- Pergunta o modo (single-repo / umbrella / sub-repo).
- Em projeto existente, analisa o código e pré-preenche o que conseguir inferir.
- Pergunta lacunas em lote, marca `> [TBD: <pergunta>]` no que ainda não dá pra responder.
- Copia os skeletons de [`templates/`](templates/) para `.gsd/` e `.harness/`:

  ```
  templates/SPEC.md             → .gsd/SPEC.md
  templates/STACK.md            → .gsd/STACK.md
  templates/ROADMAP.md          → .gsd/ROADMAP.md
  templates/feature_list.json   → .harness/feature_list.json
  templates/baseline.json       → .harness/baseline.json
  ```
- No fim, opcionalmente sincroniza ROADMAP → GitHub (Project, milestones, issues).

> Note que **não existe mais `.gsd/CONVENTIONS.md`** na v2 — convenções de código vêm da skill `stack-<archetype>` que combina com a stack (`stack-react-vite-scss`, `stack-django-drf-jwt`, etc.). A entrevista identifica o archetype e registra em `STACK.md`.

---

## Migrando um projeto v1 → v2

Guia passo a passo: [`docs/harness-v2/migration.md`](docs/harness-v2/migration.md).

TL;DR: criar branch dedicada, salvar convenções customizadas como drawers no MemPalace, trocar AGENTS.md pela versão slim, atualizar STACK.md com o archetype, apagar 4 arquivos v1 redundantes, reiniciar Claude, smoke test, PR.

---

## O que tem no repo

```
harness-engineering/
├── AGENTS.md                 # 42 linhas — aponta para skills (era 446 na v1)
├── CLAUDE.md                 # @AGENTS.md
├── skills/                   # skills carregadas via junction
│   ├── harness-index/        # tabela "para fazer X, leia skill Y"
│   ├── workflow-*/           # branching, commits, issues, prs, project-board
│   ├── ratchet-feature-list/ # contrato dev↔QA
│   ├── stack-*/              # archetypes (react-vite-scss, django-drf-jwt)
│   ├── memory-palace/        # wings/rooms/drawers do MemPalace
│   └── evolving-skills/      # FIX/DERIVED/CAPTURED do OpenSpace
├── bootstrap/
│   └── prompt.md             # bootstrap slim (137 linhas; era 219 na v1)
├── templates/                # skeletons que projeto novo copia
│   ├── SPEC.md  STACK.md  ROADMAP.md
│   ├── feature_list.json  baseline.json
├── scripts/
│   ├── setup.{sh,ps1}        # setup global por máquina (v2)
│   ├── doctor.{sh,ps1}       # validação do ambiente (v2)
│   ├── check-harness.sh      # validador feature_list/baseline (v1+v2)
│   ├── harness-init.sh       # bootstrap v1 (legado)
│   └── harness-sync.sh       # sync v1 (legado)
├── umbrella/                 # docs/templates do modo umbrella
└── docs/harness-v2/          # arquitetura e guia de migração
    ├── overview.md
    └── migration.md
```

---

## Modo de workspace

Por padrão: **single-repo** — um repo Git, uma stack, skills carregadas globalmente. É o que cobre 99% dos casos (incluindo todos os usos solo).

> **Modos avançados (umbrella / sub-repo).** Time que compartilha produto entre vários repos Git independentes e precisa de `PRODUCT.md`/`INTEGRATION.md` versionados na raiz do workspace. Para uso solo cross-projeto, **MemPalace cobre o papel** com busca semântica — basta wing por projeto. Detalhe em [`bootstrap/prompt.md`](bootstrap/prompt.md), seção "Modo avançado".

---

## Workflow dia a dia

Skills cobrem o detalhe. Resumo:

| Disciplina | Skill |
| --- | --- |
| Branching (`feat/*` → `preview` → `main`) | `workflow-branching` |
| Commits (Conventional Commits, inglês, ≤72 chars) | `workflow-commits` |
| Issues (template, marcador `Task: <MID>-<SID>-<TID>`) | `workflow-issues` |
| PRs (`Closes #N`, validação verde, base = `preview`) | `workflow-prs` |
| Project board (6 colunas: Backlog→Done) | `workflow-project-board` |
| Feature list e baseline (ratchet de qualidade) | `ratchet-feature-list` |
| Memória cross-projeto (decisões, postmortems) | `memory-palace` |
| Skills auto-evolutivas (curated × evolved, promoção) | `evolving-skills` |

Invoque `harness-index` no início da sessão quando estiver em dúvida do roteamento.

---

## Conceitos que valem entender

- **Skills auto-carregadas vs slash commands.** As skills do harness são auto-descobertas pelo Claude Code (frontmatter sempre visível, body sob demanda). Não são slash commands — Claude invoca quando o `description` bate com a tarefa.
- **Curated × evolved.** Skills curadas vivem no repo (versionadas, revisadas em PR). Skills evoluídas pelo OpenSpace vivem em `~/.claude/skills/captured/` (untracked). Promoção de evolved para curated é deliberada, via PR — não default. Detalhes em `evolving-skills`.
- **Decisão do projeto sempre ganha da skill genérica.** A skill `stack-*` é guia padrão. Se o projeto explicitamente decidiu diferente, registre como drawer no MemPalace (room `decisions`); a regra universal "search antes de decidir" no AGENTS.md faz o agente encontrar a decisão e respeitá-la.
- **Vagueza é o inimigo.** A entrevista de bootstrap faz pushback em respostas vagas porque specs vagos geram código vago.
- **TBD é permitido.** Melhor marcar algo desconhecido do que inventar resposta errada.

---

## Troubleshooting

**As skills do harness não aparecem na lista de skills disponíveis.**
Claude Code não rescaneia mid-session. Saia e abra de novo (ou reinicie a IDE). Confirme com `./scripts/doctor.sh` que `~/.claude/skills/harness/` existe.

**`doctor` reclama de RTK / MemPalace / OpenSpace.**
Rode `./scripts/setup.sh` (idempotente). Para reinstalar uma só: `uv tool upgrade mempalace` / `uv tool upgrade openspace` / `brew upgrade rtk`.

**Migrar um projeto v1 quebrou alguma decisão customizada.**
Você pulou o passo 2 do guia (salvar drawer no MemPalace antes de apagar `CONVENTIONS.md`). Rollback: `git checkout preview && git branch -D chore/harness-v2-migration`. Refaça lendo o guia com calma.

**Stack inusual sem archetype matching (Rust+Axum, Go+Echo, Elixir+Phoenix...).**
OK. Em `.gsd/STACK.md`, deixe "Archetype skill correspondente: nenhum ainda — convenções emergem via OpenSpace (skill `evolving-skills`)". As regras universais (workflow, ratchet, memória) continuam funcionando agnósticas de stack.

**Quero criar uma skill nova específica do meu projeto.**
Para um padrão recorrente que vale só num projeto, deixe o OpenSpace capturar via uso (CAPTURED). Quando provar valor, promova manualmente para `skills/` aqui no repo do harness via PR (ver `evolving-skills`, seção "Promovendo CAPTURED → curated").
