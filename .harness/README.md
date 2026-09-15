# .harness/

Contratos legíveis por máquina que conectam sessões de dev e sessões de QA.

Dois arquivos vivem aqui depois que um projeto é inicializado:

- **`feature_list.json`** — cada feature que o projeto precisa entregar. Critérios de aceitação numa forma que um script (ou agente de QA) consegue iterar. O agente é **proibido** de editar títulos ou critérios de feature depois da criação — só os flags `implemented` e `verified` mudam.
- **`baseline.json`** — valores atuais de métricas de qualidade (testes passando, coverage, lint warnings, type errors, etc.). Estes números **só podem melhorar**. Um PR que diminuir qualquer métrica de baseline precisa documentar o motivo no build log e atualizar o arquivo no mesmo PR.

---

**Precisa de `jq`** para validar. Veja o `README.md` raiz → Pré-requisitos para instruções de instalação. `setup.sh` aponta como instalar; o CI instala no runner automaticamente.

> Schema preservado em v2. Skill `ratchet-feature-list` (em `~/.claude/skills/harness/`) cobre as regras de uso e atualização desses dois JSONs.

---

## Por que isso existe

A sessão de dev escreve código. A sessão de QA verifica contra o contrato — e o contrato precisa viver em algum lugar que **nenhuma das duas consiga redefinir silenciosamente**.

Checklists de markdown (em issues, em `progress/`) são fáceis para um agente reescrever para combinar com o que foi construído. JSON com contrato de campos congelados é mais difícil de fudge: o agente de QA compara o comportamento rodando com o texto literal de `criteria[]`, não com a memória de "o que combinamos".

Esta é uma versão leve do padrão de ryanhaqueIT/harness-engineering-template — sem os gates de AST Python.

---

## Bootstrapping em projeto novo

O bootstrap (`bootstrap/prompt.md` do harness v2) copia os skeletons da pasta `templates/` para os arquivos reais:

```bash
cp templates/feature_list.json .harness/feature_list.json
cp templates/baseline.json     .harness/baseline.json
```

> Os `*.example.json` nesta pasta são preservados como compatibilidade com projetos ainda em v1 (que dependiam do `harness-sync.sh` copiando daqui).

Depois preencha `feature_list.json` a partir do `SPEC.md` e `ROADMAP.md` (os critérios de sucesso de cada milestone viram uma ou mais features), e popule `baseline.json` com os números atuais depois de rodar o comando de validação pela primeira vez.

---

## Schema do feature list

```json
{
  "project": "<nome do projeto>",
  "features": [
    {
      "id": "F001",
      "title": "<nome curto estável — NÃO edite depois de criar>",
      "criteria": [
        "<critério observável — NÃO edite depois de criar>",
        "<outro critério observável>"
      ],
      "linked_issues": [12, 14],
      "implemented": false,
      "verified": false,
      "notes": ""
    }
  ]
}
```

Regras dos campos:

- `id` — atribuído na criação, nunca reusado, nunca renomeado
- `title`, `criteria` — **congelados** depois que a issue é aberta; se o requisito mudar de verdade, feche a feature e abra uma nova com novo ID
- `linked_issues` — números das issues no GitHub que implementam ou verificam esta feature
- `implemented` — virado para `true` pela sessão de dev quando o código está escrito e o comando de validação passa
- `verified` — virado para `true` pela sessão de QA depois de rodar os critérios contra a app viva
- `notes` — texto livre; útil para falhas de QA e caveats conhecidos

---

## Schema do baseline

```json
{
  "updated_at": "YYYY-MM-DD",
  "metrics": {
    "tests_passing":    { "value": 0, "better": "higher" },
    "coverage_percent": { "value": 0, "better": "higher" },
    "lint_warnings":    { "value": 0, "better": "lower" },
    "type_errors":      { "value": 0, "better": "lower" }
  },
  "rule": "Cada métrica só pode mover na direção 'better'. Para regredir uma métrica intencionalmente, documente o motivo no build log e atualize este arquivo no mesmo PR."
}
```

Regras dos campos:

- `value` — medição atual (precisa ser número)
- `better` — precisa ser `"higher"` ou `"lower"`; diz para `scripts/check-harness.sh` qual direção conta como regressão
- O script lê a versão anterior da branch base (`preview` por padrão) e falha o PR se qualquer métrica se moveu contra sua direção `better`

Adicione ou remova métricas conforme a stack. Adições comuns: `bundle_size_kb` (`lower`), `cyclomatic_complexity_max` (`lower`), `dead_code_count` (`lower`), `accessibility_violations` (`lower`), `lighthouse_performance` (`higher`).
