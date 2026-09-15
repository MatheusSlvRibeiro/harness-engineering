# Promovendo CAPTURED → curated

Referência de `evolving-skills`. Volte ao [índice](../SKILL.md) para o quando-invocar.

Quando uma skill em `~/.claude/skills/captured/` provou seu valor (você usou várias vezes, validou que o conteúdo está certo, e ela generaliza além de um caso isolado):

1. **Revise o `SKILL.md`** — reescreva no tom e formato das curated. Frontmatter do harness, descrição clara de quando invocar, exemplos, regras inegociáveis.
2. **Decida o nome curado** — não use o slug auto-gerado. Pense no namespace (`workflow-*`, `stack-*`, etc.).
3. **Copie** para `<repo>/skills/<nome-novo>/SKILL.md`.
4. **Registre** em `skills/harness-index/SKILL.md` na tabela "Skills específicas".
5. **PR para `preview`** com tipo `feat` (nova skill) ou `refactor` (substitui uma curada).
6. **Apague** a versão em `~/.claude/skills/captured/<slug>/` para evitar duplicata na próxima sessão.

## Regras inegociáveis

- **Curated nunca é sobrescrito por OpenSpace**: `OPENSPACE_HOST_SKILL_DIRS=~/.claude/skills/captured`, **não** `~/.claude/skills/harness`. Confirme em `~/.claude/mcp.json` antes de rodar.
- **Conflito curated × evolved**: curated ganha. Se a evolved está mais certa, vira issue, não merge silencioso.
- **CAPTURED não vai pra commit**: o repo guarda só curated. Evolved é local da máquina.
- **Sem ação destrutiva auto-aplicada**: mesmo um FIX precisa de validação humana se altera config, derruba serviço, ou apaga dado.
- **Promoção exige PR**: copiar de captured para o repo é uma decisão revisável, não atalho.
