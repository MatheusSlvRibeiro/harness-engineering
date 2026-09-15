# Título e body

Referência de `workflow-prs`. Volte ao [índice](../SKILL.md) para o quando-invocar.

## Quando abrir cada tipo de PR

- **`feat/*` (ou `fix/*`, `chore/*`, etc.) → `preview`**: obrigatório antes de mover issue para In Review.
- **`preview` → `main`**: obrigatório antes de deployar para produção. Aprovação do senior necessária.

## Título do PR

Mesmo formato de Conventional Commits (ver `workflow-commits`):

```
feat(webhook): add github signature verification
fix(report): handle missing startTime
chore: add vitest configuration
```

- Em inglês, lowercase, sem ponto no fim.
- Máximo 72 caracteres.

## Body do PR

```markdown
## Summary
- <ponto 1 do que mudou>
- <ponto 2>

## Test plan
- [ ] <passo 1 de teste manual ou automatizado>
- [ ] <passo 2>
- [ ] Comando de validação do projeto passou
- [ ] Nenhuma métrica em `.harness/baseline.json` regrediu

Closes #<numero>
Closes #<outro-numero-se-houver>
```
