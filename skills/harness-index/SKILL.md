---
name: harness-index
description: Índice das skills do harness-engineering. Carrega regras universais (branches preview/main, sessões dev/QA, validação antes de commit) e aponta para skills específicas (workflow-*, stack-*, ratchet-*). Invoque sempre que iniciar uma sessão em projeto que contém .gsd/ ou .harness/, ou quando o dev mencionar "harness".
---

# Harness Index

Você está em um projeto que usa o **harness-engineering**. Este índice descreve quando invocar cada skill específica e aponta para as regras universais.

## Referência

| Arquivo | Conteúdo |
| --- | --- |
| [reference/how-it-works.md](reference/how-it-works.md) | Sessões dev/QA, o que cada uma lê e escreve |
| [reference/universal-rules.md](reference/universal-rules.md) | Regras que valem em toda sessão (validação, idioma, escrita restrita, MemPalace) |
| [reference/project-config-and-progress.md](reference/project-config-and-progress.md) | Onde buscar config do projeto (`.gsd/`, `.harness/`) e como acompanhar progresso |

## Skills específicas — quando invocar cada

| O dev pediu… | Invoque |
| --- | --- |
| Criar branch, naming, hierarquia preview/main | `workflow-branching` |
| Abrir issue, template, ciclo Backlog→Done | `workflow-issues` |
| Abrir PR, `Closes #N`, validação | `workflow-prs` |
| Mensagem de commit (Conventional Commits) | `workflow-commits` |
| GitHub Project (6 colunas, criar via gh, sincronia ROADMAP) | `workflow-project-board` |
| Adicionar feature, atualizar baseline, ratchet | `ratchet-feature-list` |
| Código frontend (React, Vite, SCSS, RHF, zod, BEM, aliases) | `stack-react-vite-scss` |
| Código backend (Django, DRF, JWT) | `stack-django-drf-jwt` |
| Memória cross-projeto (wings/rooms/drawers, MemPalace) | `memory-palace` |
| Skills auto-evolutivas (FIX/DERIVED/CAPTURED, OpenSpace) | `evolving-skills` |
