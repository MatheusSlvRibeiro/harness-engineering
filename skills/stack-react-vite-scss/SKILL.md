---
name: stack-react-vite-scss
description: Archetype frontend React 18 + Vite + TypeScript + SCSS Modules + React Hook Form + zod + BEM + path aliases. Invoque ao criar componente, form, rota, configurar alias, escrever teste, ou ao iniciar qualquer projeto que usa esta stack.
---

# Stack: React + Vite + SCSS

Archetype para projetos **React 18 + Vite + TypeScript + SCSS Modules**.
Formulários: **React Hook Form (RHF) + zod**. Convenção de CSS: **BEM dentro de SCSS Modules**.

## Referência

| Arquivo | Conteúdo |
| --- | --- |
| [reference/folder-structure.md](reference/folder-structure.md) | Estrutura de pastas, regra de colocação (quando promover para pasta compartilhada) |
| [reference/components-and-styling.md](reference/components-and-styling.md) | Convenção de componente, BEM + SCSS Modules, SCSS global |
| [reference/aliases-and-forms.md](reference/aliases-and-forms.md) | Path aliases (`@/`), formulários com React Hook Form + zod |
| [reference/types-and-env.md](reference/types-and-env.md) | Regras de type safety, variáveis de ambiente `VITE_*` |
| [reference/testing.md](reference/testing.md) | Vitest + Testing Library, configuração mínima |

## Regras inegociáveis

- Sem `any`. Sem inline styles. Sem import de CSS global dentro de componente.
- `@/` em vez de paths relativos com `../../`.
- Schema zod para todo input externo (forms, resposta de API, params de URL) — tipo e mensagem de erro moram no schema, nunca inline no `.tsx`.
- Componente de form é só estrutura (hook + JSX + submit); zero `interface`/`type` de dado externo e zero validação manual dentro dele.
- Toda função em `src/lib/` tem teste correspondente.
- Componente sobe para `src/components/` só quando há 2+ usos reais.
- Export nomeado para componentes não-page (facilita tree-shaking e grep).

## Skills relacionadas

- Fluxo de issue, branch e PR: `workflow-branching`, `workflow-prs`, `workflow-issues`
- Feature list e baseline: `ratchet-feature-list`
- Backend: `stack-django-drf-jwt`
- Archetype de projeto: `project-multitenant`
