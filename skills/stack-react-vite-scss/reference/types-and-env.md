# Type safety e variáveis de ambiente

Referência de `stack-react-vite-scss`. Volte ao [índice](../SKILL.md) para o quando-invocar.

## Type safety

- Sem `any`. Use `unknown` + narrowing, ou defina o tipo correto.
- Toda função tipada por completo — sem parâmetro implicitamente `any`.
- `interface` para shapes de objeto; `type` para uniões, aliases e mapped types.
- Resposta de API é `unknown` até ser validada por um schema zod:
  ```ts
  const raw: unknown = await res.json();
  const data = UserSchema.parse(raw);   // lança se inválido
  ```
- Evite non-null assertion (`!`) — prefira narrowing explícito ou optional chaining.

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
