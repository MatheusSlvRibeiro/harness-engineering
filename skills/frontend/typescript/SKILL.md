---
name: frontend/typescript
description: Regras de type safety em TypeScript — sem any, narrowing, validação de resposta de API. Invoque ao escrever ou revisar qualquer código TypeScript no frontend.
---

# TypeScript

## Regras inegociáveis

- Sem `any`. Use `unknown` + narrowing, ou defina o tipo correto.
- Toda função tipada por completo — sem parâmetro implicitamente `any`.
- `interface` para shapes de objeto; `type` para uniões, aliases e mapped types.
- Resposta de API é `unknown` até ser validada por um schema zod:
  ```ts
  const raw: unknown = await res.json();
  const data = UserSchema.parse(raw);   // lança se inválido
  ```
- Evite non-null assertion (`!`) — prefira narrowing explícito ou optional chaining.

## Skills relacionadas

- Validação de schema (zod): `frontend/react-hook-form-zod`
- Build tool e env vars tipadas: `frontend/vite`
