# Harness v2 — Visão Geral

Refatoração do harness-engineering para usar **Claude Skills nativas**, **MemPalace** (memória persistente) e **OpenSpace** (skills evolutivas) como base.

> Em curso na branch `feat/harness-v2-skills`. Master continua com o sistema antigo até a Fase 7.

---

## Por que refatorar

O harness v1 funciona, mas tem 3 dores estruturais:

1. **AGENTS.md de ~400 linhas** carregado em toda sessão, mesmo para tarefas que tocam só uma fatia.
2. **Bootstrap longo** (18 perguntas em batch) repetido em todo projeto novo, mesmo quando a empresa só usa 2-3 stacks.
3. **Convenções estáticas** que precisam ser relidas a cada sessão — não evoluem com o uso real.

A v2 ataca isso com três mecanismos:

| Mecanismo | Resolve | Como |
| --- | --- | --- |
| **Claude Skills** (nativo) | AGENTS.md verboso | Tópicos viram skills com frontmatter sempre carregado + body sob demanda. |
| **MemPalace MCP** | Re-entrevista entre projetos | Memória *verbatim* + busca semântica das decisões anteriores. |
| **OpenSpace MCP** | Convenções estáticas | Skills versionadas que evoluem (FIX/DERIVED/CAPTURED) com o uso. |

---

## Arquitetura

```
harness-engineering/                       (este repo)
├── skills/                                ← junction → ~/.claude/skills/harness/
│   ├── harness-index/                     ← AGENTS.md condensado
│   ├── workflow-branching/                ← preview/main, naming
│   ├── workflow-issues/                   ← template, ciclo no project
│   ├── workflow-prs/                      ← Closes #N, validação
│   ├── workflow-commits/                  ← Conventional Commits
│   ├── workflow-project-board/            ← 6 colunas, automação gh
│   ├── ratchet-feature-list/              ← .harness/ contract
│   ├── stack-react-vite-scss/             ← archetype frontend
│   ├── stack-django-drf-jwt/              ← archetype backend (esqueleto)
│   ├── memory-palace/                     ← wings/rooms/drawers, cadência MemPalace
│   ├── session-rituals/                   ← rituais de abertura/fechamento de sessão
│   └── evolving-skills/                   ← FIX/DERIVED/CAPTURED, promoção curated/evolved
├── bootstrap/
│   └── prompt.md                          ← bootstrap slim (entrevista referencia skills)
├── templates/                             ← skeletons que projeto novo copia
│   ├── SPEC.md
│   ├── STACK.md
│   ├── ROADMAP.md
│   ├── feature_list.json
│   └── baseline.json
├── scripts/
│   ├── setup.ps1 / setup.sh               ← instala junction + MCPs
│   ├── doctor.ps1 / doctor.sh             ← valida ambiente
│   ├── harness-init.sh                    ← (legado v1)
│   ├── harness-sync.sh                    ← (legado v1)
│   └── check-harness.sh                   ← validador de feature_list/baseline
├── docs/harness-v2/                       ← documentação do novo sistema
└── AGENTS.md                              ← slim (~40 linhas, aponta para skills)
```

### Onde mora cada coisa

- **Global por máquina, curated** (`~/.claude/skills/harness/` via junction): tudo em `skills/` deste repo.
- **Global por máquina, evolved** (`~/.claude/skills/captured/`): skills auto-geradas pelo OpenSpace (FIX/DERIVED/CAPTURED). Untracked, separadas das curated para evitar poluir o repo. Ver `evolving-skills` para promoção.
- **Global por máquina** (`~/.claude/mcp.json`): MemPalace e OpenSpace.
- **Palace global** (`~/.mempalace/` ou similar): memória *verbatim* de decisões cross-projeto.
- **Workspace do OpenSpace** (`~/.openspace-workspace/`): estado interno do OpenSpace (lineage, métricas de evolução).
- **Local no projeto** (`.gsd/`): apenas o que é único daquele projeto. CONVENTIONS.md some — referencia archetype.
- **Local no projeto** (`.harness/feature_list.json`, `baseline.json`): contrato dev↔QA, mantido como na v1.

---

## Setup por máquina

