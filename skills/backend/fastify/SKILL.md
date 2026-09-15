---
name: backend/fastify
description: Archetype backend Node.js + Fastify + TypeScript para APIs leves (formulários, integrações simples, sem modelagem relacional pesada). Invoque ao criar rota, plugin, schema de validação ou teste em qualquer projeto que usa esta stack como API.
---

# Fastify

Archetype para APIs **leves** — o caso comum é uma SPA que só precisa de um punhado de endpoints
(receber submissão de form, mandar email, proxy pra um serviço terceiro), não um sistema com
modelagem relacional rica. Quando o backend cresce pra ter dezenas de entidades relacionadas e regras
de negócio complexas, isso é sinal de que o projeto não é mais "SPA leve" — considere
`backend/django-drf` em vez de continuar empilhando em cima do Fastify.

Validação: **zod** via `fastify-type-provider-zod`. Testes: **vitest**.

## Referência

| Arquivo | Conteúdo |
| --- | --- |
| [reference/folder-structure.md](reference/folder-structure.md) | Estrutura de pastas, plugins vs rotas |
| [reference/routes-and-validation.md](reference/routes-and-validation.md) | Schema zod por rota, error handling |
| [reference/env-vars.md](reference/env-vars.md) | Validação de env com zod |
| [reference/testing.md](reference/testing.md) | Vitest + `fastify.inject()` |

## Regras inegociáveis

- Sem `any`. Toda rota tem `schema` (body/params/querystring/response) via zod — sem handler que lê
  `request.body` sem validação.
- Handler de rota é só orquestração (valida → chama service/lib → responde); lógica de negócio, se
  houver, mora em `src/services/`, nunca solta no handler.
- Erros não tratados nunca vazam stack trace pro cliente — `setErrorHandler` centralizado mapeia pra
  resposta JSON consistente (`{ error: { code, message } }`).
- Toda rota tem teste de integração via `app.inject()` — sem mockar o Fastify.
- Env vars validadas no boot (schema zod) — processo derruba na subida se faltar variável obrigatória,
  nunca falha silenciosamente em runtime.
- Rate limiting (`@fastify/rate-limit`) em toda rota pública que aceita submissão de form — é o
  endpoint mais exposto a abuso nesse archetype.

## Skills relacionadas

- Fluxo de issue, branch e PR: `workflow-branching`, `workflow-prs`, `workflow-issues`
- Feature list e baseline: `ratchet-feature-list`
- Frontend: `frontend/react`, `frontend/tailwind`
- Archetype de projeto: `project-spa`
