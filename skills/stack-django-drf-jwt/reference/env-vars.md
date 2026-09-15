# Variáveis de ambiente

Referência de `stack-django-drf-jwt`. Volte ao [índice](../SKILL.md) para o quando-invocar.

Usar **django-environ**. `.env` por ambiente, `.env.example` versionado com placeholders.

```python
# config/settings/base.py
import environ

env = environ.Env()
environ.Env.read_env()  # lê .env na raiz

SECRET_KEY = env('DJANGO_SECRET_KEY')
DEBUG = env.bool('DJANGO_DEBUG', default=False)
ALLOWED_HOSTS = env.list('DJANGO_ALLOWED_HOSTS', default=[])
DATABASES = {'default': env.db('DATABASE_URL')}
CORS_ALLOWED_ORIGINS = env.list('CORS_ALLOWED_ORIGINS', default=[])
CORS_ALLOW_CREDENTIALS = True  # obrigatório para o browser enviar/receber os cookies de auth
```

Com auth via cookie httpOnly, `CORS_ALLOWED_ORIGINS` nunca pode ser `*` — o browser recusa
credenciais (cookies) em requests com origem coringa. Liste os domínios exatos do frontend.

Variáveis obrigatórias em todo projeto:

| Variável | Descrição |
| --- | --- |
| `DJANGO_SECRET_KEY` | Chave do Django. Nunca commit, sempre rotacionável. |
| `DJANGO_DEBUG` | `True` só em local. Em prod, `False`. |
| `DJANGO_ALLOWED_HOSTS` | Lista separada por vírgula. |
| `DATABASE_URL` | URL completa (`postgres://user:pass@host:port/db`). |
| `DJANGO_SETTINGS_MODULE` | `config.settings.local` / `config.settings.production`. |
| `CORS_ALLOWED_ORIGINS` | Origens permitidas pelo django-cors-headers. |

- **`.env` no `.gitignore`**, sempre.
- **`.env.example` versionado** com placeholders (`DJANGO_SECRET_KEY=changeme`).
- **Secrets reais em vault** (1Password, AWS Secrets Manager, etc.), nunca no repo.
