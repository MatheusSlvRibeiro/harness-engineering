# Regras universais (todas as sessões)

Referência de `harness-index`. Volte ao [índice](../SKILL.md) para a tabela de roteamento de skills.

- O comando de validação do projeto (ver `.gsd/STACK.md`) precisa passar antes de cada commit.
- Sem `any`/escape hatches no type system. Sem código comentado em commits. Sem debug prints.
- Conteúdo de documentação em **português-BR**. Identificadores técnicos (tipo de commit, slug de branch, label de issue) em **inglês**.
- No fim de cada sessão, **mostre ao dev** o conteúdo atualizado de `.gsd/progress/<MID>-<SID>.md` para ele colar manualmente. Você **não** escreve sozinho em `.gsd/` fora do bootstrap inicial.
- Antes de qualquer trabalho com issue/branch/PR, verifique se o GitHub Project existe — se não, invoque `workflow-project-board` para criar.
- No início de toda sessão, puxe contexto cross-projeto via MemPalace (`memory-palace`): wake-up + search no wing do projeto e nos wings de stack relevantes. Antes de propor decisão arquitetural, search antes — se há decisão prévia, exponha-a.
