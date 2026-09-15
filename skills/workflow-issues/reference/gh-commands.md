# Mover issue entre colunas via gh

Referência de `workflow-issues`. Volte ao [índice](../SKILL.md) para o quando-invocar.

```bash
# Listar items do project para achar o item-id da issue
gh project item-list <project-number> --owner <owner> --format json

# Editar o status
gh project item-edit \
  --project-id <project-node-id> \
  --id <item-id> \
  --field-id <status-field-id> \
  --single-select-option-id <option-id-da-coluna-destino>
```

(Os IDs ficam estáveis por projeto. Em projetos novos, capture-os no bootstrap e guarde em `.gsd/STACK.md` na seção "Notas".)
