# Models

Referência de `backend/django-drf`. Volte ao [índice](../SKILL.md) para o quando-invocar.

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
