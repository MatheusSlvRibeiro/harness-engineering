# Bootstrap — criar project do zero

Referência de `workflow-project-board`. Volte ao [índice](../SKILL.md) para o quando-invocar.

## Verificação no início da sessão

Antes de qualquer trabalho com issue/branch/PR, verifique se o Project existe:

```bash
gh project list --owner <owner>
```

Se nenhum project corresponde ao repo, criar antes de qualquer outro trabalho.

## 1. Criar

```bash
gh project create --owner <owner> --title "<repo-name>"
```

## 2. Linkar ao repositório

```bash
gh project link <project-number> --owner <owner> --repo <repo>
```

## 3. Configurar campos padrão

- **Status** (single select): 6 colunas, nesta ordem exata
- **Type** (single select): `feat`, `fix`, `chore`, `refactor`, `test`, `docs`
- **Priority** (single select): `low`, `medium`, `high`

## Colunas padrão (6, nesta ordem)

| Coluna | Significado |
| --- | --- |
| Backlog | Issue criada, ainda não avaliada |
| Ready | Avaliada, clara o bastante para começar |
| Priority | Ready e deve ser pegada em seguida |
| In Progress | Branch criada, em trabalho ativo |
| In Review | PR aberta, esperando revisão do orquestrador |
| Done | PR mergeada em preview, issue fechada |
