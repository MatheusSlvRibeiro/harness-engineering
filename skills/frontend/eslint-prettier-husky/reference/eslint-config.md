# Config ESLint

Referência de `eslint-prettier-husky`. Volte ao [índice](../SKILL.md) para o quando-invocar.

Flat config (`eslint.config.js`), ESLint 9+.

```js
// eslint.config.js
import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import react from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';
import prettier from 'eslint-config-prettier';

export default tseslint.config(
  js.configs.recommended,
  ...tseslint.configs.strict,
  {
    files: ['**/*.{ts,tsx}'],
    plugins: { react, 'react-hooks': reactHooks },
    rules: {
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-non-null-assertion': 'error',
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'error',
      'react/jsx-no-leaked-render': 'error',
    },
  },
  prettier, // sempre por último — desliga regras de estilo que o Prettier já cobre
);
```

- `tseslint.configs.strict`, não `recommended` — o objetivo é bloquear `any`/non-null assertion
  automaticamente, não só sugerir.
- `eslint-config-prettier` sempre **último** no array — evita ESLint e Prettier brigarem sobre a
  mesma regra de formatação (deixa formatação 100% pro Prettier).
- Regra nova em `frontend/typescript` ou `frontend/react` que é mecanicamente checável → vira regra
  de lint aqui, não fica só documentada em prosa.
