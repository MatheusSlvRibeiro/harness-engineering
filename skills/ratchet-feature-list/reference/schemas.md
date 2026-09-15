# Schemas: feature_list e baseline

Referência de `ratchet-feature-list`. Volte ao [índice](../SKILL.md) para o quando-invocar.

## .harness/feature_list.json

Cada feature do projeto, com critérios observáveis que a sessão QA verifica contra a app rodando.

```json
{
  "features": [
    {
      "id": "F001",
      "title": "Login com email/senha",
      "criteria": [
        "Usuário consegue submeter formulário com email válido e senha",
        "Token JWT é armazenado em httpOnly cookie",
        "Redirect para /dashboard após sucesso"
      ],
      "implemented": false,
      "verified": false
    }
  ]
}
```

## .harness/baseline.json

Valores atuais de métricas de qualidade que **só podem melhorar** (quality ratchet).

```json
{
  "metrics": {
    "tests_passing": 142,
    "tests_total": 142,
    "coverage_pct": 78.4,
    "lint_warnings": 0,
    "type_errors": 0
  }
}
```
