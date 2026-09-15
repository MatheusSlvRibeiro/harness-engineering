# Autenticação JWT e Models

Referência de `stack-django-drf-jwt`. Volte ao [índice](../SKILL.md) para o quando-invocar.

## Autenticação JWT via cookie httpOnly

Usar **djangorestframework-simplejwt**, mas o par de tokens nunca volta no corpo da resposta para
consumo do browser — vai em cookies `httpOnly` + `Secure` + `SameSite`. Isso fecha a superfície de
XSS que rouba token de `localStorage`. O preço é CSRF, que se resolve com o padrão de cookie CSRF
não-httpOnly + header enviado pelo frontend.

```python
# config/settings/base.py
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'apps.auth.authentication.CookieJWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
}

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=15),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
}

AUTH_COOKIE_ACCESS = 'access_token'
AUTH_COOKIE_REFRESH = 'refresh_token'
AUTH_COOKIE_SECURE = not DEBUG          # True em prod, permite http local
AUTH_COOKIE_SAMESITE = 'Lax'            # 'None' só se frontend e API vivem em domínios diferentes (exige Secure=True)

CSRF_COOKIE_HTTPONLY = False            # o frontend precisa ler este pra ecoar no header
CSRF_HEADER_NAME = 'HTTP_X_CSRFTOKEN'
```

```python
# apps/auth/authentication.py
from rest_framework_simplejwt.authentication import JWTAuthentication
from django.conf import settings

class CookieJWTAuthentication(JWTAuthentication):
    """Lê o access token do cookie httpOnly; cai pro header Bearer se o cookie não existir
    (clientes non-browser: mobile, integração server-to-server)."""

    def authenticate(self, request):
        raw_token = request.COOKIES.get(settings.AUTH_COOKIE_ACCESS)
        if raw_token is None:
            return super().authenticate(request)
        validated_token = self.get_validated_token(raw_token)
        return self.get_user(validated_token), validated_token
```

```python
# apps/auth/views.py
from django.conf import settings
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from rest_framework_simplejwt.serializers import TokenRefreshSerializer

class CookieTokenObtainPairView(TokenObtainPairView):
    def finalize_response(self, request, response, *args, **kwargs):
        if response.status_code == 200:
            access, refresh = response.data.pop('access'), response.data.pop('refresh')
            _set_auth_cookies(response, access, refresh)
        return super().finalize_response(request, response, *args, **kwargs)


class CookieTokenRefreshView(TokenRefreshView):
    def post(self, request, *args, **kwargs):
        request.data['refresh'] = request.COOKIES.get(settings.AUTH_COOKIE_REFRESH)
        return super().post(request, *args, **kwargs)

    def finalize_response(self, request, response, *args, **kwargs):
        if response.status_code == 200:
            access = response.data.pop('access')
            refresh = response.data.pop('refresh', request.COOKIES.get(settings.AUTH_COOKIE_REFRESH))
            _set_auth_cookies(response, access, refresh)
        return super().finalize_response(request, response, *args, **kwargs)


def _set_auth_cookies(response, access, refresh):
    common = dict(httponly=True, secure=settings.AUTH_COOKIE_SECURE, samesite=settings.AUTH_COOKIE_SAMESITE)
    response.set_cookie(settings.AUTH_COOKIE_ACCESS, access, **common)
    response.set_cookie(settings.AUTH_COOKIE_REFRESH, refresh, path='/auth/token/refresh/', **common)


class LogoutView(APIView):
    def post(self, request):
        response = Response(status=204)
        response.delete_cookie(settings.AUTH_COOKIE_ACCESS)
        response.delete_cookie(settings.AUTH_COOKIE_REFRESH, path='/auth/token/refresh/')
        return response
```

```python
# apps/auth/urls.py
from django.urls import path
from apps.auth.views import CookieTokenObtainPairView, CookieTokenRefreshView, LogoutView

urlpatterns = [
    path('token/', CookieTokenObtainPairView.as_view()),
    path('token/refresh/', CookieTokenRefreshView.as_view()),
    path('logout/', LogoutView.as_view()),
]
```

- Todo endpoint `POST`/`PUT`/`PATCH`/`DELETE` chamado pelo cookie exige o header `X-CSRFToken` no
  request — o frontend lê o valor do cookie `csrftoken` (não-httpOnly) e ecoa no header. GETs não
  precisam.
- `SameSite='None'` só quando frontend e API estão em domínios diferentes de fato; nesse caso
  `AUTH_COOKIE_SECURE` é obrigatoriamente `True` (browsers rejeitam `None` sem `Secure`).
- Cliente non-browser (mobile, script server-to-server) usa o fluxo antigo: `Authorization: Bearer
  <token>` obtido de um endpoint que retorna o token no corpo em vez de cookie — documente
  explicitamente por que esse endpoint é a exceção quando ele existir.

## Models

- **PK**: UUID por padrão (`UUIDField(primary_key=True, default=uuid4)`). Use `BigAutoField` só quando há razão concreta (ex.: integração legada).
- **Timestamps**: todo model herda `created_at` / `updated_at` via base abstrata.
- **Sem lógica de negócio em models** — só persistência, invariantes simples e `__str__`. Lógica vai para `services.py`.
- **Managers customizados** para querysets que repetem (`active()`, `for_user(user)`), nunca `@classmethod` na model.
- **Meta.ordering** padrão por `-created_at` para listagens.

```python
# apps/core/models.py
import uuid
from django.db import models

class BaseModel(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True
        ordering = ['-created_at']

# apps/billing/models.py
from apps.core.models import BaseModel

class Subscription(BaseModel):
    user = models.ForeignKey('users.User', on_delete=models.PROTECT, related_name='subscriptions')
    plan = models.ForeignKey('Plan', on_delete=models.PROTECT)
    status = models.CharField(max_length=20, choices=[('active', 'Active'), ('canceled', 'Canceled')])

    def __str__(self):
        return f'{self.user.email} → {self.plan.name}'
```

- **`on_delete`**: prefira `PROTECT` para FKs com sentido de negócio; `CASCADE` só para dependência forte (ex.: filhos órfãos de fato).
- **Choices** em listas no topo do arquivo ou como `TextChoices`/`IntegerChoices` — nunca strings mágicas espalhadas.
