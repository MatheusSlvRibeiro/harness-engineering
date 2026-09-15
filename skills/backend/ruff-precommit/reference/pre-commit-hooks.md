# pre-commit framework + commitlint + CI

Referência de `ruff-precommit`. Volte ao [índice](../SKILL.md) para o quando-invocar.

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.6.9
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
  - repo: https://github.com/alessandrojcm/commitlint-pre-commit-hook
    rev: v9.16.0
    hooks:
      - id: commitlint
        stages: [commit-msg]
        additional_dependencies: ['@commitlint/config-conventional']
```

```bash
pip install pre-commit
pre-commit install --hook-type pre-commit --hook-type commit-msg
```

```js
// commitlint.config.js — mesmo arquivo/convenção usada no lado frontend, se o repo tiver os dois
export default { extends: ['@commitlint/config-conventional'] };
```

- `pre-commit install` precisa rodar uma vez por clone (documentar no `STACK.md` → "Setup do zero"
  do projeto) — sem isso o hook simplesmente não existe na máquina do dev.
- `args: [--fix]` só no hook local; o job de CI chama `ruff check` (sem `--fix`) + `ruff format
  --check` para **falhar**, não reescrever.

```yaml
# .github/workflows/ci.yml (job de lint — testes ficam em backend/django-drf → testing.md)
- run: pip install ruff
- run: ruff check .
- run: ruff format --check .
```
