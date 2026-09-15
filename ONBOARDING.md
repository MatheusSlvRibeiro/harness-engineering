# Onboarding — Harness Engineering (v2)

> Você acabou de receber acesso a um projeto que usa o **harness engineering v2**. Este documento te coloca produtivo em 10 minutos e mostra como o agente (Claude Code) trabalha junto com você.

---

## 5 minutos de pitch

O **harness v2** é um conjunto de **skills**, **MCPs** e tooling que fazem toda sessão de Claude Code começar já sabendo:

- **Workflow** — branches, commits, PRs, project board, ratchet de qualidade. Vive em skills `workflow-*` e `ratchet-feature-list`.
- **Convenções de stack** — folder layout, componentes, testes, schemas. Vive em skills `stack-<archetype>` (`stack-react-vite-scss`, `stack-django-drf-jwt`...).
- **Memória cross-projeto** — decisões arquiteturais, postmortems, termos de domínio. Vive no MemPalace (MCP), com convenção em `memory-palace`.
- **Evolução** — skills que melhoram com o uso real via OpenSpace (FIX/DERIVED/CAPTURED). Convenção em `evolving-skills`.

**Por que isso importa:** o agente lê o contexto correto sob demanda (frontmatter sempre visível, body só quando relevante), em vez de carregar um AGENTS.md de 400 linhas em toda sessão. Você revisa o **trabalho**, não decisões já tomadas em outra sessão.

---

## Sua primeira sessão — passo a passo

### 1. Setup global (uma vez por máquina)

```bash
# Linux / macOS / WSL
git clone https://github.com/MatheusSlvRibeiro/harness-engineering ~/harness-engineering
cd ~/harness-engineering
./scripts/setup.sh        # ~3-5 min: instala junction, RTK, MCPs
./scripts/doctor.sh       # confirma tudo verde
```

```powershell
# Windows nativo (PowerShell)
git clone https://github.com/MatheusSlvRibeiro/harness-engineering "$HOME\harness-engineering"
.\scripts\setup.ps1
.\scripts\doctor.ps1
```

Se `doctor` reclamar de algo, ele aponta o comando exato pra instalar — siga e rode de novo.

### 2. Clone o projeto

```bash
git clone <repo-do-projeto> <pasta>
cd <pasta>
```

### 3. Suba o ambiente do projeto

Cada projeto tem README próprio. Exemplos típicos:

- Backend Django: `docker compose up -d && docker compose exec web python manage.py migrate`
- Frontend Vite: `npm install && npm run dev`
- Outras stacks: ver `.gsd/STACK.md` → seção *Setup do zero*

### 4. Reinicie o Claude Code

Skills são carregadas no início da sessão; o Claude Code **não** rescaneia mid-session. Se você abriu o Claude Code antes do passo 1 acima, feche e abra de novo.

### 5. Confirme o contexto

Antes da primeira tarefa real, peça:

> "Liste as skills do harness disponíveis nesta sessão e resume em uma frase o que cada uma cobre."

Se aparecer `harness-index`, `workflow-*`, `stack-*`, `memory-palace`, `evolving-skills` e `ratchet-feature-list` — você está bom. Se não aparecerem, o symlink não está ativo: rode `~/harness-engineering/scripts/doctor.sh` pra ver o que falta.

### 6. Confira o que o projeto disse pra você

```bash
cat .gsd/STACK.md       # qual stack, qual archetype, validação, env vars
cat .gsd/SPEC.md        # o que o produto faz, restrições
cat .gsd/ROADMAP.md     # milestones, sprints, tasks
```

Se o STACK aponta um archetype skill (ex.: `stack-react-vite-scss`), é essa skill que cobre as convenções de código deste projeto — o Claude vai puxar quando for relevante.

---

## Os arquivos que importam (v2)

| Arquivo | O que tem | Mexer quando |
| --- | --- | --- |
| `AGENTS.md` | 42 linhas — aponta para `harness-index`. Universal, vem do repo do harness. | Nunca direto neste projeto. |
| `.gsd/STACK.md` | Stack, archetype skill correspondente, validação, env vars, notas. | Quando o stack muda (nova lib core, novo env). |
| `.gsd/SPEC.md` | O que o produto faz, pra quem, restrições. | Quando a fatia do produto muda. |
| `.gsd/ROADMAP.md` | Milestones, sprints, tasks. `[ ]/[~]/[x]`. | Sempre que uma task completa. |
| `.gsd/progress/<MID>-<SID>.md` | Build log do sprint atual. | No fim de cada sessão. |
| `.harness/feature_list.json` | Features e critérios observáveis. Imutável depois de criar — só `implemented`/`verified` mudam. | Quando feature nova é planejada. |
| `.harness/baseline.json` | Métricas de qualidade. Só pode melhorar. | Quando métrica melhora (ou regride com justificativa). |

> Note: **`.gsd/CONVENTIONS.md` não existe mais na v2**. As convenções de código vêm da skill `stack-<archetype>` correspondente, carregada automaticamente pelo Claude.

> Se o projeto faz parte de um workspace umbrella (raro em uso solo — MemPalace resolve cross-projeto sem precisar de arquivos versionados), veja `bootstrap/prompt.md` no repo do harness, seção "Modo avançado".

---

## Fluxo dia-a-dia

