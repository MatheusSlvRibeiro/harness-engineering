---
name: evolving-skills
description: Como o harness usa OpenSpace (MCP de skills auto-evolutivas — FIX/DERIVED/CAPTURED). Define onde skills curadas vs evoluídas ficam, como distingui-las, quando confiar numa CAPTURED e como promover uma CAPTURED bem-sucedida para o conjunto curado. Invoque ao adotar/criticar uma skill evoluída, ao ver uma CAPTURED nova, ou ao decidir promover.
---

# Skills evolutivas (OpenSpace)

O **OpenSpace** é um MCP que adiciona auto-evolução ao conjunto de skills do agente. Plugado, ele observa execução real, detecta padrões e propõe (ou aplica) três tipos de evolução.

> Curated stays in this repo. Evolved stays out. Promotion is manual and explicit.

## Referência

| Arquivo | Conteúdo |
| --- | --- |
| [reference/modes-and-layout.md](reference/modes-and-layout.md) | Os três modos (FIX/DERIVED/CAPTURED), layout de diretórios, como distinguir curated vs evolved |
| [reference/trust-and-cadence.md](reference/trust-and-cadence.md) | Filtro de confiança para skill evolved, cadência da sessão |
| [reference/promotion.md](reference/promotion.md) | Passo a passo de promoção CAPTURED → curated, regras inegociáveis |

## Skills relacionadas

- Índice geral: `harness-index`
- Memória cross-projeto (decisões cabem aqui antes de virarem skill curada): `memory-palace`
- Convenção de PR para promover skill nova: `workflow-prs`, `workflow-commits`
