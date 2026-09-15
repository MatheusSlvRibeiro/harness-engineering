# Os três modos e layout no harness

Referência de `evolving-skills`. Volte ao [índice](../SKILL.md) para o quando-invocar.

## Os três modos

| Modo | O que faz | Quando dispara |
| --- | --- | --- |
| **FIX** | Repara uma skill que está falhando (output errado, tool quebrada) | Quando uma skill curada para de funcionar — ex.: comando `gh` mudou de assinatura, regex parou de bater |
| **DERIVED** | Cria nova versão de uma skill existente que se mostrou consistentemente melhor | Quando um padrão de uso recorrente bate a skill original em sucesso/tokens |
| **CAPTURED** | Cria skill nova a partir de fluxo bem-sucedido observado várias vezes | Quando um workflow ad-hoc se repete e dá certo — vira skill reutilizável |

## Layout no harness

Dois diretórios — separação dura entre **curated** (revisado, versionado) e **evolved** (auto-gerado, untracked):

```
<repo>/skills/                              ← CURATED (este repo)
   └── workflow-*, stack-*, memory-palace,
       evolving-skills, ...                 ← versionado, revisado em PR

~/.claude/skills/harness/                   ← symlink → <repo>/skills/

~/.claude/skills/captured/                  ← EVOLVED (untracked, local)
   └── <slug-gerado-pelo-OpenSpace>/        ← FIX/DERIVED/CAPTURED moram aqui
       └── SKILL.md
```

Claude Code carrega ambos diretórios automaticamente (`~/.claude/skills/` é escaneado inteiro). O agente vê curated + evolved sem distinção visual no autoload — distinção vem do **caminho**.

### Por que dois diretórios

- **Sem poluir o repo**: CAPTURED é experimental por definição. Não deve aparecer em `git status` nem entrar em PR sem revisão.
- **Promoção é deliberada**: copiar de `captured/` para `<repo>/skills/` é um ato consciente, não default.
- **Rollback é trivial**: apagar `~/.claude/skills/captured/<slug>/` reverte sem afetar curado.

## Como distinguir curated vs evolved

Pelo caminho. Se o `SKILL.md` que o agente carregou está em:

- `<repo>/skills/<nome>/SKILL.md` → **curated**: tem revisão humana, foi pensado, segue convenção do harness.
- `~/.claude/skills/captured/<slug>/SKILL.md` → **evolved**: auto-gerado, ainda não validado pelo dev.

OpenSpace também grava metadados (`evolution_processed_at`, lineage, success rate) — quando você ler uma skill evolved, busque esses sinais antes de seguir o que ela diz.