```
1. Pega uma issue do board → move pra "In Progress"
2. git checkout preview && git pull
3. git checkout -b <type>/<slug>   (ver skill workflow-branching)
4. Trabalha; valida antes de cada commit
5. git push -u origin <branch>
6. gh pr create --base preview --title "<type>(...): ..."
7. CI verde → review → merge → issue vira "Done"
```

### Validação

Sempre documentada em `.gsd/STACK.md` → seção *Validação*. Tem que passar 100% **antes de cada commit**. Exemplos:

- Python/Django: `ruff check . && ruff format --check . && pytest`
- Node/Vite: `npx tsc --noEmit && npm run lint && npx prettier --check . && npm test`
- Go: `go vet ./... && go test ./...`
- Rust: `cargo clippy -- -D warnings && cargo test`

O comando exato vive no STACK.md do seu projeto.

### Branch naming

`<type>/<slug>` — sem número de issue. Uma branch/PR pode fechar várias issues; cada uma vira `Closes #N` separada no body do PR. Detalhes na skill `workflow-branching`. Tipos válidos: `feat`, `fix`, `chore`, `refactor`, `test`, `docs`, `style`, `perf`.

### Commit messages

Conventional Commits, **inglês**, lowercase, imperativo, ≤72 chars na primeira linha. Skill `workflow-commits` cobre o detalhe e exemplos.

Bom: `feat(webhook): add github signature verification`
Ruim: `fix stuff`, `Adicionado novo componente`, `WIP`

---

## Quando tem dúvida, onde olhar

| Dúvida | Onde |
| --- | --- |
| "Como faço X no fluxo de PR/branch/issue?" | skill `harness-index` → encontra a skill específica |
| "Posso usar X biblioteca?" | skill `stack-<archetype>` apontada em `.gsd/STACK.md` |
| "Como funciona o auth aqui?" | `.gsd/STACK.md` + `INTEGRATION.md` (se multi-repo) |
| "Qual a próxima feature?" | `.gsd/ROADMAP.md` + GitHub Project board |
| "Já decidimos algo sobre Y antes?" | `mempalace search "<termo>"` — drawer no MemPalace |
| "O Claude sugeriu algo estranho" | Confronte com a skill `stack-*` apontada em STACK.md; se contraria, peça justificativa antes de aceitar |

---

## Princípios que valem entender

- **Skills são descritas para serem auto-invocadas.** Não tem `/harness-branching`. O Claude lê os `description:` no frontmatter e invoca quando a tarefa bate. Se nada aparece, é porque o symlink não está ativo (rode `doctor`).
- **Curated × evolved.** Skills no repo (`<harness>/skills/`) são curadas, revisadas em PR. Skills em `~/.claude/skills/captured/` são evoluídas automaticamente pelo OpenSpace — local da sua máquina, untracked. Promoção de evolved → curated é deliberada (ver `evolving-skills`).
- **Decisão do projeto sempre ganha da skill genérica.** Se este projeto decidiu explicitamente algo diferente do que a skill diz, registre no MemPalace (room `decisions`); a regra "search antes de decidir" no AGENTS.md vai fazer o agente respeitar.
- **TBD é aceito.** Melhor marcar algo como TBD do que inventar resposta errada — em qualquer documento `.gsd/`.
- **Fricção é o ponto.** Specs vagos geram código vago. O harness faz pushback de propósito.
- **PR atômico.** Uma PR fecha quantas issues precisar, mas mantém um único tema.
- **Validação manda.** Se a validação falha local, não pusha. Se passa local mas falha CI, é ambiente — não bypasse.

---

## FAQ

**"O Claude inventou uma convenção que não está no harness — devo aceitar?"**
Não. Pergunte de onde veio. Se for boa, salva como drawer no MemPalace (ver `memory-palace`) — vira referência futura. Se for genérica o bastante, pode virar PR pra skill `stack-*` no repo do harness.

**"A skill que está sugerindo está desatualizada (lib X mudou de API)."**
O OpenSpace eventualmente captura isso como FIX. Enquanto isso, salve um drawer no MemPalace registrando o gotcha. Se o problema persistir, abra issue no repo do harness pra atualizar a skill curada.

**"A validação está falhando em código que eu não toquei."**
Significa que existe débito pré-existente. Pode corrigir em um `style:` commit no mesmo PR, OU abre uma issue separada e segue só com a tua mudança original (se a falha não bloquear).

**"Quero adicionar uma feature que não está no roadmap."**
Abre issue no board → entra no Backlog → planeja se precisa entrar num sprint próximo.

**"Vou trabalhar offline / a internet caiu."**
Skills, MemPalace e RTK são todos locais — funcionam offline. Só `gh` (issues/PRs) e atualização do MCP precisam de internet.

**"Quero atualizar minhas skills do harness."**
`cd ~/harness-engineering && git pull`. O symlink continua válido e as skills atualizadas ficam disponíveis na próxima sessão do Claude.

---

## Próximos passos

1. Leia o `AGENTS.md` do projeto (42 linhas — termina em 2 minutos).
2. Leia o `.gsd/STACK.md` e identifique qual skill `stack-*` cobre as convenções deste projeto.
3. Pegue uma task pequena do board (procure "Ready" ou "Priority") e rode o fluxo completo uma vez antes de pegar algo grande. O primeiro PR é sempre o que mais ensina.

Para conceitos avançados (wings/rooms/drawers no MemPalace, promoção de skill CAPTURED para curated): leia `~/harness-engineering/docs/harness-v2/overview.md` quando tiver curiosidade. Não é pré-requisito.
