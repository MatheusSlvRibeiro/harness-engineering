# Convenção Tailwind

Referência de `stack-react-tailwind`. Volte ao [índice](../SKILL.md) para o quando-invocar.

Classes utilitárias direto no JSX. Sem arquivo `.module.css`/`.scss` por componente — a única folha
de estilo do projeto é `src/styles/index.css`, e só existe para o que Tailwind não cobre (reset,
`@font-face`, tokens custom via `@theme`).

```tsx
// Button.tsx
interface ButtonProps {
  label: string;
  variant?: 'primary' | 'ghost';
  onClick: () => void;
}

export function Button({ label, variant = 'primary', onClick }: ButtonProps) {
  return (
    <button
      onClick={onClick}
      className={cn(
        'rounded-md px-4 py-2 text-sm font-medium transition-colors',
        variant === 'primary' && 'bg-blue-600 text-white hover:bg-blue-700',
        variant === 'ghost' && 'bg-transparent text-blue-600 hover:bg-blue-50',
      )}
    >
      {label}
    </button>
  );
}
```

- Combinação condicional de classes via `cva` (`class-variance-authority`) quando há 3+ variantes;
  `clsx`/`cn()` simples é suficiente para 1-2 condicionais.
- Mesma sequência de utilitárias repetida em 3+ componentes é sinal de que virou um componente
  (`<Card>`, `<Badge>`) — não uma constante de string de classes.
- Sem `style={{ ... }}` inline — se Tailwind não cobre o valor, vira token em `@theme` no
  `index.css` e uma classe utilitária a partir dele.
- Tokens de design (cores de marca, espaçamento fora da escala padrão) vivem em `@theme` no
  `index.css`, não espalhados como valores mágicos (`bg-[#1a2b3c]`) pelos componentes.
