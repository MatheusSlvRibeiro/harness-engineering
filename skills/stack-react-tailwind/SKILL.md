---
name: stack-react-tailwind
description: Archetype frontend React 18 + Vite + TypeScript + Tailwind CSS + React Hook Form + zod + path aliases. Invoque ao criar componente, form, rota, configurar alias, escrever teste, ou ao iniciar qualquer projeto SPA leve que usa esta stack.
---

# Stack: React + Vite + Tailwind

Archetype para projetos **React 18 + Vite + TypeScript + Tailwind CSS**. Sem SCSS, sem BEM — classes
utilitárias direto no JSX.
Formulários: **React Hook Form (RHF) + zod**, mesma convenção de `stack-react-vite-scss`.

> Usado pelo archetype de projeto `project-spa`. Se o projeto precisa de tabela densa com
> sort/filtro/paginação, isso normalmente é sinal de que não é uma SPA leve — considere
> `project-multitenant` em vez deste archetype.

## Referência

| Arquivo | Conteúdo |
| --- | --- |
| [reference/folder-structure.md](reference/folder-structure.md) | Estrutura de pastas |
| [reference/styling.md](reference/styling.md) | Convenção Tailwind, `cn()`/variantes, quando extrair componente |
| [reference/aliases-and-forms.md](reference/aliases-and-forms.md) | Path aliases (`@/`), formulários com React Hook Form + zod |
| [reference/types-and-env.md](reference/types-and-env.md) | Regras de type safety, variáveis de ambiente `VITE_*` |
| [reference/testing.md](reference/testing.md) | Vitest + Testing Library, configuração mínima |

## Regras inegociáveis

- Sem `any`. Sem CSS custom fora do necessário (só via `@layer` no `index.css` para o que Tailwind
  não cobre — ex.: reset, fontes).
- Sem classe utilitária repetida 3+ vezes entre componentes sem virar variante (`cva`) ou componente.
- `@/` em vez de paths relativos com `../../`.
- Schema zod para todo input externo (forms, resposta de API, params de URL) — tipo e mensagem de
  erro moram no schema, nunca inline no `.tsx`.
- Componente de form é só estrutura (hook + JSX + submit); zero `interface`/`type` de dado externo e
  zero validação manual dentro dele.
- Toda função em `src/lib/` tem teste correspondente.
- Componente sobe para `src/components/` só quando há 2+ usos reais.
- Export nomeado para componentes não-page.

## Skills relacionadas

- Fluxo de issue, branch e PR: `workflow-branching`, `workflow-prs`, `workflow-issues`
- Feature list e baseline: `ratchet-feature-list`
- Backend: `stack-node-fastify`
- Archetype de projeto: `project-spa`
