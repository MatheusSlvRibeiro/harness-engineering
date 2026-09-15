---
name: ruff-precommit
description: Lint, format e git hooks para projetos Python/Django — ruff (lint + format) + pre-commit framework + commitlint. Invoque ao configurar um projeto novo, ao adicionar uma regra de lint, ou quando um commit passar sem lint/format ter rodado.
---

# Ruff + pre-commit

Equivalente Python de `frontend/eslint-prettier-husky`: torna as regras de `backend/django-drf`
verificáveis automaticamente em vez de prosa que só um humano lembra de checar. **Ruff** substitui
black + flake8 + isort + boa parte do bandit num binário só, ordens de magnitude mais rápido que a
combinação antiga.

## Referência

| Arquivo | Conteúdo |
| --- | --- |
| [reference/ruff-config.md](reference/ruff-config.md) | `pyproject.toml`, regras não-negociáveis |
| [reference/pre-commit-hooks.md](reference/pre-commit-hooks.md) | `.pre-commit-config.yaml`, commit-msg, CI |

## Regras inegociáveis

- `ruff check` (lint) e `ruff format` (formatação) — não instale black/flake8/isort junto, é
  trabalho duplicado que pode divergir.
- Hook local roda só nos arquivos staged (`pre-commit` framework já faz isso por padrão) — nunca
  `ruff check .` no repo inteiro em todo commit.
- `commit-msg` valida contra o mesmo formato Conventional Commits de `workflow-commits`.
- O **mesmo** comando que roda no hook roda no CI (`.github/workflows/ci.yml`) — hook é conveniência
  local, CI é o gate real. Nunca configure só um dos dois.
- `ruff check --fix` e `ruff format` rodam no hook local (autofix); CI só roda `ruff check` (sem
  `--fix`) + `ruff format --check` — CI nunca reescreve o commit de outra pessoa.

## Skills relacionadas

- Regras que o ruff torna verificáveis: `backend/django-drf`
- Formato de commit que o hook valida: `workflow-commits`
- Equivalente frontend (TypeScript): `frontend/eslint-prettier-husky`
