# Path aliases e formulários (RHF + zod)

Referência de `stack-react-tailwind`. Volte ao [índice](../SKILL.md) para o quando-invocar.

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

## Formulários (RHF + zod)

**Schema, tipo e mensagem de erro vivem juntos no arquivo de schema — nunca inline no componente.** O `.tsx` só importa o schema e o tipo; não declara `interface`/`type` de dados de form nem faz validação manual (`if (!email.includes('@'))`). Toda regra de validação — obrigatoriedade, formato, mensagem exibida ao usuário — é responsabilidade do zod.

```ts
// LoginForm.schema.ts
import { z } from 'zod';

export const loginSchema = z.object({
  email: z.string().email('Email inválido'),
  password: z.string().min(8, 'Mínimo 8 caracteres'),
});

export type LoginData = z.infer<typeof loginSchema>;
```

```tsx
// LoginForm.tsx — só estrutura: hook de form, JSX, submit. Zero tipo, zero regra de validação.
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { loginSchema, type LoginData } from './LoginForm.schema';

export function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginData>({ resolver: zodResolver(loginSchema) });

  const onSubmit = async (data: LoginData) => {
    // data já validado pelo zod — sem if/else de validação manual
    await authService.login(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      {errors.email && <span role="alert">{errors.email.message}</span>}

      <input type="password" {...register('password')} />
      {errors.password && <span role="alert">{errors.password.message}</span>}

      <button type="submit" disabled={isSubmitting}>Entrar</button>
    </form>
  );
}
```

- O componente lê `errors.<campo>.message` — a mensagem em si (`'Email inválido'`, `'Mínimo 8 caracteres'`) mora no schema, não em string solta na JSX.
- Schema de um único form: `<Form>.schema.ts` na mesma pasta do componente (ver [reference/folder-structure.md](folder-structure.md)). Schema usado por 2+ forms: `src/schemas/`.
- Erro de campo cruzado (ex.: "senha e confirmação não batem") também vai no schema via `.refine()`/`.superRefine()` — nunca comparado manualmente no `onSubmit` ou no JSX.
- Resposta de API dentro de um form (ex.: erro 422 do backend) é reaplicada ao form com `setError`, mas o **shape** esperado da resposta ainda é validado por um schema zod antes de virar estado — não se confia em `unknown` solto.
