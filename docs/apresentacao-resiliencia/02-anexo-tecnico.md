# Anexo Técnico — Estratégia de Resiliência

**Documento de referência. Não precisa ser lido na apresentação — serve para sustentar as decisões do [resumo executivo](./01-resumo-executivo.md) e como guia de implementação.**

---

## Sumário

1. [Capítulo 1 — Gitea / Forgejo na prática](#capítulo-1--gitea--forgejo-na-prática)
   - Gitea vs Forgejo — por que Forgejo
   - Arquitetura proposta
   - Estratégias de espelhamento (3 opções)
   - Stack técnica e requisitos
   - Plano de migração gradual
   - Riscos e mitigação
2. [Capítulo 2 — Arquiteturas de alta disponibilidade](#capítulo-2--arquiteturas-de-alta-disponibilidade)
   - Análise dos grandes outages de 2025
   - Hierarquia de redundância: AZ → Região → Provedor
   - DNS multi-provedor
   - Multi-CDN
   - Replicação de banco multi-região
   - Chaos Engineering — o que dá para copiar do Netflix
   - O que cabe em empresas de porte médio
3. [Fontes](#fontes)

---

## Capítulo 1 — Gitea / Forgejo na prática

### 1.1 Gitea vs Forgejo — qual escolher

**Contexto:** Forgejo é um *hard-fork* do Gitea criado em 2022 e que divergiu definitivamente do código-base em 2024. As duas plataformas têm interface e funcionalidades quase idênticas, mas governança e ritmo diferentes.

| Aspecto | Gitea | Forgejo |
|---------|-------|---------|
| Governança | Empresa com fins lucrativos (Gitea Ltd.) detém marca e domínio | Codeberg e.V. — associação sem fins lucrativos |
| Licença | MIT | GPL v3+ (garante que forks permaneçam livres) |
| Contribuidores ativos (2025) | ~153 | ~232 |
| Velocidade de commits recente | Menor | Maior |
| Patches de segurança | Periódicos | Mensais, com aviso prévio público |
| Funcionalidades enterprise | Algumas exclusivas pagas (Gitea EE) | Tudo open-source |
| Compatibilidade entre os dois | Forgejo ainda aceita migração de Gitea, mas é caminho de mão única | — |
| API e UI | Quase idênticas (Forgejo herdou tudo até 2024) | Quase idênticas |

**Recomendação:** **Forgejo**, salvo se houver dependência explícita de uma feature do Gitea Enterprise. Governança sem fins lucrativos, ritmo de segurança maior e licença GPL são as escolhas mais seguras a longo prazo para uma empresa que está adotando a ferramenta justamente para reduzir dependência de fornecedor único.

> Daqui em diante o texto fala em "Forgejo", mas tudo se aplica igual ao Gitea.

### 1.2 Arquitetura proposta

```
        ┌─────────────────────────────────────────┐
        │           Devs / CI / scripts           │
        └────────────────┬────────────────────────┘
                         │ git push (origem única)
                         ▼
        ┌─────────────────────────────────────────┐
        │   Forgejo  ←  fonte da verdade          │
        │   (VPS própria, TLS via Caddy/Nginx)    │
        │   + backup diário off-site              │
        └────────────────┬────────────────────────┘
                         │ push mirror automático
                         │ (built-in do Forgejo)
                         ▼
        ┌─────────────────────────────────────────┐
        │   GitHub  ←  espelho público            │
        │   (integração Vercel, vitrine, Actions) │
        └─────────────────────────────────────────┘
```

**Pontos-chave:**

- **Direção única do espelhamento.** Devs sempre fazem push no Forgejo. O GitHub é só leitura para humanos; integrações (Vercel, etc.) também leem dali.
- **Bidirecional NÃO recomendado.** Inevitavelmente gera conflitos e dúvida sobre qual é a verdade.
- **Webhooks ficam no Forgejo.** Se quisermos manter alguns Actions do GitHub, configurar como secundário.

### 1.3 Estratégias de espelhamento — três opções

| Opção | Direção | Quem é fonte da verdade | Quando faz sentido |
|-------|---------|--------------------------|---------------------|
| **A. Push mirror (recomendada)** | Forgejo → GitHub | Forgejo | Quando o objetivo é independência |
| **B. Pull mirror** | GitHub → Forgejo (Forgejo puxa periodicamente) | GitHub | Quando o objetivo é só ter backup do GitHub |
| **C. Bidirecional** | Forgejo ↔ GitHub | Indefinido | **Nunca.** Race conditions, conflitos, ninguém sabe qual é a versão correta |

**Configuração da opção A (push mirror):**

1. Criar Personal Access Token no GitHub com escopo `repo`
2. No Forgejo: Repositório → Settings → Mirror Settings → Add Push Mirror
3. URL do remoto: `https://github.com/<owner>/<repo>.git`
4. Intervalo: `8h0m0s` (padrão) ou tempo menor se quiser quase tempo real
5. Sincronizar uma vez manualmente para validar

Issues, PRs e wiki **não** são espelhados nativamente — só git refs (branches/tags). Se quisermos espelhar issues, precisamos de scripts customizados (existem ferramentas como `github-to-gitea-migrator`).

### 1.4 Stack técnica e requisitos

| Componente | Requisito |
|------------|-----------|
| RAM | 512 MB mínimo, 1 GB confortável |
| Disco | Tamanho dos repositórios × 2 (espaço para crescer) + 5 GB para o sistema |
| CPU | 1 vCPU suficiente para times pequenos |
| Banco de dados | SQLite (até ~50 usuários), PostgreSQL (recomendado para produção) |
| Reverse proxy | Caddy (mais simples — TLS automático) ou Nginx |
| TLS | Let's Encrypt via Caddy/Certbot |
| Backup | Snapshot diário do volume + `pg_dump` se PostgreSQL |
| Monitoramento | Uptime Kuma (open-source, leve) |

**Instalação resumida (Docker Compose):**

```yaml
services:
  forgejo:
    image: codeberg.org/forgejo/forgejo:latest
    container_name: forgejo
    environment:
      - USER_UID=1000
      - USER_GID=1000
      - FORGEJO__database__DB_TYPE=postgres
      - FORGEJO__database__HOST=db:5432
      - FORGEJO__database__NAME=forgejo
      - FORGEJO__database__USER=forgejo
      - FORGEJO__database__PASSWD=<secret>
    restart: always
    networks: [forgejo]
    volumes:
      - ./forgejo:/data
    ports:
      - "3000:3000"
      - "222:22"
    depends_on: [db]

  db:
    image: postgres:16
    restart: always
    environment:
      - POSTGRES_USER=forgejo
      - POSTGRES_PASSWORD=<secret>
      - POSTGRES_DB=forgejo
    networks: [forgejo]
    volumes:
      - ./postgres:/var/lib/postgresql/data

networks:
  forgejo:
```

### 1.5 Plano de migração gradual

| Fase | Duração | O que fazer |
|------|---------|--------------|
| **0 — Setup** | 1 dia | Forgejo no ar, TLS, primeiro usuário admin, PostgreSQL, backup automatizado |
| **1 — Repo piloto** | 3 dias | Migrar 1 repositório não-crítico. Configurar push mirror para GitHub. Validar fluxo de commit, PR e CI |
| **2 — Repos secundários** | 1 semana | Mover repositórios internos / experimentais |
| **3 — Repos de produção** | 2 semanas | Mover repositórios principais. Atualizar webhooks do Vercel para apontarem para o GitHub mirror (que continua atualizado) |
| **4 — Ratchet** | Contínuo | A cada nova integração nova, avaliar se aponta para Forgejo direto ou via GitHub mirror |

### 1.6 Riscos e mitigação

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| VPS cai → ninguém comita | Média | Alto | Backup off-site + clone local em cada dev sempre disponível para emergência. Em queda longa, push direto no GitHub e reconciliar depois |
| Push mirror para o GitHub falha silenciosamente | Média | Médio | Monitoramento Uptime Kuma testando que o último commit aparece no GitHub em ≤ 15 min |
| Esquecer de atualizar Forgejo → CVE | Baixa | Alto | Subscrever ao feed de segurança do Forgejo; updates uma vez por mês mínimo |
| Disco cheio na VPS | Média | Alto | Alarme em 80%; LFS para binários grandes |
| Perder a chave SSH do admin | Baixa | Alto | Cópia em cofre de senhas (1Password/Bitwarden); segundo admin por usuário humano |

---

## Capítulo 2 — Arquiteturas de alta disponibilidade

### 2.1 Análise dos grandes outages de 2025

#### AWS us-east-1 — 20 de outubro de 2025

- **Duração:** ~15 horas
- **Causa raiz:** Falha na resolução DNS do endpoint da API do **DynamoDB** em us-east-1
- **Impacto:** Snapchat, Reddit, Duolingo, Ring, Fortnite, Coinbase, Robinhood — entre centenas de outros
- **Custo estimado pelo mercado:** **US$ 75 milhões/hora** somando todas as empresas afetadas
- **Lição central:** Multi-AZ (várias zonas de disponibilidade dentro da mesma região) **não basta**. Problemas no *control plane* da região derrubam tudo dentro dela, independente de quantas AZs você use.
- **Quem sobreviveu sem turbulência:** empresas com arquitetura multi-região ativo-ativo. Failover automático em 3-6 minutos.
- **Quem sofreu mesmo com multi-região:** empresas com failover manual — 2-4h para confirmar o problema e mais 1-2h para acionar o failover.

#### Cloudflare — 18 de novembro de 2025

- **Duração:** 4h10min (11:20 às 15:30 UTC)
- **Causa raiz:** Uma alteração nas permissões de um banco de dados interno fez com que o arquivo de "features" do sistema de Bot Management dobrasse de tamanho, ultrapassando o limite que os proxies da rede aceitavam. Erro interno — **não foi ataque**.
- **Impacto:** X (Twitter), ChatGPT, OpenAI, Spotify, Discord, Zoom, Canva, League of Legends, IKEA, Uber, Indeed, Character AI, Claude AI, Truth Social, Square, Quizlet, Canvas, Letterboxd, Google Store, Dayforce. 2,1 milhões de reports no Downdetector.
- **Custo estimado:** **US$ 250 milhões** acumulado entre as plataformas; Cloudflare perdeu **US$ 1,8 bilhão** em valor de mercado no dia.
- **Lição central:** Cloudflare está no caminho crítico de aproximadamente 20% do tráfego web global. Quando cai, **a internet cai**. Não há margem para confiar em um único provedor de borda.

#### Cloudflare — 5 de dezembro de 2025

- Segunda queda em três semanas. Confirmou para o mercado que o ponto único de falha é estrutural.

### 2.2 Hierarquia de redundância

Cada camada de redundância protege contra um tipo diferente de falha. **Quanto mais "para cima" você protege, mais caro fica — mas menos comum é a falha que isso evita.**

```
┌───────────────────────────────────────────────────────────────┐
│  Multi-PROVEDOR    (AWS + GCP, Cloudflare + Fastly)           │  ← protege de outage de provedor
│  ├ Multi-REGIÃO   (us-east + eu-west)                         │  ← protege de outage regional
│  │  ├ Multi-AZ   (us-east-1a + us-east-1b + us-east-1c)       │  ← protege de outage de datacenter
│  │  │  └ Multi-INSTÂNCIA (várias VMs na mesma AZ)             │  ← protege de falha de máquina
└───────────────────────────────────────────────────────────────┘
```

| Camada | Tipo de falha que evita | Custo relativo | Comum em empresas brasileiras médias? |
|--------|--------------------------|----------------|----------------------------------------|
| Multi-instância | VM individual | × 1 | Sim (Auto Scaling Group básico) |
| Multi-AZ | Data center / energia | × 1.2 | Sim (load balancer + 2 AZs) |
| Multi-região | Região inteira do provedor | × 2-3 | Raro |
| Multi-provedor | Provedor inteiro fora do ar | × 3-5 | Quase nunca |

**Para uma empresa pequena/média a estratégia que mais paga é redundância seletiva**: replicar nas camadas baratas (DNS, backup, código), e aceitar o risco nas camadas caras (banco multi-região).

### 2.3 DNS multi-provedor — a redundância mais barata e mais subestimada

Quando Cloudflare caiu em novembro/2025, vários sites cujo **único uso** do Cloudflare era o DNS ficaram fora — sem necessidade. Quem tinha DNS em dois provedores não sentiu.

#### Como funciona

DNS já é nativamente redundante: o `NS` record permite listar múltiplos nameservers no registrador (`registrar`). Resolvedores tentam o próximo se o primeiro não responder.

```
seudominio.com NS:
  ns1.cloudflare.com
  ns2.cloudflare.com
  ns-1234.awsdns-12.com    ← Route53 (provedor secundário)
  ns-5678.awsdns-56.net
```

#### Implementação prática

1. Escolher dois provedores DNS independentes (boas combinações: **Cloudflare + Route53**, **Cloudflare + deSEC**, **NS1 + Route53**).
2. Configurar as mesmas zonas DNS nos dois — manualmente no início, depois automatizar com script ou ferramenta como `octoDNS` (Spotify) ou `dnscontrol` (Stack Overflow).
3. Listar os 4 nameservers no registrador (2 de cada provedor).
4. TTL baixo (60-300s) para registros A/AAAA críticos; TTL alto (1-4h) para registros NS.

#### Custo

- Route53: ~US$ 0,50/mês por zona + tráfego.
- deSEC: gratuito (organização sem fins lucrativos, focada em DNSSEC).
- Cloudflare: gratuito no tier free.
- **Total realista: US$ 1-5/mês** para a maioria das empresas.

### 2.4 Multi-CDN

#### O que é

Usar duas ou mais CDNs ao mesmo tempo, com um sistema de roteamento que decide em tempo real qual atende cada request, baseado em latência, geografia e saúde.

#### Quem usa

- **Netflix:** 3 CDNs + sua própria CDN proprietária (Open Connect).
- **Discord:** roteamento dinâmico entre Cloudflare e Fastly.
- **Spotify:** roteamento por região entre múltiplos provedores.

#### Como funciona o roteamento

Três padrões:

1. **DNS-based routing** (simples): registros CNAME apontam para um *traffic director* (NS1, Cedexis/Citrix ITM) que decide qual CDN responder com base em health checks.
2. **Client-side routing** (player decide): o app do cliente recebe uma lista de origens e mede latência localmente — comum em streaming de vídeo.
3. **Anycast com BGP** (Netflix-scale): roteamento na camada de rede; requer infraestrutura própria significativa.

#### Quando vale a pena

- Você está no caminho crítico do usuário final (latência importa).
- Receita por hora justifica complexidade adicional (~US$ 500-5000/mês de custo extra de CDN + traffic director).
- Existem requisitos regulatórios de geografia.

#### Para o nosso porte

**Não recomendado ainda.** Cloudflare grátis ou Vercel Edge Network suprem 99% dos casos. Só revisitar se Cloudflare se mostrar instável para nosso tráfego específico.

### 2.5 Replicação de banco multi-região

A camada mais cara e mais difícil de fazer direito. Existem três famílias de soluções:

| Solução | Modelo | Consistência | Custo | Quem usa |
|---------|--------|--------------|-------|----------|
| **AWS Aurora Global Database** | Primary numa região, réplicas read-only em outras | Eventual | $$ | Empresas AWS-only |
| **Google Cloud Spanner** | Distribuído globalmente, ACID | Forte (TrueTime) | $$$$ | Google, empresas grandes |
| **CockroachDB** | Distribuído por design, replicação síncrona | Forte serializable | $$$ | DoorDash, JPMorgan |
| **AWS Aurora DSQL** (novo, 2025) | Multi-região síncrono | Forte | $$$ | Recente, em adoção |

**Trade-offs centrais:**

- **Consistência forte multi-região = latência maior** (a transação precisa do quórum entre regiões geograficamente distantes — fisicamente limitado pela velocidade da luz, ~80ms cross-continent).
- **Consistência eventual = mais rápido**, mas o app precisa tolerar leituras desatualizadas.

**Para nosso porte:** não vale a pena. Replicação síncrona multi-região faz sentido a partir de ~US$ 10M ARR ou requisitos regulatórios específicos (financeiro, saúde). Para o resto, **backup off-site é o substituto pragmático** — você perde alguns minutos/horas em uma catástrofe, mas a 1% do custo.

### 2.6 Chaos Engineering — o que dá para copiar do Netflix

A Netflix popularizou a ideia de **injetar falhas em produção de propósito** para validar resiliência. A suíte de ferramentas dela:

| Ferramenta | O que faz |
|------------|-----------|
| **Chaos Monkey** | Desliga VMs aleatórias em produção, no horário comercial |
| **Latency Monkey** | Injeta latência artificial em chamadas de rede |
| **Chaos Gorilla** | Simula queda de uma AZ inteira |
| **Chaos Kong** | Simula queda de uma região AWS inteira |
| **Conformity Monkey** | Detecta instâncias fora dos padrões de segurança/config |
| **Janitor Monkey** | Limpa recursos não utilizados |

#### GameDays — versão acessível

Conceito criado pela Amazon entre 2008-2010 (Jesse Robbins). Vez ou outra a equipe **agenda uma sessão para derrubar algo de propósito** e medir como o sistema (e a equipe) reagem.

**Como fazer no nosso porte (sem ferramental do Netflix):**

1. Trimestralmente, agendar 2-3 horas com a equipe.
2. Escolher um cenário: "Cloudflare está fora", "VPS principal foi desligada", "GitHub bloqueou nossa conta".
3. **Realmente desligar / bloquear o componente** (em ambiente de staging ou em produção fora do horário de pico).
4. Cronometrar:
   - Quanto tempo até alguém perceber?
   - Quanto tempo até saber a causa?
   - Quanto tempo até restaurar?
5. Documentar o que falhou, atualizar o runbook, repetir trimestralmente.

> Não precisa de Chaos Monkey. Precisa do hábito.

### 2.7 O que cabe em empresas de porte médio — síntese pragmática

| Camada | Padrão do Netflix | Versão pragmática para nós |
|--------|--------------------|------------------------------|
| Código | Repositório distribuído entre 3 regiões | **Forgejo na VPS + push mirror GitHub** |
| CI/CD | Pipeline multi-região com failover automático | Manter GitHub Actions + Forgejo Actions como backup |
| DNS | Anycast próprio (Netflix tem) | **2 provedores DNS no registrador** |
| Compute | Multi-região ativo-ativo | **Vercel + 1 VPS de standby** (failover manual) |
| Banco | Cassandra multi-região | **Backup off-site diário + RTO de horas, não minutos** |
| CDN | 3 CDNs + Open Connect | **Cloudflare por enquanto + plano B documentado** |
| Cultura | Chaos Engineering automatizado | **Game Day trimestral manual** |
| Observabilidade | Stack proprietária | **Uptime Kuma + alertas no Telegram/Slack** |

**Princípio que orienta a coluna da direita:** *resiliência cresce com complexidade. Adote a complexidade na ordem do custo de uma falha.* Para uma operação no nosso porte, perder 4 horas custa muito menos do que pagar permanentemente por uma arquitetura multi-região ativo-ativo.

---

## Fontes

### Outages e post-mortems
- [Cloudflare outage on November 18, 2025 — Cloudflare Blog](https://blog.cloudflare.com/18-november-2025-outage/)
- [Cloudflare outage on December 5, 2025 — Cloudflare Blog](https://blog.cloudflare.com/5-december-2025-outage/)
- [The Cloudflare Outage May Be a Security Roadmap — Krebs on Security](https://krebsonsecurity.com/2025/11/the-cloudflare-outage-may-be-a-security-roadmap/)
- [Global Cloudflare Outage Disrupts Major Platforms Worldwide — Sangfor](https://www.sangfor.com/blog/cloud-and-infrastructure/cloudflare-outage-nov-2025)
- [AWS us-east-1 outage: How Ably's multi-region architecture held up — Ably](https://ably.com/blog/multi-region-resilience-aws-outage)
- [AWS October 2025 Outage: Multi-Region & Cloud Lessons Learned — INE](https://ine.com/blog/aws-october-2025-outage-multi-region-and-cloud-lessons-learned)
- [AWS US-East-1 Outage October 2025 — Safi](https://abdulkadersafi.com/blog/aws-us-east-1-outage-october-2025-complete-analysis-and-impact-report)
- [The $75 Million-Per-Hour Lesson — Revyz](https://www.revyz.io/blog/the-75-million-per-hour-lesson-why-the-aws-us-east-1-outage-of-2025-demands-a-shift-to-a-multi-pronged-resilience-strategylesson-aws-outage)
- [When Multi-AZ Isn't Enough — Censinet](https://censinet.com/perspectives/aws-us-east-1-failure-resilience-lessons)

### Arquiteturas de referência (cloud providers)
- [Architecture Strategies for Using Availability Zones and Regions — Microsoft Azure Well-Architected](https://learn.microsoft.com/en-us/azure/well-architected/design-guides/regions-availability-zones)
- [Architecture Strategies for Designing for Redundancy — Microsoft Azure](https://learn.microsoft.com/en-us/azure/well-architected/reliability/highly-available-multi-region-design)
- [Google Cloud multi-regional deployment archetype](https://docs.cloud.google.com/architecture/deployment-archetypes/multiregional)
- [How to Build Highly Available Multi-regional Services with Cloud Run — Google Cloud Blog](https://cloud.google.com/blog/topics/developers-practitioners/how-to-build-highly-available-multi-regional-services-with-cloud-run/)
- [Architecting Multi-Region HA/DR resiliency patterns — SAP Architecture Center](https://architecture.learning.sap.com/docs/ref-arch/81805673c0)

### DNS e CDN
- [Designing DNS Redundancy: How to Survive the Next Cloudflare-Style Outage — Medium / Nitesh Jain](https://medium.com/@jainnitesh/designing-dns-redundancy-how-to-survive-the-next-cloudflare-style-outage-b60f6d9fd7cd)
- [How we achieve multi-provider DNS redundancy — Hale Stack](https://www.halestack.com/post/how-we-achieve-multi-provider-dns-redundency)
- [Configuring DNS failover — Amazon Route 53 docs](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover-configuring.html)
- [DNS Failover Strategies for High Availability — DNS Spy](https://dnsspy.io/learning/dns-availability/dns-failover-strategies)
- [CDN Routing for a Multi-CDN Architecture — Vercara/DigiCert](https://vercara.digicert.com/resources/cdn_routing)
- [Understanding multi-CDN: benefits and best practices — Spyrosoft](https://spyro-soft.com/blog/media-and-entertainment/understanding-multi-cdn-benefits-and-best-practices)

### Netflix e padrões da indústria
- [Netflix's Strategy for Region Failover & Disaster Readiness — Medium / Ismail Kovvuru](https://medium.com/@ismailkovvuru/netflixs-strategy-for-region-failover-disaster-readiness-a-guide-for-aws-devops-engineers-1ed215f882a9)
- [Building a Video Streaming Platform: Netflix Architecture Deep Dive — DEV Community](https://dev.to/sgchris/building-a-video-streaming-platform-netflix-architecture-deep-dive-36fg)
- [Netflix Architecture: A Look Into Its System Architecture in 2026 — ClickIT](https://www.clickittech.com/software-development/netflix-architecture/)
- [What is Chaos Engineering: How Netflix Uses Chaos Engineering — Substack](https://skylinecodes.substack.com/p/what-is-chaos-engineering-how-netflix)
- [Chaos engineering — Wikipedia](https://en.wikipedia.org/wiki/Chaos_engineering)
- [The Netflix Simian Army: Chaos Engineering & the URF — Unified Resilience](https://www.unifiedresilience.com/blog/the-netflix-simian-army-chaos-engineering-and-the-urf.html)
- [Adapting Netflix's Simian Army for antifragile cloud architectures — Medium / Parzival](https://medium.com/@teddyhaemanth/adapting-netflixs-simian-army-for-antifragile-cloud-architectures-b13fd39d91c9)

### Bancos de dados multi-região
- [How to build a highly available database for a multi-region architecture in 3 steps — Cockroach Labs](https://www.cockroachlabs.com/blog/build-a-highly-available-multi-region-database/)
- [Intro to multi-region distributed SQL topologies — Cockroach Labs](https://www.cockroachlabs.com/blog/multi-region-topology-patterns/)
- [Aurora DSQL is in preview — A first comparison with CockroachDB](https://www.cockroachlabs.com/blog/intro-aws-aurora-dsql/)

### Gitea / Forgejo
- [Comparison with Gitea — Forgejo](https://forgejo.org/compare-to-gitea/)
- [Self-Host Gitea or Forgejo: Lightweight GitHub Alternative on VPS (2026) — DanubeData](https://danubedata.ro/blog/self-host-gitea-forgejo-github-alternative-2026)
- [The 2026 Guide to Self-Hosted Git: Gitea, Forgejo, and the Future of Code Hosting — ServerSpan](https://www.serverspan.com/en/blog/the-2026-guide-to-self-hosted-git-gitea-forgejo-and-the-future-of-code-hosting)
- [Gitea vs Forgejo vs Gogs: Self-Hosted Git 2026 — PkgPulse](https://www.pkgpulse.com/guides/gitea-vs-forgejo-vs-gogs-self-hosted-git-platforms-2026)
- [Self-Hosting Gitea as a GitHub Alternative: Setup, CI/CD, and Mirroring — Botmonster Tech](https://botmonster.com/posts/self-host-gitea-github-alternative/)
