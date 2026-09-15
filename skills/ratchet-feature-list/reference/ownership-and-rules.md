# Quem escreve o quê e regras inegociáveis

Referência de `ratchet-feature-list`. Volte ao [índice](../SKILL.md) para o quando-invocar.

## Quem escreve o quê

| Quem | Escreve | Não pode |
| --- | --- | --- |
| **Dev** | código, `implemented: true`, atualizar `baseline.json` se métricas melhoraram | editar `title`/`criteria[]` de feature existente, virar `verified: true`, baixar métrica do baseline sem motivo no build log |
| **QA** | `verified: true` (ou notas em falha), atualizar progresso | implementar código, "concordar" com o dev sem rodar critérios contra a app viva |

## Regras inegociáveis

- `title` e `criteria[]` de uma feature ficam **congelados** após a issue ser aberta. Se o requisito mudar de verdade: feche a feature e crie uma nova com novo ID.
- PR **não pode mergear** em `preview` enquanto qualquer feature linkada tiver `verified: false`.
- Nenhuma métrica em `baseline.json` pode regredir sem motivo documentado no body do PR e no build log do mesmo PR.
- Sessão dev **nunca** vira `verified: true` — isso é só de QA.
- Todo PR voltado para usuário precisa linkar ao menos um feature ID; PRs de chore/tooling/refactor podem não ter nenhum.

## Por que duas sessões, dois arquivos

A sessão QA **não tem memória** da conversa do dev. Ela não pode ser "convencida" — só consegue ler o texto literal de `criteria[]` e tentar reproduzir contra a app viva. Isso impede falsos positivos onde o dev pensa que entregou mas faltou algo.
