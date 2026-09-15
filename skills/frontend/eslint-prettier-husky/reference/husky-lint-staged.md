# Husky + lint-staged + commitlint

Referência de `eslint-prettier-husky`. Volte ao [índice](../SKILL.md) para o quando-invocar.

```bash
npx husky init
npm pkg set scripts.prepare="husky"
```

```json
// package.json
{
  "lint-staged": {
    "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{json,css,scss,md}": ["prettier --write"]
  }
}
```

```bash
# .husky/pre-commit
npx lint-staged
```

```bash
# .husky/commit-msg
npx --no -- commitlint --edit "$1"
```

```bash
# .husky/pre-push
npx tsc --noEmit
```

```js
// commitlint.config.js
export default { extends: ['@commitlint/config-conventional'] };
```

- `pre-commit` só toca arquivos staged (`lint-staged`) — nunca `eslint .` no repo inteiro no hook.
- `commit-msg` usa `@commitlint/config-conventional`, que já cobre os tipos de `workflow-commits`
  (`feat`, `fix`, `refactor`, `docs`, `chore`, `test`).
- `pre-push`, não `pre-commit`, pro typecheck — `tsc` é lento demais pra rodar em todo commit; rodar
  no push ainda pega o erro antes de virar PR.
- CI (`.github/workflows/ci.yml`) roda `eslint .` (repo inteiro, não só staged) + `prettier --check`
  + `tsc --noEmit` + testes — os hooks locais são conveniência, o CI é o gate que não pode ser
  pulado com `--no-verify`.

```yaml
# .github/workflows/ci.yml (job de lint/typecheck — testes ficam em frontend/vitest-testing-library)
- run: npm run lint
- run: npx prettier --check .
- run: npx tsc --noEmit
```
