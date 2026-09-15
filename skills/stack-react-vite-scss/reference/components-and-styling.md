# Componentes, BEM e SCSS

Referência de `stack-react-vite-scss`. Volte ao [índice](../SKILL.md) para o quando-invocar.

## Componentes

- Uma pasta por componente (`.tsx` + `.module.scss` + `.test.tsx`).
- Export **nomeado**, não `default`, para componentes não-page.
- Props tipadas com `interface`, nunca com `type` inline anônimo.
- Nunca importe CSS global dentro de um componente — use **SCSS Modules**.
- Nunca use inline styles (`style={{}}`).

```tsx
// Button/Button.tsx
import styles from './Button.module.scss';

interface ButtonProps {
  label: string;
  variant?: 'primary' | 'secondary';
  onClick: () => void;
}

export function Button({ label, variant = 'primary', onClick }: ButtonProps) {
  return (
    <button
      className={`${styles.button} ${styles[`button--${variant}`]}`}
      onClick={onClick}
    >
      {label}
    </button>
  );
}
```

## BEM + SCSS Modules

BEM dentro de SCSS Modules: o escopo do arquivo já evita colisão global.

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

Uso no `.tsx`:
```tsx
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
