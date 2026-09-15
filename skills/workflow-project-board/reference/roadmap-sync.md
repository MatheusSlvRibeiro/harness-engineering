# Sincronia ROADMAP → GitHub

Referência de `workflow-project-board`. Volte ao [índice](../SKILL.md) para o quando-invocar.

Procedimento determinístico que roda no fim do bootstrap e no início de cada sessão.

## Passo 1 — Project

```bash
gh project list --owner <owner> --format json
```

Se nenhum project corresponde ao repo, criar (ver [reference/bootstrap.md](bootstrap.md)).

## Passo 2 — Milestones

Para cada milestone do `.gsd/ROADMAP.md` (M01, M02, ...):

```bash
gh api repos/<owner>/<repo>/milestones --jq '.[].title'
```

Se a milestone (título "M01 — <nome>") não existe:

```bash
gh api repos/<owner>/<repo>/milestones \
  -f title="M01 — Core pipeline" \
  -f description="Goal: ... · Shippable when: ..." \
  -f state="open"
```

## Passo 3 — Issues por task

Para cada task do ROADMAP (`M01-S02-T01: ...`):

1. Buscar pelo marcador:

   ```bash
   gh issue list --search "Task: M01-S02-T01 in:body" --state all --json number,title
   ```

2. Se já existe, **pular**.

3. Se não existe, criar:

   ```bash
   gh issue create \
     --title "<type>(<scope>): T01 - <descrição>" \
     --body "Task: M01-S02-T01

   <body do template — ver workflow-issues>" \
     --milestone "M01 — Core pipeline" \
     --label "<type>"
   ```

4. Adicionar ao Project no status `Backlog`:

   ```bash
   gh project item-add <project-number> --owner <owner> --url <issue-url>
   ```

   E setar `Status=Backlog`, `Type=<type>` via `gh project item-edit`.

## Regras

- Project precisa existir **antes** de qualquer trabalho de issue/branch.
- Direção da sincronia é **só** ROADMAP → GitHub. Nunca apague/feche issues para refletir mudanças no ROADMAP.
- Issues novas criadas pela sincronia entram em `Backlog`, sem priority, sem branch. Milestone correspondente já linkada.
- Issue com marcador `Task: <MID>-<SID>-<TID>` não deve ser duplicada — a sincronia procura o marcador antes de criar.

## Resumo ao dev após sincronia

```
Sincronia ROADMAP → GitHub:
- Project: <criado | já existia> (<url>)
- Milestones criadas: M01, M02
- Milestones puladas (já existiam): M03
- Issues criadas: 12 (#NN..#NN)
- Issues puladas (marcador Task: já existia): 5
- Tasks no ROADMAP sem issue após sincronia: 0
```

Se algum passo falhou (token sem scope `project`, milestone com nome divergente, gh CLI faltando), pare e mostre o erro — não tente workarounds destrutivos.
