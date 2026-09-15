# Estrutura de pastas

Referência de `stack-node-fastify`. Volte ao [índice](../SKILL.md) para o quando-invocar.

```
src/
├── app.ts                    # build() da instância Fastify, registra plugins
├── server.ts                 # listen() — único arquivo que sobe o processo
├── plugins/                  # coisa que decora o app (cors, cookie, rate-limit, db client)
│   └── cors.ts
├── routes/                   # uma pasta por recurso, registrada via autoload ou explicitamente
│   └── contact/
│       ├── contact.routes.ts
│       ├── contact.schema.ts   # zod: body/response
│       └── contact.test.ts
├── services/                  # lógica que não é só "validar e responder" (envio de email, etc.)
├── lib/                       # utilitários puros
└── env.ts                     # schema zod das env vars + parse no boot
```

## Regra de colocação

- Rota nova de recurso simples (form, webhook) → pasta própria em `routes/`.
- Lógica que faz algo além de "validar → persistir/chamar terceiro → responder" (ex.: montar corpo de
  email, orquestrar 2+ chamadas externas) → `services/`, chamada pelo handler da rota.
- Não crie camada de repository/ORM pesado aqui — se o projeto precisa disso, é sinal de que passou
  do escopo de "API leve" (ver nota no [índice](../SKILL.md)).
