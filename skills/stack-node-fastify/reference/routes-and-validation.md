# Rotas e validação (zod)

Referência de `stack-node-fastify`. Volte ao [índice](../SKILL.md) para o quando-invocar.

```ts
// contact.schema.ts
import { z } from 'zod';

export const contactBodySchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  message: z.string().min(10).max(2000),
});

export const contactResponseSchema = z.object({ ok: z.literal(true) });

export type ContactBody = z.infer<typeof contactBodySchema>;
```

```ts
// contact.routes.ts
import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { contactBodySchema, contactResponseSchema } from './contact.schema';
import { sendContactEmail } from '../../services/email';

export const contactRoutes: FastifyPluginAsyncZod = async (app) => {
  app.post('/contact', {
    schema: { body: contactBodySchema, response: { 200: contactResponseSchema } },
  }, async (request, reply) => {
    await sendContactEmail(request.body); // request.body já é ContactBody, validado
    return { ok: true };
  });
};
```

```ts
// app.ts
import Fastify from 'fastify';
import { serializerCompiler, validatorCompiler } from 'fastify-type-provider-zod';
import { contactRoutes } from './routes/contact/contact.routes';

export function build() {
  const app = Fastify().withTypeProvider<ZodTypeProvider>();
  app.setValidatorCompiler(validatorCompiler);
  app.setSerializerCompiler(serializerCompiler);

  app.setErrorHandler((error, request, reply) => {
    request.log.error(error);
    const status = error.statusCode ?? 500;
    reply.status(status).send({
      error: { code: error.code ?? 'INTERNAL_ERROR', message: status < 500 ? error.message : 'Internal error' },
    });
  });

  app.register(contactRoutes);
  return app;
}
```

- Handler nunca lê `request.body`/`request.query` sem schema — se a rota não declara `schema`, isso é
  o bug, não uma exceção válida.
- Erro de validação (400) já vem formatado pelo `validatorCompiler` — não precisa de try/catch manual
  no handler pra isso.
- Erro de negócio esperado (ex.: "email já cadastrado") usa `reply.status(409).send({ error: {...} })`
  explícito no handler — reserve o `setErrorHandler` central pra erro não-esperado.
- Mensagem de erro 5xx pro cliente é sempre genérica (`'Internal error'`); detalhe completo só no log.
