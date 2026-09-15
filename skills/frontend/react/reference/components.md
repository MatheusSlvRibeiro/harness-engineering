# Componentes

Referência de `frontend/react`. Volte ao [índice](../SKILL.md) para o quando-invocar.

- Uma pasta por componente (`.tsx` + arquivo de estilo do projeto + `.test.tsx`).
- Export **nomeado**, não `default`, para componentes não-page.
- Props tipadas com `interface`, nunca com `type` inline anônimo.
- Nunca use inline styles (`style={{}}`).

```tsx
// Button/Button.tsx
interface ButtonProps {
  label: string;
  variant?: 'primary' | 'secondary';
  onClick: () => void;
}

export function Button({ label, variant = 'primary', onClick }: ButtonProps) {
  return (
    <button className={/* classe vem da lib de estilo do projeto — ver frontend/scss-bem ou frontend/tailwind */ ''} onClick={onClick}>
      {label}
    </button>
  );
}
```

O arquivo de estilo em si (`.module.scss` + BEM, ou classes utilitárias Tailwind) segue a convenção
do skill de estilo do archetype — `frontend/scss-bem` ou `frontend/tailwind`.
