# Testes (Vitest + fastify.inject())

Referência de `backend/fastify`. Volte ao [índice](../SKILL.md) para o quando-invocar.

```ts
// contact.test.ts
import { describe, it, expect, vi } from 'vitest';
import { build } from '../../app';
import * as email from '../../services/email';

describe('POST /contact', () => {
  it('retorna 200 e dispara o email com payload válido', async () => {
    const sendSpy = vi.spyOn(email, 'sendContactEmail').mockResolvedValue(undefined);
    const app = build();

    const response = await app.inject({
      method: 'POST',
      url: '/contact',
      payload: { name: 'Ana', email: 'ana@example.com', message: 'Olá, preciso de ajuda com...' },
    });

    expect(response.statusCode).toBe(200);
    expect(sendSpy).toHaveBeenCalledOnce();
  });

  it('retorna 400 com payload inválido', async () => {
    const app = build();
    const response = await app.inject({ method: 'POST', url: '/contact', payload: { name: '' } });
    expect(response.statusCode).toBe(400);
  });
});
```

- Nunca sobe o servidor de verdade (`listen()`) em teste — `app.inject()` testa a rota sem porta
  aberta.
- Mock só nas bordas do sistema (envio de email, chamada HTTP terceira) — a própria rota e validação
  zod rodam de verdade.
- Todo endpoint tem pelo menos um teste de caminho feliz e um de validação falhando (400).
