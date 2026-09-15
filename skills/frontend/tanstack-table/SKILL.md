---
name: frontend/tanstack-table
description: Convenção de tabela com TanStack Table (headless) — sort, filtro, paginação. Invoque ao criar qualquer listagem densa com essas necessidades.
---

# TanStack Table

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
  mesma regra de "schema fora do componente" que vale pra forms (`frontend/react-hook-form-zod`).
- Paginação server-side (comum quando há muitas linhas): `manualPagination: true` + `pageCount`
  vindo da resposta paginada da API.
- Estilização segue o skill de estilo do projeto (`frontend/scss-bem` ou `frontend/tailwind`) —
  TanStack Table não traz CSS.

## Skills relacionadas

- Estrutura de componente: `frontend/react`
