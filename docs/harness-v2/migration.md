# Migração v1 → v2

Guia para migrar um projeto existente que usa o harness v1 para o harness v2.

> A migração não destrói trabalho. O que era inline no `AGENTS.md` ou em `.gsd/CONVENTIONS.md` continua a ser observado pela v2 — só mora em outro lugar (skill genérica, MemPalace drawer, ou — em último caso — `.gsd/STACK.md` notes do projeto).

---

## TL;DR (5 passos)

1. Rodar `setup.sh` do harness-engineering na máquina (uma vez por máquina).
2. Criar branch dedicada no projeto: `chore/harness-v2-migration`.
3. Salvar no MemPalace qualquer convenção customizada do projeto que diverge da skill `stack-*` correspondente.
4. Substituir `AGENTS.md`, atualizar `.gsd/STACK.md`, apagar 4 arquivos v1 redundantes.
5. Reiniciar o Claude Code → smoke test → PR.

---

## Pré-requisitos

Antes de tocar no projeto, garanta o setup global no laptop:

```bash
# Clone (ou pull) do harness
git clone https://github.com/<owner>/harness-engineering ~/harness-engineering
cd ~/harness-engineering
./scripts/setup.sh        # cria symlink ~/.claude/skills/harness, instala RTK + MCPs
./scripts/doctor.sh       # confirma tudo verde
```

`doctor.sh` precisa terminar com **"Doctor: tudo OK."** antes de continuar. Se algo falta, instale a dependência apontada e rode de novo — não pule.

---

## Mapa de equivalência v1 → v2

| Arquivo no projeto v1 | Destino v2 |
| --- | --- |
| `AGENTS.md` (regras gerais inline) | `AGENTS.md` slim (~42 linhas) — copia de `<harness>/AGENTS.md` |
| `.gsd/CONVENTIONS.md` | **removido** — substituído pela skill `stack-<archetype>` (`stack-react-vite-scss`, `stack-django-drf-jwt`) |
| `.gsd/bootstrap-prompt.md` | **removido** — `<harness>/bootstrap/prompt.md` é a fonte única agora |
| `.gsd/SESSION_START.md` | **removido** — skill `harness-index` orienta o início de sessão |
| `.gsd/BOOTSTRAP.md` | **removido** — meta-doc, não precisa mais |
| `.gsd/STACK.md` | **mantido**, adiciona linha "Archetype skill correspondente" |
| `.gsd/SPEC.md` | **mantido**, opcionalmente move bloco "Visão técnica" pra STACK |
| `.gsd/ROADMAP.md` | **mantido** sem mudança |
| `.gsd/progress/<MID>-<SID>.md` | **mantido** sem mudança |
| `.harness/feature_list.json` | **mantido** — schema preservado |
| `.harness/baseline.json` | **mantido** — schema preservado |
| `scripts/check-harness.sh` | **mantido** — continua validando os JSONs |

> `scripts/harness-init.sh` e `scripts/harness-sync.sh` (v1) deixam de ser usados — bootstrap roda via prompt no harness, sincronia ROADMAP→GitHub é orientada por `workflow-project-board` + `workflow-issues`. Você pode apagar do projeto ou deixar parados — eles não atrapalham.

---

## Passos detalhados

### 1. Branch dedicada

No projeto que vai migrar:

```bash
git checkout preview
git pull origin preview
git checkout -b chore/harness-v2-migration
```

A migração é tipo `chore` (tooling/config, sem feature de usuário). Não linka feature do `feature_list.json`.

### 2. Preservar convenções customizadas no MemPalace

**Antes** de apagar `.gsd/CONVENTIONS.md` e substituir `AGENTS.md`, leia esses dois arquivos procurando regras **específicas do projeto** que divergem da skill `stack-*` genérica que vai substituí-los.

Exemplos de coisas que merecem virar drawer:

- "Neste projeto, validação Zod fica em `lib/validators/` em vez de colocada junto da rota."
- "Time decidiu usar `Bearer` em cookie HttpOnly em vez de header (same-origin only)."
- "Migration nunca toca tabela `legacy_users` — invariante histórico."

