# Tabelas com TanStack Table

Referência de `project-multitenant`. Volte ao [índice](../SKILL.md) para o quando-invocar.

Usar **`@tanstack/react-table`** (headless) para toda listagem com sort/filtro/paginação — não
montar `<table>` com state próprio linha por linha.

```tsx
// UsersTable.tsx
import { useReactTable, getCoreRowModel, getSortedRowModel, type ColumnDef } from '@tanstack/react-table';

type UserRow = { id: string; email: string; role: string };

const columns: ColumnDef<UserRow>[] = [
  { accessorKey: 'email', header: 'Email' },
  { accessorKey: 'role', header: 'Papel' },
];

export function UsersTable({ data }: { data: UserRow[] }) {
  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
  });

  // render: table.getHeaderGroups() / table.getRowModel().rows — sem lógica de sort manual aqui
}
```

- Colunas (`ColumnDef[]`) moram em `<Table>.columns.ts` ao lado do componente — não inline no JSX,
  mesma regra de "schema fora do componente" que vale pra forms (`stack-react-vite-scss`).
- Paginação server-side (comum em multi-tenant com muitas linhas): `manualPagination: true` +
  `pageCount` vindo da resposta paginada do DRF (`stack-django-drf-jwt` já usa paginação por padrão).
- Estilização é SCSS Modules + BEM como qualquer outro componente — TanStack Table não traz CSS.
