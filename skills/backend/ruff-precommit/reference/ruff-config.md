# Config Ruff

Referência de `ruff-precommit`. Volte ao [índice](../SKILL.md) para o quando-invocar.

```toml
# pyproject.toml
[tool.ruff]
line-length = 100
target-version = "py312"

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B", "SIM", "DJ"]  # DJ = flake8-django
ignore = []

[tool.ruff.lint.isort]
known-first-party = ["apps", "config"]

[tool.ruff.format]
quote-style = "single"
```

- `select` inclui `DJ` (regras específicas de Django — ex.: `null=True` em `CharField`, que deveria
  ser `blank=True`) e `B` (bugbear — pega mutable default argument e outras pegadinhas comuns).
- `I` (isort) substitui isort standalone — import fora de ordem já quebra o lint, não precisa de
  ferramenta separada.
- Regra nova em `backend/django-drf` que é mecanicamente checável (ex.: "sem `fields = '__all__'`")
  → considere uma regra custom ou `# noqa` documentado, não só prosa no skill.
