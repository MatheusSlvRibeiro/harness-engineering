---
name: eslint-prettier-husky
description: Lint, format e git hooks para projetos frontend — ESLint + Prettier + Husky + lint-staged + commitlint. Invoque ao configurar um projeto novo, ao adicionar uma regra de lint, ou quando um commit passar sem lint/format ter rodado.
---

# ESLint + Prettier + Husky

O conjunto que torna as regras dos outros skills `frontend/*` **verificáveis automaticamente**, em vez
de "combinado de boca" que só um humano lembra de checar. Sem isso, `frontend/typescript` dizer "sem
`any`" é só prosa — com ESLint configurado, é um erro que quebra o commit.

## Referência

| Arquivo | Conteúdo |
| --- | --- |
| [reference/eslint-config.md](reference/eslint-config.md) | Config ESLint (flat config, plugins, regras não-negociáveis) |
| [reference/prettier-config.md](reference/prettier-config.md) | Config Prettier, integração com ESLint |
| [reference/husky-lint-staged.md](reference/husky-lint-staged.md) | Hooks: pre-commit (lint-staged), commit-msg (commitlint), pre-push (typecheck) |

## Regras inegociáveis

- `pre-commit` roda `lint-staged` — só nos arquivos staged, nunca o repo inteiro (evita hook de 40s
  no dia a dia).
- `commit-msg` roda `commitlint` validando contra o formato Conventional Commits de `workflow-commits`
  — mensagem fora do padrão bloqueia o commit, não é revisão manual em PR.
- `pre-push` roda `tsc --noEmit` — ESLint não pega erro de tipo, só Prettier/regras de lint; sem esse
  passo, erro de tipo só aparece no CI (ou pior, em prod).
- O **mesmo** comando que roda no hook roda no CI (`.github/workflows/ci.yml`) — hook é conveniência
  local, CI é o gate real. Nunca configure só um dos dois.
- `--fix`/autoformat roda em `lint-staged`, não em CI — CI só **falha**, nunca reescreve o commit de
  outra pessoa.

## Skills relacionadas

- Regras que o ESLint torna verificáveis: `frontend/typescript`, `frontend/react`
- Formato de commit que o commitlint valida: `workflow-commits`
- Equivalente backend (Python): `backend/ruff-precommit`
