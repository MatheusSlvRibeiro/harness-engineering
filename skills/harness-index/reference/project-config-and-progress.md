# Configuração do projeto e acompanhamento de progresso

Referência de `harness-index`. Volte ao [índice](../SKILL.md) para a tabela de roteamento de skills.

## Onde buscar configuração do projeto

- `.gsd/STACK.md` — stack, comando de validação, env vars, notas do projeto
- `.gsd/CONVENTIONS.md` — convenções da stack (em projetos v2 isso vira referência ao archetype global)
- `.gsd/SPEC.md` — visão e capacidades
- `.gsd/ROADMAP.md` — milestones, sprints, tasks
- `.harness/feature_list.json` — features + critérios verificáveis
- `.harness/baseline.json` — métricas que só podem melhorar

## Acompanhamento de progresso

No fim da sessão, atualize `.gsd/progress/<MID>-<SID>.md`:

1. Marque tarefas concluídas no checklist do contrato.
2. Anexe ao build log: `- YYYY-MM-DD: <o que foi feito, uma linha por tarefa>`.
3. Se uma tarefa não foi concluída, explique por quê e o que está bloqueando.
4. Nunca marque tarefa pronta se o comando de validação do projeto não passou.

Você **mostra** o conteúdo ao dev. Ele cola. Você não escreve em `.gsd/` direto fora do bootstrap.