Cada dev roda **uma vez** na máquina dele:

```powershell
# Windows
git clone <repo-url>
cd harness-engineering
.\scripts\setup.ps1
```

```bash
# Linux/macOS
git clone <repo-url>
cd harness-engineering
./scripts/setup.sh
```

O setup:

1. Valida `git`, `gh`, `python 3.9+`, `uv`, `node`.
2. Cria junction (Windows) / symlink (Unix) `~/.claude/skills/harness` → `<repo>/skills`, e o diretório `~/.claude/skills/captured/` para skills evolved.
3. Instala **RTK** (Rust Token Killer) — CLI proxy que filtra/comprime saída de comandos antes de chegar ao contexto do LLM, reduzindo 60–90% dos tokens em operações comuns (`git status`, `ls`, `pytest`, etc.).
4. Instala MCPs (`uv tool install mempalace` + `uv tool install git+https://github.com/HKUDS/OpenSpace.git`) e escreve `~/.claude/mcp.json` com ambos. OpenSpace é apontado para `~/.claude/skills/captured/` via `OPENSPACE_HOST_SKILL_DIRS`. Baixa também os **hooks de auto-save** do MemPalace (`Stop` + `PreCompact`) para `~/.claude/hooks/mempalace/` e os wira em `~/.claude/settings.json` — sessões passam a indexar transcripts automaticamente, sem precisar lembrar de salvar manualmente.
5. Roda `doctor.ps1` / `doctor.sh` ao final.

**Atualizar skills depois:** `git pull` no repo. Junction continua válida.

**Atualizar MCPs:** `uv tool upgrade mempalace` / `uv tool upgrade openspace`.

**Atualizar RTK:** `brew upgrade rtk` ou rode o instalador upstream novamente.

### Ferramentas recomendadas

| Ferramenta | Papel | Como instalar |
| --- | --- | --- |
| **RTK** (rtk-ai/rtk) | CLI proxy que reduz consumo de tokens do agente em 60–90% | `brew install rtk` ou instalador upstream |
| **MemPalace** | Memória *verbatim* cross-projeto via MCP | `uv tool install mempalace` |
| **OpenSpace** (HKUDS) | Skills evolutivas (FIX/DERIVED/CAPTURED) via MCP | `uv tool install git+https://github.com/HKUDS/OpenSpace.git` |

---

## Fases da refatoração

| Fase | Entrega | Status |
| --- | --- | --- |
| 0 | Setup, doctor, estrutura de pastas, doc | ✅ |
| 1 | 7 skills de workflow | ✅ |
| 2 | `stack-react-vite-scss` completo | ✅ |
| 3 | `stack-django-drf-jwt` esqueleto | ✅ |
| 4 | MemPalace MCP rodando + Wings convencionadas | ✅ |
| 5 | OpenSpace MCP + skills evolutivas | ✅ |
| 6 | Bootstrap refatorado + AGENTS.md slim | ✅ |
| 7 | Migração de projetos existentes | ✅ |

Guia passo-a-passo da migração v1 → v2: [`migration.md`](./migration.md).

---

## Decisões de design

- **Repo único, não dois.** Skills, bootstrap, templates, scripts moram aqui.
- **Junction/symlink em vez de copiar.** Atualização = `git pull`. Sem drift.
- **MCP real, não conceitual.** Vale o setup de 10min por máquina pelo ganho contínuo.
- **Greenfield in-place.** Refatoração na branch `feat/harness-v2-skills`. Master fica intocada até a Fase 7.
- **Django começa como esqueleto.** Convenções amadurecem por CAPTURED conforme o dev decide em projetos reais.
- **Português-BR no conteúdo, inglês nos identificadores técnicos** (`feat`, `fix`, slugs de skill).

---

## Referências

- [MemPalace](https://github.com/mempalace/mempalace) — local-first memory para IA, `mine → search → wake-up → sweep`.
- [OpenSpace (HKUDS)](https://github.com/HKUDS/OpenSpace) — self-evolving skills, FIX/DERIVED/CAPTURED, skill DAG.
- [Claude Code Skills](https://docs.claude.com/en/docs/claude-code/skills) — formato nativo (frontmatter + body).
