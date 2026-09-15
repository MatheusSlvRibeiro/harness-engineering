# Estrutura de pastas

Referência de `frontend/react`. Volte ao [índice](../SKILL.md) para o quando-invocar.

```
src/
├── assets/                   # imagens e fontes estáticas
├── components/               # componentes usados em 2+ lugares
│   └── Button/
├── pages/                    # uma pasta por rota / view
│   └── Dashboard/
├── forms/ (ou junto da page)  # um form = .tsx (estrutura) + .schema.ts (tipo + validação)
│   └── LoginForm/
├── hooks/                    # hooks reutilizados em 2+ lugares
├── lib/                      # funções utilitárias e acesso a API
│   └── __tests__/
├── schemas/                  # schemas zod usados em 2+ lugares
└── types/
    └── index.ts
```

O arquivo/pasta de estilo global (`styles/`) segue a convenção do skill de estilo do projeto
(`frontend/scss-bem` ou `frontend/tailwind`) — não é parte deste layout genérico.

## Regra de colocação

| Asset | 1 lugar | 2+ lugares |
| --- | --- | --- |
| Componente | dentro da própria pasta de página | `src/components/` |
| Schema zod (+ tipo de dado externo) | `<Form>.schema.ts` junto do form | `src/schemas/` |
| Mock de teste | mesma pasta do teste | `src/mocks/` |
| Tipo (não derivado de schema) | mesmo arquivo ou `types.ts` local | `src/types/index.ts` |
| Função utilitária | inline ou `utils.ts` local | `src/lib/` |

Não crie pasta compartilhada preventivamente — promova quando o reuso acontecer de verdade.
