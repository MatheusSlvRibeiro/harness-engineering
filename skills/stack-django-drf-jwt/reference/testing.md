# Testes

Referência de `stack-django-drf-jwt`. Volte ao [índice](../SKILL.md) para o quando-invocar.

Stack: **pytest + pytest-django + factory_boy**.

- **Um arquivo por camada** dentro de `apps/<domain>/tests/`: `test_models.py`, `test_serializers.py`, `test_views.py`, `test_services.py`.
- **Factories**, não fixtures globais com dados grandes. Cada factory em `apps/<domain>/tests/factories.py`.
- **Banco real** (Postgres ou SQLite em teste). Não moque a ORM — moque só bordas externas (HTTP, S3, email).
- **Todo endpoint precisa de teste de integração**: status code + shape da resposta + efeito no banco.

```python
# conftest.py
import pytest
from rest_framework.test import APIClient

@pytest.fixture
def api_client() -> APIClient:
    return APIClient()

@pytest.fixture
def authenticated_client(api_client, user) -> APIClient:
    api_client.force_authenticate(user=user)
    return api_client
```

```python
# apps/users/tests/factories.py
import factory
from apps.users.models import User

class UserFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = User

    email = factory.Sequence(lambda n: f'user{n}@example.com')
    name = factory.Faker('name')
```

```python
# apps/billing/tests/test_views.py
import pytest
from apps.users.tests.factories import UserFactory
from apps.billing.tests.factories import SubscriptionFactory

@pytest.mark.django_db
def test_user_lists_only_own_subscriptions(api_client):
    user = UserFactory()
    other = UserFactory()
    own = SubscriptionFactory(user=user)
    SubscriptionFactory(user=other)  # não deve aparecer

    api_client.force_authenticate(user=user)
    res = api_client.get('/api/subscriptions/')

    assert res.status_code == 200
    ids = [s['id'] for s in res.json()['results']]
    assert ids == [str(own.id)]
```

- **`@pytest.mark.django_db`** em todo teste que toca banco.
- **Sem `assert True`** nem testes que só rodam sem verificar nada.
- **Coverage como ratchet**: o número vai em `.harness/baseline.json` — só pode subir.
