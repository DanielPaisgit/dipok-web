# Dice Poker — Decisões Pendentes

> Este ficheiro regista todas as decisões de produto e técnicas que ficaram em aberto.
> **Ponto de partida para a próxima sessão.**
> Última actualização: 12 Maio 2026

---

## 🟢 Decisões Tomadas (12 Maio 2026)

| Área | Decisão |
|------|--------|
| Free tier | Jogo 1v1, todos os idiomas, perfil Balanced, primeiros 5 achievements visíveis |
| Achievements free | firstWin, hatTrick, aiSlayer, piladaFromHand ("Cinco Noves!"), perfectStraight |
| Achievements premium | Restantes 35 — visíveis mas bloqueados com cadeado |
| Preço | Compra única €4,99 que desbloqueia tudo |
| Perfis AI free | Só Balanced; Aggressive, Cautious, Dreamer são premium |
| Multiplayer scope | Sala com código + lista de amigos + matchmaking aleatório (todos no MVP) |
| Autenticação | Email/password + login social (Google e Apple) |
| Linguagem | "Pilo/Pilada" substituído por "Nove/Noves" em todo o projecto |

---

## 1. Monetização

### 1.1 Modelo geral
**Estado: decidido em princípio, falta confirmar detalhes**

- Sem anúncios durante o jogo (decisão tomada ✅)
- Modelo freemium por feature gating — versão gratuita limitada, premium pago

### 1.2 O que fica no tier gratuito vs premium
**Estado: DECIDIDO ✅**

| Feature | Grátis | Premium |
|---|---|---|
| Jogo local 1v1 (humano vs 1 IA) | ✅ | ✅ |
| Todos os idiomas | ✅ | ✅ |
| Perfil AI Balanced | ✅ | ✅ |
| Primeiros 5 achievements (visíveis, desbloqueáveis) | ✅ | ✅ |
| Jogo local até 4 jogadores | ❌ | ✅ |
| Perfis AI Aggressive, Cautious, Dreamer | ❌ | ✅ |
| Achievements restantes (visíveis mas bloqueados) | 👁 bloqueado | ✅ |
| Multiplayer online | ❌ | ✅ |
| Temas visuais / cosméticos | ❌ | ✅ |
| Histórico / estatísticas | ❌ | ✅ |

**5 achievements free:** firstWin, hatTrick, aiSlayer, piladaFromHand, perfectStraight

### 1.3 Estrutura de preços
**Estado: DECIDIDO ✅**

- **Compra única de €4,99** que desbloqueia tudo
- Preços por mercado a confirmar na Google Play Console (conversão automática sugerida pelo Google)

**Pendente:**
- [ ] Confirmar se aceitar preço sugerido pelo Google por mercado ou definir manualmente (PT, BR, ES, etc.)

### 1.4 Implementação técnica
**Estado: não iniciado**

- Pacote a usar: `in_app_purchase` (Flutter oficial, funciona Android + iOS)
- Precisará de: produtos configurados na Google Play Console e Apple App Store Connect
- O código actual não tem nenhuma lógica de paywall — tudo é desbloqueado

---

## 2. Multiplayer Online

### 2.1 Tipo de multiplayer
**Estado: decidido em princípio**

- Tempo real (todos online ao mesmo tempo) ✅
- Turnos assíncronos (joga quando podes, notificação quando é a tua vez) ✅
- Ambos os modos confirmados

### 2.2 Lobby / matchmaking
**Estado: DECIDIDO ✅**

- Sala com código ✅
- Lista de amigos ✅
- Matchmaking aleatório ✅
- Todos os três incluídos no MVP de multiplayer

### 2.3 Backend
**Estado: DECIDIDO ✅**

- Supabase (utilizador já tem conta) — Realtime para tempo real, tabelas para estado de jogo
- Autenticação: **email/password + login social (Google e Apple)**
- Persistência de histórico entre sessões: sim (requer conta)

### 2.4 Implementação técnica
**Estado: não iniciado**

- Maior alteração arquitectural do projecto
- Requer: lobby screen, sala de jogo online, sincronização de GameState via Supabase Realtime
- O engine actual (puro, funções state-in/state-out) é compatível com multiplayer online sem refactor

---

## 3. Deploy

### 3.1 Web
**Estado: aprovado, não iniciado**

- Flutter build web → pasta estática `build/web`
- Hosting: Render (conta existente, plano gratuito Static Sites)
- Opção mais simples: compilar localmente + push do `build/web` para repositório separado
- Custo: zero

**Decisão pendente:**
- [ ] Repositório privado no GitHub para o código fonte — confirmar
- [ ] URL / domínio personalizado ou subdomínio do Render?

### 3.2 Android (Play Store)
**Estado: aprovado, não iniciado**

