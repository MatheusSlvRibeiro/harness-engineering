# Como o harness funciona

Referência de `harness-index`. Volte ao [índice](../SKILL.md) para a tabela de roteamento de skills.

O harness organiza desenvolvimento em **sessões** restritas por contratos legíveis por máquina:

| Sessão | Lê | Escreve |
| --- | --- | --- |
| **Dev** | issue, `.harness/feature_list.json`, `.harness/baseline.json`, `.gsd/` | código, vira `implemented: true`, atualiza baseline se métricas melhoraram |
| **QA**  | AGENTS.md, STACK.md, CONVENTIONS.md, feature_list.json | vira `verified: true` **somente** depois de rodar cada critério contra a app viva |

A separação impede que o QA seja "convencido" pela sessão dev — ele só checa critérios literais do `feature_list.json`.
