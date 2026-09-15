---
name: backend/jwt-cookie-auth
description: Autenticação JWT via cookie httpOnly com djangorestframework-simplejwt — para APIs Django consumidas pela própria SPA do produto. Invoque ao criar endpoint de login/logout/refresh, ou ao configurar autenticação num projeto Django.
---

# JWT via cookie httpOnly (SimpleJWT)

Usar **djangorestframework-simplejwt**, mas o par de tokens nunca volta no corpo da resposta para
consumo do browser — vai em cookies `httpOnly` + `Secure` + `SameSite`. Isso fecha a superfície de
XSS que rouba token de `localStorage`. O preço é CSRF, que se resolve com o padrão de cookie CSRF
não-httpOnly + header enviado pelo frontend.

> Cliente non-browser (mobile, script server-to-server) usa o fluxo alternativo: `Authorization:
> Bearer <token>` obtido de um endpoint que retorna o token no corpo em vez de cookie — documente
> explicitamente por que esse endpoint é a exceção quando ele existir.

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

CORS_ALLOW_CREDENTIALS = True           # obrigatório para o browser enviar/receber os cookies de auth
```

Com auth via cookie httpOnly, `CORS_ALLOWED_ORIGINS` (ver `backend/django-drf` → env-vars) nunca pode
ser `*` — o browser recusa credenciais (cookies) em requests com origem coringa. Liste os domínios
exatos do frontend.

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

## Regras inegociáveis

- JWT em **cookie httpOnly + Secure + SameSite**, nunca em `localStorage`/`sessionStorage`. Header
  `Bearer` só para clientes non-browser — documente a exceção quando usada.
- Todo endpoint `POST`/`PUT`/`PATCH`/`DELETE` chamado pelo cookie exige o header `X-CSRFToken` no
  request — o frontend lê o valor do cookie `csrftoken` (não-httpOnly) e ecoa no header. GETs não
  precisam.
- `SameSite='None'` só quando frontend e API estão em domínios diferentes de fato; nesse caso
  `AUTH_COOKIE_SECURE` é obrigatoriamente `True` (browsers rejeitam `None` sem `Secure`).

## Skills relacionadas

- Models, serializers, views: `backend/django-drf`
- Integração do lado frontend (axios + header CSRF): `project-multitenant` → reference/frontend-auth.md
