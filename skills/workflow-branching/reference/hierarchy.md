# Hierarquia e naming

Referência de `workflow-branching`. Volte ao [índice](../SKILL.md) para o quando-invocar.

## Hierarquia

```
main        → produção, sempre estável e deployada
preview     → staging, espelha o que está prestes a ir para main
feat/*      → branches de feature
fix/*       → branches de bug fix
chore/*     → tooling, config, dependências
refactor/*  → mudança de código sem mudança de comportamento
test/*      → adicionar ou atualizar testes
docs/*      → só documentação
```

## Regras inegociáveis

- `main` e `preview` são **protegidas**. Nunca push direto.
- Sempre criar branch a partir de `preview`, **nunca** de `main`.
- Naming: kebab-case curto descrevendo o trabalho, não número da issue.
- O tipo da branch precisa bater com o tipo dominante da issue (feat/fix/chore/etc).
- Uma branch pode fechar várias issues relacionadas — listar com `Closes #N` separadas no body do PR.

### Exemplos

Bom:
```
feat/webhook-receiver
fix/missing-start-time
chore/vitest-setup
refactor/extract-issue-row
```

Ruim:
```
feat/issue-42          ← não use número, descreva o trabalho
fix-bug                ← sem prefixo de tipo
Feature/NewStuff       ← não use camelCase nem PascalCase
feat/this-branch-name-is-way-too-long-and-says-everything-it-does
```

## Criar uma branch

```bash
git checkout preview
git pull origin preview
git checkout -b feat/<short-slug>
```
