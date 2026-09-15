---
name: backend/django-drf
description: Archetype backend Django 5 + Django REST Framework — models, serializers, views, testes, env vars. Invoque ao criar model, serializer, view, migration ou teste em qualquer projeto Django. Autenticação JWT via cookie fica em backend/jwt-cookie-auth.
---

# Django + DRF

Banco padrão: **PostgreSQL**. Testes: **pytest-django + factory_boy**. Config: **django-environ**.

> **Status:** esqueleto opinionado. Convenções aqui são um ponto de partida razoável — espera-se
> que amadureçam via CAPTURED (mecanismo OpenSpace) conforme projetos reais decidam.

## Referência

| Arquivo | Conteúdo |
| --- | --- |
| [reference/folder-structure.md](reference/folder-structure.md) | Estrutura de pastas |
| [reference/models.md](reference/models.md) | PK, timestamps, managers, on_delete |
| [reference/serializers-and-views.md](reference/serializers-and-views.md) | Serializers, ViewSets, paginação, URLs, services |
| [reference/testing.md](reference/testing.md) | pytest-django + factory_boy, fixtures, teste de integração |
| [reference/env-vars.md](reference/env-vars.md) | django-environ, variáveis obrigatórias |

## Regras inegociáveis

- Lógica de negócio em `services.py`, nunca em views ou models.
- Nenhuma query de banco direto em views — só via managers ou services.
- `fields = '__all__'` é proibido em serializers — sempre liste explicitamente.
- Todo endpoint tem teste de integração que bate no banco real.
- `get_queryset()` filtra por escopo do usuário em todo viewset que retorna dados de usuário.
- `SECRET_KEY` e credenciais nunca no repo; sempre via env var.
- Migrations geradas com `makemigrations` ficam commitadas; nunca edite migration aplicada em outra branch sem coordenar.

## Skills relacionadas

- Autenticação: `backend/jwt-cookie-auth`
- Fluxo de issue, branch e PR: `workflow-branching`, `workflow-prs`, `workflow-issues`
- Feature list e baseline: `ratchet-feature-list`
