# Serializers, Views/ViewSets e Services

Referência de `stack-django-drf-jwt`. Volte ao [índice](../SKILL.md) para o quando-invocar.

## Serializers

- **`ModelSerializer`** para CRUD direto sobre uma model.
- **`Serializer`** para shapes que não batem 1:1 com model (login, ações, agregados).
- **Validações de campo** vão em `validate_<field>`; **cross-field** vai em `validate(self, attrs)`.
- **Escrita com FK por ID, leitura com objeto aninhado** — use dois serializers (`*WriteSerializer` / `*ReadSerializer`) ou `to_representation`.
- **Nunca exponha** `password`, hashes, tokens, ou campos internos (`is_staff`, flags) sem `write_only`/`read_only` explícito.

```python
# apps/users/serializers.py
from rest_framework import serializers
from .models import User

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ['id', 'email', 'name', 'password', 'created_at']
        read_only_fields = ['id', 'created_at']

    def validate_email(self, value: str) -> str:
        if User.objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError('Email já cadastrado.')
        return value.lower()

    def create(self, validated_data: dict) -> User:
        # delega para o service — não escreva lógica de criação aqui
        from .services import create_user
        return create_user(**validated_data)
```

- **`fields = '__all__'`** é proibido. Liste explicitamente — evita expor campos novos sem querer ao adicionar coluna.
- **Serializer aninhado** só para **leitura**. Para escrita, aceite IDs (`PrimaryKeyRelatedField`).

## Views / ViewSets

- **`ModelViewSet` + Router** para CRUD padrão (`list`, `retrieve`, `create`, `update`, `destroy`).
- **`APIView`** para endpoints que não são CRUD (login, ações cruzadas, webhooks).
- **`@action`** para operações sobre um recurso que não cabem em CRUD (`/users/{id}/activate/`).
- **Paginação padrão**: `PageNumberPagination` com `page_size = 20`.
- **Permissions** declaradas explicitamente em cada viewset — não confie só na global.

```python
# apps/billing/views.py
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import Subscription
from .serializers import SubscriptionSerializer
from . import services

class SubscriptionViewSet(viewsets.ModelViewSet):
    serializer_class = SubscriptionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # nunca retorne objetos de outros usuários
        return Subscription.objects.for_user(self.request.user)

    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        subscription = self.get_object()
        services.cancel_subscription(subscription, reason=request.data.get('reason'))
        return Response(status=status.HTTP_204_NO_CONTENT)
```

- **Views são finas**: validação via serializer → chamada a `services.*` → resposta. Sem queries em handlers; sem `if user.is_staff` espalhado (use permission class).
- **`get_queryset`** sempre filtra por escopo do usuário — vazamento entre tenants/users é o bug mais comum.
- **Status codes corretos**: `201` em create, `204` em delete/action sem body, `400` em validação, `403` em permission, `404` em not found.

### Paginação

```python
# config/settings/base.py
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
}
```

### URLs

```python
# apps/billing/urls.py
from rest_framework.routers import DefaultRouter
from .views import SubscriptionViewSet

router = DefaultRouter()
router.register('subscriptions', SubscriptionViewSet, basename='subscription')

urlpatterns = router.urls
```

## Services

Lógica de negócio fica em `services.py`, não em views nem em models:

```python
# apps/billing/services.py
def create_subscription(user: User, plan: Plan) -> Subscription:
    # validações, criação, side effects
    ...
```

Views chamam services. Models são só persistência.