- Custo: 25 USD (pagamento único, conta Google Play Developer)
- Requer: keystore de assinatura, screenshots, descrição, política de privacidade
- `flutter build appbundle` gera o AAB para submissão

**Decisão pendente:**
- [ ] Nome da app na Play Store (pode ser diferente do nome interno "Dice Poker")
- [ ] Política de privacidade (obrigatória — página simples, pode ser no Render)
- [ ] Screenshots em todos os idiomas suportados ou só EN?

### 3.3 iOS (App Store)
**Estado: adiado**

- Requer: Apple Developer account (99 USD/ano) + macOS/Xcode
- Decisão: adiar até haver receita do Android que justifique o custo
- Quando avançar: usar Codemagic (CI/CD com Mac cloud, tier gratuito para Flutter)

---

## 4. Temas Visuais / Cosméticos
**Estado: ideia, não planeado**

- Possível fonte de receita adicional (IAP separado ou incluído no Premium)
- Exemplos discutidos: estilo clássico (cartas tradicionais), moderno, escuro
- **Não há design ainda**

**Decisão pendente:**
- [ ] Avançar com temas ou manter UI única por agora?
- [ ] Se sim: que elementos são temáticos? (faces dos dados, fundo, cores)

---

## 5. Histórico / Estatísticas
**Estado: ideia, não planeado**

- Possível feature premium
- Exemplos: partidas jogadas, win rate, conquistas desbloqueadas, score máximo por figura
- Localmente fácil (shared_preferences); online requer Supabase

**Decisão pendente:**
- [ ] Histórico local apenas, ou sincronizado com conta online?
- [ ] Quais estatísticas mostrar?

---

## 6. Ordem de Trabalhos (actualizada 12 Maio 2026)
**Estado: aprovado ✅**

> Nota: web Flutter não suporta `in_app_purchase` — web é sempre gratuito (demo/marketing).
> Beta testing via Google Play Internal Testing (não APK sideloading).

| # | Tarefa | Depende de | Bloqueia |
|---|--------|-----------|---------|
| T1 | Tomar decisões de produto | — | T6, T7, T8 |
| T2 | Web deploy (Render) | — | Beta PC |
| T3 | Abrir conta Google Play Developer (25 USD) | — | T4 |
| T4 | Build Android + Internal Testing track | T3 | Beta telemóvel |
| T5 | Beta testing (família e amigos) | T2 + T4 | T6 |
| T6 | Feature gating (paywall no código) | T1 + T5 | T7 |
| T7 | Lançamento oficial Android (Play Store) | T6 | T8 |
| T8 | Multiplayer online (Supabase Realtime) | T1 + T6 | T9 |
| T9 | iOS (App Store) | T7 + receita | — |

### Detalhes por tarefa

**T1 — Decisões de produto** (bloqueia tudo)
- [ ] Free vs premium: quais features ficam no tier gratuito
- [ ] Achievements: todos bloqueados ou primeiros N free?
- [ ] Perfis AI: quantos ficam free?
- [ ] Preços: compra única ~2,99€ vs pack multiplayer (1,99€) + pack completo (3,99€)
- [ ] Multiplayer scope: só sala com código, ou lista de amigos / matchmaking?
- [ ] Autenticação multiplayer: anónima (nickname) vs conta com email

**T2 — Web deploy** (sem dependências)
- `flutter build web` → `build/web` → Render static site
- Sem paywall; serve como demo e link partilhável para beta
- [ ] Domínio personalizado ou subdomínio Render?

**T3 — Conta Google Play Developer** (sem dependências técnicas)
- [ ] Pagar 25 USD em play.google.com/console
- [ ] Criar a app no Play Console

**T4 — Build Android + Internal Testing**
- Gerar `.aab` signed (`flutter build appbundle --release`)
- [ ] Criar keystore e guardar em segurança
- Upload para track "Internal Testing"
- Partilhar link de convite com testers

**T5 — Beta testing**
- [ ] Definir o que pedir: bugs, UX confuso, regras pouco claras, equilíbrio AI
- [ ] Definir canal de feedback (WhatsApp? Google Form?)

**T6 — Feature gating**
- Implementar `in_app_purchase` + lógica de paywall no Flutter
- Requer T1 decidido (saber o que bloquear e os SKUs)

---

## Resumo das Decisões por Tomar

- [ ] Feature gating: o que fica free vs premium (secção 1.2)
- [ ] Estrutura de preços: opção A vs B (secção 1.3)
- [ ] Multiplayer: amigos + matchmaking sim/não (secção 2.2)
- [ ] Autenticação multiplayer: anónima vs conta (secção 2.3)
- [ ] Web: domínio personalizado? (secção 3.1)
- [ ] Play Store: nome da app, política de privacidade (secção 3.2)
- [ ] Temas visuais: avançar ou não? (secção 4)
- [ ] Histórico/estatísticas: local ou online? (secção 5)
