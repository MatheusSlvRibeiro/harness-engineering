# STACK.md

Identificação do projeto: qual stack este código usa, como validar, que ambiente ele precisa.

Este arquivo é **preenchido pela entrevista de bootstrap** e **nunca é sobrescrito por scripts de sincronia**.
As convenções de código (folder layout, componentes, testes, schemas) **não** vão aqui — vêm da skill `stack-<archetype>` que combina com esta stack (ver `skills/harness-index`).

---

## Stack

> Preenchido pelo bootstrap. Marque o que não souber como TBD.

- Runtime / framework:
- Linguagem:
- Banco / ORM:
- Estilização:
- Testes:
- Gerenciador de pacotes:
- Deploy:

**Archetype de projeto correspondente:** <ex.: `project-multitenant` · `project-spa` · ou "nenhum ainda — convenções emergem via OpenSpace">
**Skills atômicos combinados:** <ex.: `frontend/react` + `frontend/scss-bem` + `backend/django-drf` + `backend/jwt-cookie-auth`>

---

## Validação (rodar antes de cada commit)

> Preenchido pelo bootstrap. Substitua o placeholder abaixo pelo comando real deste projeto.

```bash
<comando de validação>
```

O que ele roda, em sequência:

1. <passo 1, ex.: type check>
2. <passo 2, ex.: lint>
3. <passo 3, ex.: testes>
4. <passo 4, ex.: format check>

**Uma tarefa só está completa quando este comando passa com zero erros.**
Nunca considere uma tarefa pronta com base apenas no seu próprio julgamento.

---

## Setup do zero

> Preenchido pelo bootstrap. Comandos para subir este projeto a partir de um clone limpo.

```bash
git clone <repo>
<comando de instalação>
cp .env.example .env     # preencha as variáveis necessárias
<comando de dev>
```

Depois de instalar as dependências, verifique se existe um GitHub Project para o repositório (ver skill `workflow-project-board`). Se não existir, crie antes de qualquer outro trabalho.

---

## Variáveis de ambiente

> Preenchido pelo bootstrap. Liste cada serviço externo com que este projeto fala e as env vars necessárias.

| Variável | Descrição |
| -------- | --------- |
| —        | —         |

---

## Notas específicas do projeto

> Preenchido pelo bootstrap. Documente restrições, edge cases conhecidos e invariantes não-óbvios que o agente deve respeitar em toda sessão. O que não couber aqui e for decisão estratégica entra como drawer no MemPalace (ver skill `memory-palace`).
