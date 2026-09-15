# SPEC.md — <Nome do projeto>

> Preencha todas as seções abaixo no início de um projeto novo.
> Seja breve. Um parágrafo por seção costuma bastar.
> Este arquivo é lido no começo de toda sessão do agente — specs vagos geram código vago.

---

## Visão

> Uma ou duas frases descrevendo o que é o produto e para quem é.
> Evite listas de funcionalidades. Foque no resultado que o produto entrega.

Formato sugerido: "Uma <tipo de ferramenta> que <faz X> para <usuário-alvo>, para que possam <atingir Y>."

---

## Problema

> Que dor ou lacuna existe hoje.
> Seja concreto: quem sofre, em que situação, e qual o custo disso.
> Se o problema não é real ou não é doloroso o bastante, o projeto não vale ser construído.

---

## Solução

> Como o produto resolve o problema, em linguagem direta.
> Liste as capacidades principais como uma lista numerada — no máximo 4 ou 5.

1. <capacidade 1>
2. <capacidade 2>
3. <capacidade 3>

---

## Usuários

> Quem interage com o sistema e como.
> Nomeie cada papel explicitamente. Se existe só um papel, diga isso.

- **<Papel 1>:** o que fazem, o que tiram disso
- **<Papel 2>:** o que fazem, o que tiram disso

---

## Fora de escopo

> O que este produto explicitamente NÃO faz.
> Isso é tão importante quanto o escopo em si — previne scope creep.

- <não-objetivo 1>
- <não-objetivo 2>
- <não-objetivo 3>

---

## Critérios de sucesso

> Como saberemos que o produto funciona.
> Cada critério precisa ser observável — algo que uma pessoa consegue checar.

- <critério 1>
- <critério 2>
- <critério 3>

---

## Restrições importantes

> Regras não-óbvias, edge cases ou invariantes que o agente precisa respeitar.
> Qualquer coisa que, se violada, quebraria o produto silenciosamente.
> Exemplos: "eventos são entregues uma única vez", "campo X pode ser null em dados legados", "o cálculo acontece na escrita, não na leitura".

- <restrição 1>
- <restrição 2>
- <restrição 3>

---

> **Stack, validação, env vars e setup** ficam em `.gsd/STACK.md`.
> **Convenções de código** (folder layout, componentes, testes) vêm dos skills atômicos `frontend/*` /
> `backend/*` combinados pelo archetype de projeto (`project-multitenant`, `project-spa`, ex.:
> `frontend/react`, `backend/django-drf`) — sem CONVENTIONS.md por projeto na v2.
