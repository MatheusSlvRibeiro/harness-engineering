# Formato e tipos

Referência de `workflow-commits`. Volte ao [índice](../SKILL.md) para o quando-invocar.

## Formato

```
<type>(<escopo opcional>): <descrição curta>

[body opcional, em inglês, explicando o "why" — não o "what"]
```

## Tipos permitidos

| Tipo | Quando usar |
| --- | --- |
| `feat` | nova feature |
| `fix` | bug fix |
| `chore` | tooling, config, dependências |
| `refactor` | mudança de código sem mudança de comportamento |
| `test` | adicionar ou atualizar testes |
| `docs` | só documentação |
| `style` | formatação (sem mudança de lógica) |
| `perf` | melhoria de performance |

## Regras

- Descrição em **inglês**, lowercase, sem ponto no fim.
- Modo **imperativo**: "add route", não "added route" nem "adds route".
- Primeira linha tem no máximo **72 caracteres**.
- Body opcional: explique o **why** (motivo, contexto, trade-off), não o **what** (o diff já mostra).

## Por que inglês?

Conventional Commits é um padrão de **ferramentas** (changelog, release tools, GitHub filters). Parser inconsistente entre idiomas quebra essas ferramentas.

Documentação humana (SPEC, ROADMAP, descrição de PR, comentários em issue) fica em **português**. Só commit, slug de branch e título de PR são em inglês.

## Hooks

- Não pule hooks (`--no-verify`) a menos que o dev peça explicitamente. Se um hook falhou, investigue e corrija a causa.
- Não use `--amend` em commits já publicados. Crie commit novo.
