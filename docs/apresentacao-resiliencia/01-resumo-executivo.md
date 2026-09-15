# Estratégia de Resiliência da Infraestrutura

**Apresentação interna · Maio/2026**
**Autor:** Matheus da Silva
**Público:** Direção / decisão técnica

---

## Por que estamos discutindo isso agora

Em **2025** o mundo viu três grandes falhas em fornecedores considerados "à prova de bala":

| Data | Evento | Duração | Impacto público |
|------|--------|---------|------------------|
| **20/out/2025** | AWS us-east-1 fora (DNS no DynamoDB) | ~15h | Snapchat, Reddit, Duolingo, Ring, Fortnite |
| **18/nov/2025** | Cloudflare global (arquivo de config inflado) | ~4h10 | X, ChatGPT, Spotify, Discord, Zoom, Canva, Uber. 2.1M reports no Downdetector. Prejuízo estimado: **US$ 250 mi** |
| **05/dez/2025** | Cloudflare novamente | parcial | Repetição confirmando o ponto único de falha |

A lição é direta: **quem dependia de uma única região / único fornecedor parou. Quem tinha redundância passou pelo evento com pequena interrupção.**

Nossa empresa hoje depende — sem alternativa pronta — de: GitHub (código + CI), Vercel (deploy), Cloudflare (DNS/CDN se aplicável). Se qualquer um cair, paramos.

---

## Capítulo 1 — Proposta: Gitea/Forgejo próprio + GitHub como espelho

### O que estamos propondo

Adotar **Forgejo** (fork não-comercial do Gitea, mais ativo da comunidade em 2025/2026) auto-hospedado na nossa VPS como **fonte da verdade do código**, usando o recurso nativo de **push mirror** para manter o GitHub como espelho automático e atualizado.

```
  Dev/CI escreve  →   Forgejo (VPS própria)   →  GitHub (espelho público)
                            ↓
                   Vercel puxa daqui ou daqui
```

### Por que isso atende os dois lados

| Necessidade do chefe | Necessidade da operação |
|---|---|
| Independência de fornecedor estrangeiro | GitHub continua disponível para integração (Vercel, Actions, social login) |
| Dados sob nosso controle físico | Workflow atual quase não muda |
| Reduz lock-in | Vitrine pública continua existindo |
| Mitiga risco de banimento/bloqueio | Pull requests, issues, CI continuam funcionando |

### Custo realista (sem otimismo)

| Item | Custo |
|------|-------|
| Servidor | Forgejo roda em 512 MB de RAM. Cabe na VPS atual. |
| Setup inicial | 1-2 dias (instalação, reverse proxy, TLS, backup automatizado, configuração de mirror) |
| Manutenção mensal | ~1 h (updates, monitoramento de disco) |
| Risco operacional | Backup é nossa responsabilidade — sem isso, "independência" vira ponto único de falha caseiro |

### O que NÃO muda

- **Vercel** continua puxando do GitHub mirror — zero mudança no pipeline de deploy
- **GitHub Actions** complexas do marketplace continuam no GitHub se precisarmos
- **Autenticação social** dos clientes (se usarmos GitHub OAuth) continua igual

---

## Capítulo 2 — O que grandes empresas fazem para sobreviver a quedas de provedor

> Pesquisa feita com fontes oficiais (blogs da AWS, Cloudflare, Microsoft, Google Cloud) e post-mortems de eventos reais de 2025. Detalhes técnicos e fontes no [anexo técnico](./02-anexo-tecnico.md).

### Padrões observados em Netflix, Discord, Spotify, GitHub, Slack

| Camada | Padrão padrão da indústria | Custo / complexidade | Aplicável a nós **hoje**? |
|---|---|---|---|
| **DNS** | 2+ provedores listados no registrar | **Baixo** | ✅ Sim — recomendado |
| **Backup** | Cópia off-site em outro provedor / outra geografia | **Baixo** | ✅ Sim — recomendado |
| **Código fonte** | Espelhado entre 2 hosts | **Baixo** | ✅ É o que esta proposta resolve |
| **CDN** | Multi-CDN com roteamento por health-check (Netflix usa 3) | Médio | ⚠️ Só se Cloudflare for crítico |
| **Compute** | Multi-região ativo-ativo (Netflix usa 3 regiões AWS) | Alto | ❌ Overkill no nosso porte |
| **Banco de dados** | Replicação multi-região (Spanner, CockroachDB, Aurora Global) | Alto | ❌ Avaliar só quando faturamento justificar |
| **Cultura** | Chaos Engineering — Netflix Chaos Monkey derruba serviços em produção de propósito | Variável | ⚠️ Adotar ideia, não a ferramenta ainda |

### Princípio central que aparece em todos os post-mortems

> **Multi-AZ (várias zonas dentro da mesma região) não é suficiente.**
> A falha do us-east-1 em outubro/2025 mostrou que problemas no *control plane* derrubam tudo dentro de uma região, mesmo com múltiplas zonas. Resiliência de verdade exige redundância **entre regiões** e — para serviços críticos de borda como DNS/CDN — **entre fornecedores**.

### Citação do post-mortem oficial pós-Cloudflare (nov/2025)

> "Se você depende de um único fornecedor global, qualquer falha na infraestrutura dele impacta seu serviço diretamente. Planejar redundância e testar failover não é opcional — é parte de operar sistemas confiáveis hoje."

---

## Plano de ação proposto

Ordenado por **custo × benefício** — o que dá mais resiliência por menos esforço vem primeiro.

| # | Ação | Esforço | Janela proposta | Benefício |
|---|------|---------|------------------|-----------|
| 1 | **Forgejo na VPS + push mirror para GitHub** | 2 dias | Junho/2026 | Independência do GitHub para o ativo mais crítico (código) |
| 2 | **Backup off-site automatizado** (snapshot diário em segundo provedor) | 1 dia | Junho/2026 | Recuperação garantida se VPS ou GitHub forem comprometidos |
| 3 | **DNS em 2 provedores** (ex.: Cloudflare + Route53 ou deSEC) | 1 dia | Junho/2026 | Resolve queda total de DNS — o ataque mais comum |
| 4 | **Runbook de failover documentado** | 1 dia | Julho/2026 | Reduz tempo de reação de horas para minutos |
| 5 | **Avaliar multi-CDN** (só se Cloudflare for crítico no caminho do usuário) | 1 semana | Q4/2026 | Resolve queda de CDN — pode esperar |
| 6 | **Game Day trimestral** (simular queda de cada fornecedor) | 0.5 dia / trimestre | Iniciar em Q4/2026 | Garante que o runbook funciona quando precisar |

**Não recomendado neste momento:** multi-cloud full para compute/banco. Custo e complexidade não se pagam no nosso porte atual.

---

## Resumo de uma linha para a direção

> Adotar Forgejo próprio com GitHub como espelho automático nos dá independência sem perder praticidade — e é a porta de entrada de uma estratégia maior de resiliência que grandes empresas comprovadamente usam para sobreviver a quedas de fornecedor.

---

**Próximos passos sugeridos:** aprovar itens 1-4 do plano, agendar implementação para junho/2026, revisar runbook em retro de Q3.

Detalhes técnicos completos no [anexo técnico](./02-anexo-tecnico.md).
