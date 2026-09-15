# Ciclo de vida e regras

Referência de `workflow-issues`. Volte ao [índice](../SKILL.md) para o quando-invocar.

## Ciclo de vida no Project

| Coluna | Quando |
| --- | --- |
| Backlog | Issue criada, ainda não avaliada |
| Ready | Avaliada, clara o bastante para começar |
| Priority | Ready e deve ser pegada em seguida |
| In Progress | Branch criada, em trabalho ativo |
| In Review | PR aberta, esperando revisão do orquestrador |
| Done | PR mergeada em preview, issue fechada |

## Regras

- Issue nunca vai para **In Review** sem PR aberta.
- Issue nunca vai para **Done** sem PR mergeada.
- Issue criada pela sincronia ROADMAP→GitHub carrega `Task: <MID>-<SID>-<TID>` na primeira linha do body (rastreável; impede duplicata).
- Issue criada manualmente também deve adicionar `Task:` se cobrir uma task do ROADMAP.
- Antes de começar a trabalhar em uma issue, mova-a para In Progress.
