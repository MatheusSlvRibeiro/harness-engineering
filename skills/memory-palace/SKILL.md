---
name: memory-palace
description: Convenção de uso do MemPalace (memória local-first, verbatim, busca semântica) dentro do harness. Define wings/rooms/drawers, cadência (wake-up, search, mine, sweep) e o que vale guardar vs ruído. Invoque no início de qualquer sessão (para puxar contexto cross-projeto), ao tomar decisão arquitetural (para registrar), ou ao terminar sessão (para indexar).
---

# Memory Palace

O **MemPalace** é uma memória local-first com busca semântica que **não resume nem parafraseia** — guarda *verbatim*. O índice tem estrutura: **wings** (escopo top-level), **rooms** (tópicos) e **drawers** (memórias literais).

Tudo fica em `~/.mempalace/` por padrão. Nada sai da máquina sem opt-in.

## Referência

| Arquivo | Conteúdo |
| --- | --- |
| [reference/concepts.md](reference/concepts.md) | Palace/wing/room/drawer, wings convencionadas, rooms padrão |
| [reference/cadence-and-content.md](reference/cadence-and-content.md) | Cadência de uso, o que vira drawer vs ruído, search antes de decidir |
| [reference/mcp-tools-and-rules.md](reference/mcp-tools-and-rules.md) | Tools MCP mais usadas, regras inegociáveis |

## Skills relacionadas

- Índice geral e quando invocar cada skill: `harness-index`
- Convenções de stack (decisões podem migrar pra cá quando viram regra): skills atômicos `frontend/*`/`backend/*` e archetypes `project-multitenant`/`project-spa`
- Acompanhamento de progresso (fica em `.gsd/`, não no palace): `harness-index`
