---
name: session-rituals
description: Rituais obrigatórios de início e fim de sessão para evitar perda de contexto entre conversas. Invoque automaticamente no PRIMEIRO turno de toda sessão (mesmo antes da tarefa concreta) e novamente quando o dev sinalizar fim de sessão (palavras como "vamos parar", "encerramos por hoje", "obrigado, é isso"). Cobre wake-up do MemPalace, search direcionado antes de decisões, e a verificação de que decisões notáveis viraram drawer.
---

# Rituais de sessão

A memória cross-sessão só funciona se rodar dois rituais: **abertura** (puxar contexto que já existe) e **fechamento** (confirmar que o que foi decidido vira drawer). Os hooks de auto-save do MemPalace cuidam do transcript bruto; estes rituais cuidam do material de alta densidade.

## Ritual de abertura — primeiro turno da sessão

Antes de tocar qualquer tarefa, execute em ordem:

### 1. Wake-up

```
mempalace wake-up
```

Via MCP, isso é `mempalace_wake_up`. Carrega o contexto recente do palace (últimas sessões em wings ativos). Você não precisa fazer mais nada com o resultado — só ter passado pelos olhos já cria a ponte com o que foi feito antes.

### 2. Search direcionado para a task atual

Se o dev abriu a sessão com uma pergunta ou tarefa concreta, **antes de propor abordagem**, busque o que já foi decidido. Exemplos:

- Task: "implementar auth no novo endpoint" → `mempalace_search "auth flow" --wing <projeto>` e `mempalace_search "auth flow" --wing stack-django-drf-jwt`
- Task: "qual lib de form usar?" → `mempalace_search "form library" --wing stack-react-vite-scss` e `mempalace_search "form library" --wing harness`
- Task: "vamos refatorar o módulo X" → `mempalace_search "<nome do módulo>" --wing <projeto>`

Se a busca retornar um drawer relevante, **exiba o conteúdo literal ao dev** antes de continuar. Não silencie memória: "encontrei essa decisão de 2026-02-14 sobre form library — ainda vale?".

Se não retornar nada, declare em uma linha: "Sem decisões prévias sobre X no palace. Proponho...".

### 3. Confirmar ambiente

Para tasks de código (não conversa pura), confirme rapidamente:

- Branch atual via `git branch --show-current` (devo estar em `feat/*`, não em `main`/`preview`).
- Validação passa atualmente (`<comando de validação do .gsd/STACK.md>`). Se falha, **dizer ao dev** — não tente trabalhar em código quebrado.

Isso é leve (3 a 4 segundos de tool calls) e evita gastar 20 mensagens depois descobrindo que a branch errada está checada out.

## Durante a sessão — saving incremental

Decisão arquitetural ou descoberta importante? **Não espere o fim.** Use `mempalace_add_drawer` na hora, com o texto literal da decisão. O auto-save hook do MemPalace cobre o transcript bruto, mas drawers explícitos têm muito mais peso na busca semântica futura.

Regra de bolso para decidir se vira drawer agora ou pode esperar:

| Vira drawer agora | Pode esperar |
| --- | --- |
| Escolha entre 2+ opções com motivo do "por quê" | Detalhe de implementação que está no diff |
| Postmortem de bug que custou >30min | Erro de digitação corrigido |
| Convenção do projeto divergente da skill genérica | Aplicação da convenção da skill genérica |
| Definição literal de termo do domínio (pelo cliente) | Termo já no glossário |
| Preferência do dev que apareceu casualmente | Confirmação de algo que ele já tinha pedido |

Use as 5 rooms padrão (`decisions` / `lessons` / `glossary` / `stakeholders` / `env`) — convenção em `memory-palace`.

## Ritual de fechamento — fim da sessão

Quando o dev sinaliza fim ("vamos parar", "obrigado é isso", "deixa pra amanhã"):

### 1. Recap de decisões da sessão

Em 3–5 bullets, recapitule o que foi **decidido** (não o que foi feito — diff resolve isso). Foque em:

- "Decidimos X em vez de Y porque Z."
- "Aprendemos que A só funciona com B."
- "Combinamos que a sessão de QA precisa verificar C."

### 2. Confirmação de drawers

Pergunte (ou afirme, em projetos onde o dev já confia):

> "Vou registrar como drawers no MemPalace: [decisão 1], [decisão 2]. Wing `<projeto>`, room `decisions`. OK?"

Após "ok" (ou se o dev não corrigir), use `mempalace_add_drawer` para cada item.

### 3. Atualizar progress

Mostre ao dev o conteúdo atualizado de `.gsd/progress/<MID>-<SID>.md` para ele colar manualmente (regra universal — não escrevemos em `.gsd/` fora do bootstrap).

### 4. Confirmar TBDs pendentes

Se sobraram TBDs em algum `.gsd/*.md` ou critério `verified: false` em `.harness/feature_list.json`, liste — assim a próxima sessão sabe onde retomar.

## O que falha sem os rituais

Sem ritual de abertura:
- Você refaz decisão que já existe → re-litígio gratuito → conflito com o que está em produção.
- Você inventa convenção em vez de seguir a que o dev consolidou.

Sem ritual de fechamento:
- A próxima sessão lê o diff e tenta inferir as decisões → perde o *porquê* → o agente recomeça do zero.
- Drawer só aparece se o dev lembrar de pedir — fica desligado em 80% das sessões.

Os hooks de auto-save do MemPalace mitigam o segundo caso (auto-indexam o transcript), mas drawers explícitos são 10× mais densos para busca semântica que o transcript bruto.

## Regras inegociáveis

- **Abrir sempre com wake-up + search.** Não é opcional. Mesmo em conversa rápida, o wake-up é uma chamada de menos de um segundo.
- **Exibir memória encontrada literalmente.** Não parafraseie um drawer recuperado — mostre o texto exato. O dev decide se ainda vale.
- **Drawer no momento da decisão, não no fim.** Decisão notável → `mempalace_add_drawer` na hora, mesmo no meio da sessão.
- **Sem segredo em drawer.** Token, password, chave de API → vault, não palace. Use room `env` só para ponteiros ("DATABASE_URL fica no 1Password").
- **Recap de fechamento é separado do progress log.** Recap fala de *porquês*; progress fala de *o que foi feito*.

## Skills relacionadas

- Convenção de wings/rooms/drawers, cadência de `mempalace` CLI/MCP: `memory-palace`
- Onde decisões evoluem para virar skill curada: `evolving-skills`
- Índice geral de skills: `harness-index`