Para cada uma, registre via MCP do MemPalace (ver skill `memory-palace`):

```
Wing: <slug-do-projeto>
Room: decisions  (ou lessons, ou stakeholders, conforme o tipo)
Drawer: texto literal do trecho do AGENTS/CONVENTIONS antigo, com nota "[v1 → preservado em drawer durante migração para v2 em YYYY-MM-DD]"
```

> Não parafraseie. Salve o texto literal. MemPalace existe pra evitar perda em LLM summarization.

Se a regra é **idêntica** à da skill `stack-*` genérica, **não salve** — vira ruído.

### 3. Identificar o archetype correspondente

Olhe a stack do projeto e escolha:

| Stack predominante | Skill archetype |
| --- | --- |
| React + Vite + SCSS Modules + RHF/Zod + Vitest | `stack-react-vite-scss` |
| Django + DRF + JWT (SimpleJWT) + pytest | `stack-django-drf-jwt` |
| Outra stack | "nenhum ainda — convenções emergem via OpenSpace" |

Projetos full-stack podem listar múltiplos archetypes. Stack sem archetype matching é OK — OpenSpace fará convenções emergirem via CAPTURED conforme o agente trabalha (ver skill `evolving-skills`).

### 4. Substituir `AGENTS.md`

```bash
cp ~/harness-engineering/AGENTS.md ./AGENTS.md
```

O AGENTS.md slim referencia `@.gsd/STACK.md` no final — esse include é o que carrega config específica deste projeto.

Customize se este projeto tem regra universal **adicional** que vale para toda sessão (raro — quase tudo cabe na skill correta). Adicione na seção "Regras universais" do AGENTS.md, não invente seção nova.

### 5. Atualizar `.gsd/STACK.md`

Abra `.gsd/STACK.md` e:

- Adicione (logo após a seção "Stack") uma linha:
  ```markdown
  **Archetype skill correspondente:** stack-react-vite-scss
  ```
  ou o archetype escolhido no passo 3 (ou "nenhum ainda — convenções emergem via OpenSpace").
- Se o `.gsd/SPEC.md` ainda tem uma seção "Visão técnica" duplicando o que está em STACK, opte por:
  - **mover** o conteúdo dela inteiro para STACK e apagar a seção do SPEC (recomendado), **ou**
  - deixar como está (não quebra nada, só duplica).

### 6. Remover arquivos v1 redundantes

```bash
rm -f .gsd/CONVENTIONS.md
rm -f .gsd/bootstrap-prompt.md
rm -f .gsd/SESSION_START.md
rm -f .gsd/BOOTSTRAP.md
```

Se algum desses arquivos tinha conteúdo customizado que **não foi** salvo no MemPalace no passo 2, pare e volte. Não apague decisão sem ter o registro.

### 7. Verificar JSONs do ratchet

`feature_list.json` e `baseline.json` têm schema idêntico em v1 e v2. Rode o validador para confirmar que nada quebrou:

```bash
bash ~/harness-engineering/scripts/check-harness.sh
```

Tem que terminar OK. Se reclamar de feature `verified: false` etc., é estado normal do projeto — não problema da migração.

### 8. Reiniciar Claude Code

Skills não são rescaneadas mid-session. Feche o Claude Code (ou reinicie o terminal/IDE) e abra de novo no projeto.

Quando voltar, na primeira mensagem da nova sessão, valide:

- O system reminder lista `harness-index` (e as outras skills do harness) entre as skills disponíveis.
- `cat .gsd/STACK.md` mostra a linha do archetype.
- `ls .gsd/` mostra só `SPEC.md`, `STACK.md`, `ROADMAP.md`, `progress/`.

### 9. Smoke test

Peça ao Claude (na nova sessão):

> "Vamos validar a migração. Invoque `harness-index` e me diga em uma frase qual skill cobre cada um destes tópicos: branching, PRs, project board, feature list, convenções de código do nosso stack, memória cross-projeto, e skills evolutivas."

Se o Claude consegue responder cada tópico apontando para a skill correta, a migração funcionou.

