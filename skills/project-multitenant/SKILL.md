---
name: project-multitenant
description: Archetype de projeto para SaaS multi-tenant — React + Django + PostgreSQL + JWT via cookie httpOnly. Invoque no início de um projeto novo desse tipo, ou quando o dev perguntar "que stack usamos pra isso" e o projeto for um SaaS com múltiplos clientes/organizações.
---

# Projeto: Multi-tenant SaaS

Combinação de stack para produtos SaaS com múltiplos tenants (organizações/clientes isolados).
Este skill **não redefine convenções de código** — elas moram nos skills `stack-*` linkados abaixo.
Aqui vive só a decisão de *quais* peças combinar e *por quê*.

## Peças da stack

| Camada | Escolha | Convenções em |
| --- | --- | --- |
| Frontend | React 18 + Vite + TypeScript + SCSS Modules (BEM) | `stack-react-vite-scss` |
| Formulários | React Hook Form + zod | `stack-react-vite-scss` → [reference/aliases-and-forms.md](../stack-react-vite-scss/reference/aliases-and-forms.md) |
| Tabelas | TanStack Table | [reference/tables.md](reference/tables.md) |
| Backend | Django 5 + DRF | `stack-django-drf-jwt` |
| Banco | PostgreSQL | `stack-django-drf-jwt` |
| Autenticação | JWT via cookie httpOnly | `stack-django-drf-jwt` → [reference/auth-and-models.md](../stack-django-drf-jwt/reference/auth-and-models.md) |
| Frontend ↔ cookie auth | fetch/axios com credentials + header CSRF | [reference/frontend-auth.md](reference/frontend-auth.md) |

## Por que esta combinação

- **Django + PostgreSQL**: modelagem relacional rica (tenants, planos, permissões por org) é o forte
  do Django ORM; produtividade alta pra CRUD administrativo que todo SaaS tem.
- **Cookie httpOnly em vez de header Bearer**: o frontend é sempre a própria SPA servida pelo mesmo
  produto — não há cliente third-party consumindo a API. Cookie httpOnly fecha a superfície de XSS
  que rouba token de `localStorage`, que é o vetor mais comum contra SPAs autenticadas.
- **TanStack Table em vez de montar tabela na mão**: SaaS multi-tenant quase sempre tem telas de
  listagem densa (usuários da org, faturas, logs) com sort/filtro/paginação — reimplementar isso por
  tela é o tipo de esforço que não deveria variar de projeto pra projeto.

## Regra inegociável específica deste archetype

- Todo model, queryset e endpoint que retorna dado de tenant **filtra por tenant/organização** — não
  existe endpoint "global" que um usuário de um tenant possa usar pra enxergar dado de outro. Isso é
  além do filtro por usuário já exigido em `stack-django-drf-jwt`.

## Skills relacionadas

- Frontend: `stack-react-vite-scss`
- Backend: `stack-django-drf-jwt`
- Fluxo de issue, branch e PR: `workflow-branching`, `workflow-prs`, `workflow-issues`
- Feature list e baseline: `ratchet-feature-list`
