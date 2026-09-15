# Estrutura de pastas

Referência de `stack-react-vite-scss`. Volte ao [índice](../SKILL.md) para o quando-invocar.

```
src/
├── assets/                   # imagens e fontes estáticas
├── components/               # componentes usados em 2+ lugares
│   └── Button/
│       ├── Button.tsx
│       ├── Button.module.scss
│       └── Button.test.tsx
├── pages/                    # uma pasta por rota / view
│   └── Dashboard/
│       ├── Dashboard.tsx
│       ├── Dashboard.module.scss
│       └── Dashboard.test.tsx
├── forms/ (ou junto da page)  # um form = .tsx (estrutura) + .schema.ts (tipo + validação)
│   └── LoginForm/
│       ├── LoginForm.tsx
│       ├── LoginForm.schema.ts
│       └── LoginForm.test.tsx
├── hooks/                    # hooks reutilizados em 2+ lugares
├── lib/                      # funções utilitárias e acesso a API
│   └── __tests__/
├── schemas/                  # schemas zod usados em 2+ lugares
├── types/
│   └── index.ts
└── styles/
    ├── _variables.scss
    ├── _mixins.scss
    └── global.scss           # só importado em main.tsx
```

## Regra de colocação

| Asset | 1 lugar | 2+ lugares |
| --- | --- | --- |
| Componente | dentro da própria pasta de página | `src/components/` |
| Schema zod (+ tipo de dado externo) | `<Form>.schema.ts` junto do form | `src/schemas/` |
| Mock de teste | mesma pasta do teste | `src/mocks/` |
| Tipo (não derivado de schema) | mesmo arquivo ou `types.ts` local | `src/types/index.ts` |
| Função utilitária | inline ou `utils.ts` local | `src/lib/` |

Não crie pasta compartilhada preventivamente — promova quando o reuso acontecer de verdade.

**Componente `.tsx` é só estrutura.** Tipo de dado que vem de fora (form, resposta de API, params de URL) é sempre derivado de um schema zod (`z.infer<typeof schema>`) em arquivo próprio — nunca uma `interface`/`type` solta dentro do `.tsx`. `interface` de **props** do componente (que não representa input externo) pode continuar no próprio `.tsx` — ver [reference/components-and-styling.md](components-and-styling.md).