Rode também o comando de validação do projeto (`.gsd/STACK.md` → seção "Validação"). Tem que passar zero erros.

### 10. PR

```bash
git add AGENTS.md .gsd/
git commit -m "chore: migrate to harness-v2 (skills + MCPs)"
git push -u origin chore/harness-v2-migration
gh pr create --base preview --title "chore: migrate to harness-v2" \
  --body "Migração v1 → v2 conforme ~/harness-engineering/docs/harness-v2/migration.md."
```

PR é `chore`, vai para `preview` como qualquer outro. Como não toca código de feature, baseline e feature_list não regridem — gate do harness passa.

---

## Edge cases

### Projeto sem archetype matching

Stack inusual (Rust + Axum, Go + Echo, Elixir + Phoenix, etc.). Faça **tudo** menos identificar archetype — em STACK.md, ponha "Archetype skill correspondente: nenhum ainda — convenções emergem via OpenSpace (skill evolving-skills)".

O harness continua funcionando: workflow/PR/commits/issues/project-board/ratchet são agnósticos de stack. As convenções de código emergem via OpenSpace conforme você usa o projeto.

### Múltiplos archetypes no mesmo repo

Monorepo fullstack ou repo com frontend+backend. Liste vários em STACK.md:

```markdown
**Archetype skill correspondente:**
- `stack-react-vite-scss` (frontend em `web/`)
- `stack-django-drf-jwt` (backend em `api/`)
```

Claude carrega ambas as skills — descrições delas têm escopo claro (frontend vs backend) e o agente escolhe na hora de aplicar.

### Workspace umbrella (modo avançado, raro em uso solo)

Para times que mantêm `PRODUCT.md`/`INTEGRATION.md` versionados no raiz do workspace: cada sub-repo migra **separadamente** (passos 1–10 acima dentro de cada um). O umbrella em si não tem `.gsd/` por convenção v2; se você criou `PRODUCT.md`/`INTEGRATION.md` na v1 no nível umbrella, mantenha como está — schemas não mudaram.

> Para uso solo cross-projeto, considere abandonar umbrella e usar **MemPalace** com wing por projeto + wing extra para "produto" cruzando projetos. Cobre o papel de PRODUCT/INTEGRATION com busca semântica, sem precisar de arquivos versionados.

### `.gsd/progress/` enorme

Não toque. Histórico de progresso é dado — fica como está. Sessões futuras de v2 continuam anexando ao mesmo `progress/<MID>-<SID>.md`.

### Convenção do projeto que contradiz a skill `stack-*`

Cenário: a skill diz "use SCSS Modules", mas o projeto escolheu "use styled-components em todas as features novas". Resolução:

1. Salve a decisão como drawer no MemPalace, wing do projeto, room `decisions`.
2. Em `.gsd/STACK.md`, adicione bullet em "Notas específicas do projeto" referenciando a decisão: "Estilização: styled-components em vez de SCSS Modules (ver drawer no MemPalace, wing `<projeto>`, room `decisions`)."
3. O Claude, ao tomar decisão de estilização, deve buscar memória primeiro (regra universal "search antes de decidir" em AGENTS.md) — vai encontrar a decisão e respeitá-la, mesmo contra a skill genérica.

A skill `stack-*` é guia padrão, não bíblia. Decisão do projeto explícita ganha.

---

## Rollback

Se a migração quebrou alguma coisa não recuperável imediatamente:

```bash
git checkout preview
git branch -D chore/harness-v2-migration
```

Você fica de volta no v1 sem perda. Drawers salvos no MemPalace ficam preservados (memória é cross-projeto e local) — quando refizer a migração, os drawers continuam lá.

---

## Quando não migrar

- Projeto em release crítica (freeze) — migre depois.
- Projeto com `feature_list.json` no meio de sprint ativo onde features dependem de convenções customizadas — termine o sprint primeiro.
- Time de mais de uma pessoa sem coordenação — migre depois de alinhar com o resto.

A migração é segura e reversível, mas ainda é uma mudança no contrato de contexto do agente. Faça quando o custo de coordenação for baixo.
