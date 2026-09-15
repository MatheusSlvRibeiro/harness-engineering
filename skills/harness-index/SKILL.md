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
| Iniciar projeto novo, ou "que stack usamos pra isso" | ver tabela de archetypes abaixo |
| Código frontend (React, Vite, SCSS, RHF, zod, BEM, aliases) | `stack-react-vite-scss` |
| Código frontend (React, Vite, Tailwind, RHF, zod, aliases) | `stack-react-tailwind` |
| Código backend (Django, DRF, JWT via cookie httpOnly) | `stack-django-drf-jwt` |
| Código backend (Node.js, Fastify, zod) | `stack-node-fastify` |
| Memória cross-projeto (wings/rooms/drawers, MemPalace) | `memory-palace` |
| Skills auto-evolutivas (FIX/DERIVED/CAPTURED, OpenSpace) | `evolving-skills` |

## Archetypes de projeto — quais stacks combinar

Um `project-*` é o ponto de entrada de um projeto novo: diz *quais* skills `stack-*` combinar e
*por quê*. As convenções de código em si continuam só nos skills `stack-*` — o archetype não as
duplica.

| Tipo de projeto | Invoque | Combina |
| --- | --- | --- |
| SaaS multi-tenant (React + Django + Postgres) | `project-multitenant` | `stack-react-vite-scss` + `stack-django-drf-jwt` |
| SPA leve (React + Tailwind + API mínima) | `project-spa` | `stack-react-tailwind` + `stack-node-fastify` |
| Bots / workers assíncronos | ainda não definido | — |
