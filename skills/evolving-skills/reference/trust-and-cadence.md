# Quando confiar e cadência

Referência de `evolving-skills`. Volte ao [índice](../SKILL.md) para o quando-invocar.

## Quando confiar numa skill evolved

Não confie automaticamente. Aplique este filtro:

1. **Origem**: a skill veio de quantas execuções? OpenSpace expõe `evolution_processed_at` e contadores. Se for ≤ 2 ocorrências, trate como hipótese.
2. **Escopo**: a skill é específica do seu projeto? Se for stack-genérica (`stack-*`), só promova se a regra realmente generaliza.
3. **Conflito**: a skill evolved contradiz uma curated? **Curated ganha por default.** Se a evolved está certa e a curated está errada, isso vira issue para o dev decidir.
4. **Side effects**: a skill propõe executar comando destrutivo ou alterar config global? Nunca rode sem confirmação do dev — mesmo se a tag for FIX.

## Cadência

```
sessão começa            → escaneia ~/.claude/skills/ inteiro (curated + evolved)
durante o trabalho       → OpenSpace observa Bash, tool calls, sucessos/falhas
                            e armazena candidatos a FIX/DERIVED/CAPTURED
fim da sessão / periódico → openspace decide se promove candidato a skill
                            real em ~/.claude/skills/captured/
revisão manual           → dev abre ~/.claude/skills/captured/, lê o que apareceu,
                            decide: descartar, manter local, ou promover para o repo
```
