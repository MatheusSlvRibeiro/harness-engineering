---
name: project-multitenant
description: Archetype de projeto para SaaS multi-tenant — React + Django + PostgreSQL + JWT via cookie httpOnly. Invoque no início de um projeto novo desse tipo, ou quando o dev perguntar "que stack usamos pra isso" e o projeto for um SaaS com múltiplos clientes/organizações.
---

# Projeto: Multi-tenant SaaS

Combinação de stack para produtos SaaS com múltiplos tenants (organizações/clientes isolados).
Este skill **não redefine convenções de código** — elas moram nos skills atômicos `frontend/*` e
`backend/*` linkados abaixo. Aqui vive só a decisão de *quais* peças combinar e *por quê*.

## Peças da stack

| Camada | Escolha | Convenções em |
| --- | --- | --- |
| Componentes | React 18 + Vite + TypeScript | `frontend/react`, `frontend/typescript`, `frontend/vite` |
| Estilo | SCSS Modules + BEM | `frontend/scss-bem` |
| Formulários | React Hook Form + zod | `frontend/react-hook-form-zod` |
| Tabelas | TanStack Table | `frontend/tanstack-table` |
| Testes (frontend) | Vitest + Testing Library | `frontend/vitest-testing-library` |
| Backend | Django 5 + DRF + PostgreSQL | `backend/django-drf` |
| Autenticação | JWT via cookie httpOnly | `backend/jwt-cookie-auth` |
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
- **SCSS Modules + BEM em vez de Tailwind**: SaaS multi-tenant tende a acumular telas de admin
  complexas e às vezes theming por tenant — um arquivo de estilo isolado por componente escala melhor
  pra isso do que classes utilitárias espalhadas. Se o projeto for majoritariamente telas simples,
  reavalie contra `project-spa`.

## Regra inegociável específica deste archetype

- Todo model, queryset e endpoint que retorna dado de tenant **filtra por tenant/organização** — não
  existe endpoint "global" que um usuário de um tenant possa usar pra enxergar dado de outro. Isso é
  além do filtro por usuário já exigido em `backend/django-drf`.

## Skills relacionadas

- Fluxo de issue, branch e PR: `workflow-branching`, `workflow-prs`, `workflow-issues`
- Feature list e baseline: `ratchet-feature-list`
