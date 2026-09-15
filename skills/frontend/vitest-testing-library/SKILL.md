---
name: vitest-testing-library
description: Convenção de teste de componente React com Vitest + Testing Library. Invoque ao escrever teste de componente ou de função em src/lib/.
---

# Vitest + Testing Library

```ts
// Button.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import { Button } from './Button';

describe('Button', () => {
  it('chama onClick ao clicar', async () => {
    const handler = vi.fn();
    render(<Button label="Salvar" onClick={handler} />);
    await userEvent.click(screen.getByRole('button', { name: 'Salvar' }));
    expect(handler).toHaveBeenCalledOnce();
  });
});
```

- Toda função em `src/lib/` precisa de teste em `src/lib/__tests__/`.
- Testes de componente ficam colocados junto (`Button.test.tsx`).
- Prefira `screen.getByRole` a `getByTestId` — testa comportamento acessível.
- Teste o comportamento observável, não internals de implementação.
- `vi.mock` só para módulos de borda do sistema (API calls, localStorage). Não moque componentes filhos.

## Configuração mínima do Vitest

```ts
// vite.config.ts (ou vitest.config.ts separado)
test: {
  environment: 'jsdom',
  globals: true,
  setupFiles: './src/test-setup.ts',
}
```

```ts
// src/test-setup.ts
import '@testing-library/jest-dom';
```

## Skills relacionadas

- Estrutura de componente: `frontend/react`
