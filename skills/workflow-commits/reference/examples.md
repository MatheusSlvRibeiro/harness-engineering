# Exemplos

Referência de `workflow-commits`. Volte ao [índice](../SKILL.md) para o quando-invocar.

## Bons

```
feat(webhook): add github signature verification
fix(report): handle missing startTime in worked minutes calculation
chore: add vitest configuration
test(lib): add unit tests for calculateWorkedMinutes
refactor(dashboard): extract IssueRow into reusable component
docs(readme): add wsl2 setup instructions
perf(query): index user_id on sessions table
```

## Ruins

```
fix stuff                       ← vago, sem tipo
Adicionado novo componente      ← português, passado
update                          ← nenhuma informação
WIP                             ← nunca commitar WIP em branches publicadas
feat: Added webhook receiver.   ← passado + ponto no fim
feat(webhook): add github signature verification because we found a bug yesterday  ← excede 72 chars
```
