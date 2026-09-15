# Template de issue

Referência de `workflow-issues`. Volte ao [índice](../SKILL.md) para o quando-invocar.

Toda issue do harness precisa ter estas seções (template em `.github/ISSUE_TEMPLATE/default.md`):

```markdown
Task: M01-S02-T01     ← primeira linha, marcador para sincronia ROADMAP↔GitHub

## Descrição
Sobre o que é esta issue. Um parágrafo curto, linguagem direta.

## Situação atual
O que existe hoje. O que está faltando ou quebrado.

## O que implementar
Descrição detalhada da solução esperada. Especifique arquivos, funções, comportamento.

## Escopo
- [ ] Backend
- [ ] Frontend
- [ ] Ambos

## Feature(s)
IDs de feature do `.harness/feature_list.json` que esta issue implementa ou verifica.
Vazio se for trabalho puramente de tooling/chore sem feature de usuário.

- F001
- F002

## Critérios de aceitação
Checklist. Só vira Done quando todo item está marcado.

- [ ] Critério um (específico e verificável)
- [ ] Critério dois
- [ ] Comando de validação do projeto passa
- [ ] Todas features linkadas em `.harness/feature_list.json` têm `implemented: true` (dev) e `verified: true` (QA)
- [ ] Nenhuma métrica em `.harness/baseline.json` regrediu
- [ ] PR referencia esta issue com `Closes #N`
```
