# Frontend ↔ auth por cookie httpOnly

Referência de `project-multitenant`. Volte ao [índice](../SKILL.md) para o quando-invocar.

O backend (`stack-django-drf-jwt`) seta os tokens em cookies `httpOnly`; o frontend nunca lê nem
guarda o access/refresh token diretamente — só precisa mandar `credentials`/`withCredentials` e
ecoar o cookie CSRF.

```ts
// src/lib/api/client.ts
import axios from 'axios';

function getCsrfCookie(): string {
  return document.cookie
    .split('; ')
    .find((row) => row.startsWith('csrftoken='))
    ?.split('=')[1] ?? '';
}

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  withCredentials: true, // manda e recebe cookies (access/refresh/csrf)
});

api.interceptors.request.use((config) => {
  if (['post', 'put', 'patch', 'delete'].includes(config.method ?? '')) {
    config.headers['X-CSRFToken'] = getCsrfCookie();
  }
  return config;
});
```

- Login/logout só fazem `POST` para `/token/` e `/logout/` — não guardam nada em
  `localStorage`/`sessionStorage`/estado global além de "estou autenticado" (booleano ou dados do
  usuário retornados pela própria API).
- Expiração de access token: um 401 dispara `POST /token/refresh/` (o refresh também vem de cookie)
  e repete a request original; se o refresh falhar, redireciona pro login.
- `VITE_API_URL` aponta pro domínio da API — se front e API estão em domínios diferentes, o backend
  precisa de `SameSite='None'` + `Secure=True` (ver `stack-django-drf-jwt`).
