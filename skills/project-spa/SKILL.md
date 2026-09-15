---
name: project-spa
description: Archetype de projeto para SPA leve — React + Tailwind + Node/Fastify quando a API é pequena (formulários, integrações simples, sem modelagem relacional pesada). Invoque no início de um projeto novo desse tipo, ou quando o dev perguntar "que stack usamos pra isso" e o backend for pouco mais que um handler de formulário.
---

# Projeto: SPA leve

Combinação de stack para produtos que são essencialmente frontend — o backend existe só pra cobrir o
que o browser não pode fazer sozinho (enviar email, assinar um webhook, proxy autenticado pra uma API
terceira). Este skill **não redefine convenções de código** — elas moram nos skills atômicos
`frontend/*` e `backend/*` linkados abaixo. Aqui vive só a decisão de *quais* peças combinar e *por
quê*.

## Peças da stack

| Camada | Escolha | Convenções em |
| --- | --- | --- |
| Componentes | React 18 + Vite + TypeScript | `frontend/react`, `frontend/typescript`, `frontend/vite` |
| Estilo | Tailwind CSS | `frontend/tailwind` |
| Formulários | React Hook Form + zod | `frontend/react-hook-form-zod` |
| Testes (frontend) | Vitest + Testing Library | `frontend/vitest-testing-library` |
| Backend | Node.js + Fastify + TypeScript | `backend/fastify` |
| Validação de API | zod (mesma lib do frontend, mesmo mental model) | `backend/fastify` → [reference/routes-and-validation.md](../backend/fastify/reference/routes-and-validation.md) |

## Por que esta combinação

- **Tailwind em vez de SCSS Modules**: SPA leve tende a ter poucas telas e iterar rápido em cima de
  um design já pronto (Figma/biblioteca de componentes) — utilitário no JSX é mais rápido pra isso do
  que manter arquivo `.module.scss` por componente. Se o projeto crescer pra dezenas de telas com
  design system próprio, reavalie — `frontend/scss-bem` não é proibido aqui, é só não o padrão.
- **Node/Fastify em vez de Django**: o backend não tem modelagem relacional — é um punhado de rotas
  sem estado ou com estado trivial. Usar a mesma linguagem do frontend (TypeScript) reduz o custo de
  troca de contexto pra um time pequeno, e Fastify tem overhead de setup bem menor que um projeto
  Django completo pra esse tamanho de escopo.
- **Sem JWT/sessão obrigatória**: diferente do `project-multitenant`, esse archetype não assume
  usuário autenticado por padrão — se o projeto precisar de login, isso é sinal de que o escopo
  cresceu; reavalie se `project-multitenant` não é o archetype certo antes de empilhar auth em cima do
  Fastify.

## Quando este archetype NÃO é o certo

- API vai crescer com entidades relacionadas, permissões por usuário/organização, ou telas de
  administração densas → `project-multitenant`.
- Precisa de fila/worker assíncrono, múltiplos serviços coordenados → considere o archetype de bots
  (ainda não definido — ver `harness-index`).

## Skills relacionadas

- Fluxo de issue, branch e PR: `workflow-branching`, `workflow-prs`, `workflow-issues`
- Feature list e baseline: `ratchet-feature-list`
