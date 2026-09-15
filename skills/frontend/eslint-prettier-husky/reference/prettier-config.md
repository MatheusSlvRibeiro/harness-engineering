# Config Prettier

Referência de `eslint-prettier-husky`. Volte ao [índice](../SKILL.md) para o quando-invocar.

```json
// .prettierrc
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2
}
```

```
// .prettierignore
dist/
coverage/
*.md
```

- Um `.prettierrc` versionado — nunca configuração de formatação só no editor de cada dev (diverge
  silenciosamente, gera diff de formatação em PR sem relação com a mudança real).
- `.md` no `.prettierignore` por padrão — Prettier reformata Markdown de um jeito que atrapalha texto
  em pt-BR com listas/tabelas; formate manualmente ou desative caso a caso.
- Sem `prettier-ignore` inline espalhado pelo código — se uma regra de formatação está errada pro
  projeto, muda a config, não silencia linha por linha.
