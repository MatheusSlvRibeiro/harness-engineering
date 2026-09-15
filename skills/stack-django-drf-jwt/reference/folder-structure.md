# Estrutura de pastas

Referência de `stack-django-drf-jwt`. Volte ao [índice](../SKILL.md) para o quando-invocar.

```
project/
├── config/
│   ├── settings/
│   │   ├── base.py
│   │   ├── local.py
│   │   └── production.py
│   ├── urls.py
│   └── wsgi.py
├── apps/
│   └── <domain>/            # uma app por domínio (users, billing, etc.)
│       ├── models.py
│       ├── serializers.py
│       ├── views.py
│       ├── urls.py
│       ├── services.py      # lógica de negócio (não na view, não no model)
│       └── tests/
│           ├── test_models.py
│           ├── test_serializers.py
│           └── test_views.py
├── manage.py
└── requirements/
    ├── base.txt
    ├── local.txt
    └── production.txt
```
