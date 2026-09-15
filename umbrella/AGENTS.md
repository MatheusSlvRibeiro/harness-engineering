# AGENTS.md — Umbrella

Este arquivo é carregado quando uma sessão do agente começa na **raiz do workspace** de um projeto multi-repo (onde dois ou mais repos Git independentes vivem lado a lado como subpastas).

É uma camada meta fina. As regras reais de cada repo vivem dentro do `AGENTS.md` (slim, ~40 linhas) e `.gsd/STACK.md` desse repo, mais as **skills do harness** carregadas globalmente via `~/.claude/skills/harness/`.

---

## O que é o modo umbrella

Este workspace contém **múltiplos repositórios Git independentes** que servem ao mesmo produto. Cada repo:

- Tem seu próprio remote, branches, GitHub Project, comando de validação, deploy.
- Tem `AGENTS.md` slim + `.gsd/STACK.md` + `.gsd/SPEC.md` + `.gsd/ROADMAP.md`. As convenções de código vêm da skill `stack-<archetype>` apontada no STACK.md — não há mais `CONVENTIONS.md` por sub-repo na v2.
- É operado **independentemente** no dia a dia.

A raiz do workspace adiciona **contexto compartilhado** que é importante demais para duplicar:

- `PRODUCT.md` — a fonte única de verdade para visão do produto, problema, usuários, escopo.
- `INTEGRATION.md` — contratos cross-repo: APIs, tipos compartilhados, fluxo de auth, ordem de deploy.

---

## Quando usar umbrella vs sessões de single-repo

| Você vai… | Onde começar a sessão |
| --- | --- |
| Mudar só um repo (bug fix típico, feature isolada) | `cd <repo>` e comece ali |
| Desenhar uma feature cross-repo (API + UI juntos, mudança de contrato) | Comece na raiz do workspace |
| Raciocinar sobre o produto, usuários ou não-objetivos | Comece na raiz do workspace |
| Refatorar internals de um sub-repo | Dentro desse sub-repo |

Modo single-repo é o padrão — use sempre que puder. Modo umbrella custa mais tokens (carrega as duas stacks). Promova para umbrella só quando o trabalho cruzar repos de verdade.

---

## Ordem de leitura quando começar na raiz do workspace

1. Este arquivo (`AGENTS.md`)
2. `PRODUCT.md`
3. `INTEGRATION.md`
4. Para cada sub-repo que você for tocar: `AGENTS.md` (slim) e `.gsd/STACK.md` desse repo — a skill `stack-<archetype>` correspondente é carregada automaticamente pelo Claude

**Não** pré-carregue todos os sub-repos. Só os relevantes para a tarefa atual.

---

## Regras de trabalho cross-repo

### Coordenação de issues

- Features que atravessam repos ganham uma **issue âncora** no repo que inicia a mudança (geralmente backend, já que contratos nascem ali).
- Cada repo afetado abre sua **issue filha** referenciando a âncora: `Refs <owner>/<repo-âncora>#N`.
- Os critérios de aceitação da issue âncora listam as issues filhas.
- Feche a âncora só quando todos os PRs filhos tiverem mergeado.

### Naming de branch entre repos

- Use o **mesmo slug** em todos os repos para a mesma feature: `feat/favorites` tanto no backend quanto no frontend.
- Isso deixa óbvio quais branches pertencem ao mesmo trabalho na hora de revisar.
- Se a issue âncora e as filhas vivem todas na mesma branch (trabalho single-repo), feche todas no body do PR com várias linhas `Closes #N`.

### Ordem de merge

- O repo que **define** um contrato (ex.: um endpoint de API) mergeia para `preview` primeiro.
- O repo que **consome** o contrato vem depois, com a descrição do PR anotando a dependência.
- Nunca mergeie um consumidor antes do contrato estar disponível em `preview`.

### Validação

- O comando de validação de cada repo roda **independentemente**. Não existe validate no nível umbrella.
- Antes de abrir qualquer PR, o comando do repo alterado precisa passar.
- Se uma mudança cross-repo está em andamento, rode a validação de cada repo afetado localmente antes de abrir qualquer PR.

---

## GitHub Project board (multi-repo)

Use um **único GitHub Project (Projects v2)** linkado a **todos** os repos deste workspace.

- Um board, um conjunto de colunas, uma lista de priorização — mesmo que os commits vivam em repos separados.
- Issues de qualquer repo aparecem no mesmo board.
- As colunas e o ciclo de vida definidos no `AGENTS.md` de cada repo se aplicam identicamente.

Verifique no início da sessão:

```bash
gh project list --owner <owner>
```

Se existirem vários boards (um por repo), consolide em um só antes de qualquer trabalho novo.

---

## O que vive onde

| Assunto | Vive em |
| --- | --- |
| Visão do produto, usuários, critérios de sucesso | `PRODUCT.md` (umbrella) |
| Contratos de API, tipos compartilhados, ordem de deploy | `INTEGRATION.md` (umbrella) |
| Fatia deste repo no produto | `<repo>/.gsd/SPEC.md` |
| Milestones e sprints deste repo | `<repo>/.gsd/ROADMAP.md` |
| Stack deste repo + archetype skill correspondente | `<repo>/.gsd/STACK.md` |
| Convenções de código deste stack | skill `stack-<archetype>` (carregada via `~/.claude/skills/harness/`) |
| Regras universais de workflow (branches, commits, PRs, ratchet) | skills `workflow-*` e `ratchet-feature-list` (também via `~/.claude/skills/harness/`) |
| Decisões customizadas que contradizem a skill genérica | drawers no MemPalace, wing do projeto, room `decisions` |

Quando o `SPEC.md` de um sub-repo for duplicar algo do `PRODUCT.md`, ele deve referenciar: "Este repo entrega <fatia X> do produto definido em `../PRODUCT.md`."
