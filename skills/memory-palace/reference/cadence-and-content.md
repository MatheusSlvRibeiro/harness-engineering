# Cadência e o que vira drawer

Referência de `memory-palace`. Volte ao [índice](../SKILL.md) para o quando-invocar.

## Cadência

```
sessão começa            → mempalace wake-up   (carrega contexto recente)
                         → mempalace search "<dúvida específica>"
                            antes de tomar decisão arquitetural
durante o trabalho       → registrar drawer ao tomar decisão notável
                            (via MCP tool, não CLI)
sessão termina           → auto-save hooks indexam o transcript
                            (ver mempalaceofficial.com/guide/hooks)
periodicamente (dia/sem) → mempalace sweep ~/.claude/projects/
                            para recall message-level
```

## O que vira drawer (vs ruído)

Vira drawer:

- **Decisão arquitetural** com o *porquê* — "trocamos Pinia por Zustand porque o time já dominava e SSR não era requisito".
- **Postmortem** — "o webhook duplicava porque o GitHub reentrega em 10s; corrigimos com idempotency key".
- **Convenção adotada** que diverge do padrão do harness — "neste projeto usamos cookies em vez de JWT em header porque o front é same-origin".
- **Termo do domínio** com definição literal do cliente — não parafraseie.
- **Preferência do dev** que apareceu em conversa — "o Matheus prefere PR único bundleado a vários PRs pequenos em refactors locais".

**Não** vira drawer:

- O que está no código (a fonte é a fonte).
- O que está em `.gsd/` (specs, roadmap, convenções).
- Histórico de git (já é histórico).
- Solução passo-a-passo de bug já fixado (o diff e o commit message bastam).
- Comentários ephemeral de uma sessão ("rodei o teste, passou").

Regra de bolso: se um futuro você não vai ganhar nada relendo isso em outro projeto, **não guarde**.

## Search antes de decidir

Antes de propor stack, padrão de pasta, lib de form, etc., **busque o que já foi decidido**:

```bash
mempalace search "form library escolhida" --wing frontend-react-hook-form-zod
mempalace search "auth flow django" --wing backend-jwt-cookie-auth
mempalace search "preferência de PR" --wing harness
```

Se houver decisão prévia conflitante com a sugestão atual, **mostre a tensão** ao dev — não silencie a memória nem ignore a sugestão. O dev decide se a decisão antiga ainda vale.
