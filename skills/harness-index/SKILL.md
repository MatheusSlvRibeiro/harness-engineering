---
name: harness-index
description: Índice das skills do harness-engineering. Carrega regras universais (branches preview/main, sessões dev/QA, validação antes de commit) e aponta para skills específicas (workflow-*, stack-*, ratchet-*). Invoque sempre que iniciar uma sessão em projeto que contém .gsd/ ou .harness/, ou quando o dev mencionar "harness".
---

# Harness Index

Você está em um projeto que usa o **harness-engineering**. Este índice descreve quando invocar cada skill específica e aponta para as regras universais.

## Referência

O harness organiza desenvolvimento em **sessões** restritas por contratos legíveis por máquina:

| Sessão | Lê | Escreve |
| --- | --- | --- |
| **Dev** | issue, `.harness/feature_list.json`, `.harness/baseline.json`, `.gsd/` | código, vira `implemented: true`, atualiza baseline se métricas melhoraram |
| **QA**  | AGENTS.md, STACK.md, CONVENTIONS.md, feature_list.json | vira `verified: true` **somente** depois de rodar cada critério contra a app viva |

A separação impede que o QA seja "convencido" pela sessão dev — ele só checa critérios literais do `feature_list.json`.

## Regras universais (todas as sessões)

- O comando de validação do projeto (ver `.gsd/STACK.md`) precisa passar antes de cada commit.
- Sem `any`/escape hatches no type system. Sem código comentado em commits. Sem debug prints.
- Conteúdo de documentação em **português-BR**. Identificadores técnicos (tipo de commit, slug de branch, label de issue) em **inglês**.
- No fim de cada sessão, **mostre ao dev** o conteúdo atualizado de `.gsd/progress/<MID>-<SID>.md` para ele colar manualmente. Você **não** escreve sozinho em `.gsd/` fora do bootstrap inicial.
- Antes de qualquer trabalho com issue/branch/PR, verifique se o GitHub Project existe — se não, invoque `workflow-project-board` para criar.
- No início de toda sessão, execute o ritual de abertura (`session-rituals` → wake-up + search direcionado). Antes de propor decisão arquitetural, search antes — se há decisão prévia, exponha-a literalmente.
- No fim de toda sessão (sinalizado pelo dev), execute o ritual de fechamento (recap de decisões → drawers explícitos → progress log).

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
| Rituais de início/fim de sessão (wake-up, search, drawer recap) | `session-rituals` |
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
