# Conceitos, wings e rooms

Referência de `memory-palace`. Volte ao [índice](../SKILL.md) para o quando-invocar.

## Conceitos

| Conceito | Significado |
| --- | --- |
| **Palace** | A memória inteira da máquina |
| **Wing** | Escopo top-level (um projeto, uma pessoa, um agente especialista) |
| **Room** | Tópico dentro de uma wing (`decisions/`, `lessons/`, `glossary/`) |
| **Drawer** | Memória literal — texto exato salvo, recuperado por busca semântica |

## Wings convencionadas no harness

| Wing | Conteúdo |
| --- | --- |
| `<slug-do-projeto>` | Tudo específico daquele projeto (uma wing por projeto, slug igual ao nome da pasta) |
| `harness` | Meta-decisões sobre como o dev usa o harness (workflow adotado, convenções de PR que diferem do default) |
| `frontend-<tech>` (ex.: `frontend-react-hook-form-zod`) | Decisões cross-projeto sobre um skill atômico de frontend (libs adotadas, padrões que evoluíram) |
| `backend-<tech>` (ex.: `backend-django-drf`) | Idem para um skill atômico de backend |
| `agents/<nome>` | Diários de agentes especialistas (gerenciado pelo próprio MemPalace via `mempalace_list_agents`) |

**Regra:** wing de projeto = nome da pasta do repo, em kebab-case. Não invente apelido novo.

## Rooms padrão dentro de wing de projeto

| Room | O que vai aqui |
| --- | --- |
| `decisions` | Decisões arquiteturais — *por que* escolhemos X em vez de Y |
| `lessons` | Postmortems, gotchas, bugs que custaram tempo |
| `glossary` | Termos do domínio do negócio (cliente, billing, schedule, etc.) |
| `stakeholders` | Pessoas envolvidas, preferências, contatos não-óbvios |
| `env` | Ponteiros para envs/infra (vault, dashboards) — **nunca o segredo em si** |

Rooms novos podem ser criados livremente; estes cinco são o mínimo esperado.
