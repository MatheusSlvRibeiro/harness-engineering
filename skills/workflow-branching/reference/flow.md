# Fluxo completo do dev

Referência de `workflow-branching`. Volte ao [índice](../SKILL.md) para o quando-invocar.

```
issue criada (Backlog)
   ↓
issue priorizada (Ready → Priority)
   ↓
branch criada a partir de preview
   ↓
issue movida para In Progress (gh project item-edit)
   ↓
trabalho local → comando de validação do projeto passa
   ↓
commit(s) → push → PR feat/* → preview
   ↓
issue movida para In Review
   ↓
PR aprovado → merge → preview deployado e validado
   ↓
PR de preview → main (aprovação do senior)
   ↓
PR aprovado → merge → main deployado
   ↓
issue movida para Done
```
