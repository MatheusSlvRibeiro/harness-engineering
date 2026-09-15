---
name: workflow-project-board
description: Bootstrap do GitHub Project (6 colunas padrão), sincronia ROADMAP → milestones/issues, e automação via gh CLI. Invoque quando o dev pedir para criar project, sincronizar roadmap, mover issue de coluna, configurar campos, ou diagnosticar "project ausente".
---

# Workflow: GitHub Project board

## Referência

| Arquivo | Conteúdo |
| --- | --- |
| [reference/bootstrap.md](reference/bootstrap.md) | Verificação inicial, criar project do zero, campos padrão, 6 colunas |
| [reference/roadmap-sync.md](reference/roadmap-sync.md) | Sincronia determinística ROADMAP → milestones/issues, regras, resumo ao dev |
| [reference/moving-columns.md](reference/moving-columns.md) | Comando `gh project item-edit` para mover issue entre colunas |

## Skills relacionadas

- Template de issue: `workflow-issues`
- Criar branch a partir de issue: `workflow-branching`
- Abrir PR: `workflow-prs`
