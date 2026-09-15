# Mover issue entre colunas

Referência de `workflow-project-board`. Volte ao [índice](../SKILL.md) para o quando-invocar.

```bash
gh project item-edit \
  --project-id <project-node-id> \
  --id <item-id> \
  --field-id <status-field-id> \
  --single-select-option-id <option-id-da-coluna-destino>
```

Capture os IDs estáveis no bootstrap e guarde em `.gsd/STACK.md` (seção "Notas") para reutilizar.
