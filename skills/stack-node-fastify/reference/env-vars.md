# Variáveis de ambiente

Referência de `stack-node-fastify`. Volte ao [índice](../SKILL.md) para o quando-invocar.

```ts
// env.ts
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.coerce.number().default(3000),
  CORS_ORIGIN: z.string(),
  SMTP_URL: z.string().url(),
});

export const env = envSchema.parse(process.env); // derruba o processo no boot se faltar/for inválido
```

- `env.ts` é importado uma vez, no topo de `server.ts` — se o `parse()` lança, o processo nem chega a
  abrir a porta.
- Nenhum outro arquivo lê `process.env.*` diretamente — sempre importa `env` de `env.ts`, já tipado.
- `.env` no `.gitignore`; `.env.example` versionado com placeholders.
- Secrets reais (SMTP, chaves de API terceiras) em vault/variável de ambiente do provedor de deploy,
  nunca no repo.
