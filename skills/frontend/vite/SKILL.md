---
name: frontend/vite
description: Convenções de Vite — path aliases e variáveis de ambiente VITE_*. Invoque ao configurar alias, adicionar variável de ambiente, ou iniciar um projeto novo com Vite.
---

# Vite

## Path aliases

```ts
// vite.config.ts
import path from 'path';
import { defineConfig } from 'vite';

export default defineConfig({
  resolve: {
    alias: { '@': path.resolve(__dirname, './src') },
  },
});
```

```json
// tsconfig.json  (dentro de "compilerOptions")
{
  "baseUrl": ".",
  "paths": { "@/*": ["./src/*"] }
}
```

Sempre use `@/` em vez de paths relativos profundos (`../../lib/api`).

## Variáveis de ambiente

- Prefixo obrigatório `VITE_*` — sem ele a variável não é exposta ao browser.
- Acesso via `import.meta.env.VITE_*`.
- Declare tipos em `src/env.d.ts`:
  ```ts
  interface ImportMetaEnv {
    readonly VITE_API_URL: string;
  }
  interface ImportMeta {
    readonly env: ImportMetaEnv;
  }
  ```
- Nunca comite `.env` com valores reais. `.env.example` com placeholders é obrigatório.

## Skills relacionadas

- Type safety: `frontend/typescript`
