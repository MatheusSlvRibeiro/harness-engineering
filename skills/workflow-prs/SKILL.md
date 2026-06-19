---
name: workflow-prs
description: Como abrir PR no harness (título em Conventional Commits, body com Closes #N, validação obrigatória). Cobre PR feat/* → preview (obrigatório antes de In Review) e PR preview → main (produção). Invoque ao abrir PR, escrever título/body, ou diagnosticar PR rejeitado.
---

# Workflow: PRs

## Quando abrir cada tipo de PR

- **`feat/*` (ou `fix/*`, `chore/*`, etc.) → `preview`**: obrigatório antes de mover issue para In Review.
- **`preview` → `main`**: obrigatório antes de deployar para produção. Aprovação do senior necessária.

## Título do PR

Mesmo formato de Conventional Commits (ver `workflow-commits`):

```
feat(webhook): add github signature verification
fix(report): handle missing startTime
chore: add vitest configuration
```

- Em inglês, lowercase, sem ponto no fim.
- Máximo 72 caracteres.

## Body do PR

```markdown
## Summary
- <ponto 1 do que mudou>
- <ponto 2>

## Test plan
- [ ] <passo 1 de teste manual ou automatizado>
- [ ] <passo 2>
- [ ] Comando de validação do projeto passou
- [ ] Nenhuma métrica em `.harness/baseline.json` regrediu

Closes #<numero>
Closes #<outro-numero-se-houver>
```

## Regras

- **Antes de abrir PR `feat/* → preview`, invoque o subagent `code-reviewer`** (Agent tool, se instalado em `~/.claude/agents/`) sobre o diff da branch. Reporte os achados ao dev antes do `gh pr create` — não bloqueia a abertura, mas o dev precisa ver o resultado primeiro. Se `code-reviewer` não estiver instalado, siga sem ele e avise o dev.
- Cada issue fechada precisa de uma linha `Closes #N` **separada** (uma por linha). Um PR pode fechar várias issues relacionadas.
- PR sem `Closes #N` em pelo menos uma issue não deve ser aprovado (exceção: PR `preview → main`, que agrega várias).
- PR em que o comando de validação do projeto falha **nunca** é aprovado.
- PR não pode mergear em `preview` enquanto qualquer feature linkada tiver `verified: false` no `feature_list.json`.
- Nenhuma métrica em `baseline.json` pode regredir sem motivo documentado no body do PR e no build log (`.gsd/progress/`).
- Nunca force push (`push --force`) em `main` ou `preview`. Em branches `feat/*` próprias, só se o dev pedir.
- Nunca skip hooks (`--no-verify`) a menos que o dev peça explicitamente.

## Comando

```bash
gh pr create --title "feat(scope): description" --body "$(cat <<'EOF'
## Summary
- ...

## Test plan
- [ ] ...

Closes #N
EOF
)" --base preview
```

Para PR `preview → main`:

```bash
gh pr create --title "release: <data ou versão>" --body "..." --base main --head preview
```

## Ao receber feedback no PR

- Mudanças requeridas → mover issue de volta para **In Progress**. Endereçar feedback, push, comentar com resumo do que mudou. Mover de volta para **In Review**.
- Aprovado → senior faz o merge. Issue vira **Done** automaticamente (pelo `Closes #N`).

## Skills relacionadas

- Mensagem do commit que vai compor o PR: `workflow-commits`
- Estratégia de branches: `workflow-branching`
- Mover issue para In Review após abrir PR: `workflow-project-board`
- Ratchet de qualidade que bloqueia merge: `ratchet-feature-list`
