---
name: frontend/scss-bem
description: Convenção de estilo SCSS Modules + BEM para componentes React. Invoque ao estilizar um componente em projeto que usa este archetype (project-multitenant).
---

# SCSS Modules + BEM

BEM dentro de SCSS Modules: o escopo do arquivo já evita colisão global. Cada componente tem um
`.module.scss` ao lado do `.tsx` (ver `frontend/react` → folder-structure).

- Nunca importe CSS global dentro de um componente — use **SCSS Modules**.

```scss
// Button.module.scss
.button {
  padding: 8px 16px;
  border-radius: 4px;

  &--primary   { background: var(--color-primary); color: #fff; }
  &--secondary { background: transparent; border: 1px solid var(--color-primary); }

  &__icon { margin-right: 8px; }
}
```

```tsx
// Button/Button.tsx
import styles from './Button.module.scss';

// elemento + modifier
<button className={`${styles.button} ${styles['button--primary']}`} />

// elemento filho
<span className={styles.button__icon} />
```

Quando o modifier é dinâmico, prefira `clsx` ou template literal em vez de concatenação manual:
```tsx
import clsx from 'clsx';
<button className={clsx(styles.button, styles[`button--${variant}`])} />
```

## SCSS global

Variáveis CSS custom properties e mixins ficam em `src/styles/_variables.scss` / `_mixins.scss`.
Injete globalmente via `vite.config.ts` para não repetir `@use` em cada arquivo:

```ts
// vite.config.ts
export default defineConfig({
  css: {
    preprocessorOptions: {
      scss: {
        additionalData: `@use "@/styles/variables" as *; @use "@/styles/mixins" as *;`,
      },
    },
  },
});
```

Quando precisar de funções do Sass no arquivo, importe explicitamente:
```scss
@use 'sass:color';
.foo { background: color.adjust(#3366ff, $lightness: 10%); }
```

`src/styles/global.scss` (reset, tipografia base) é importado **só** em `main.tsx` — nunca dentro de
um componente.

## Skills relacionadas

- Estrutura de componente: `frontend/react`
