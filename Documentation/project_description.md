# Dice Poker — Descrição do Projecto

## Visão Geral

**Dice Poker** (Dice Poker) is a cross-platform game (mobile-first + web) based on the traditional Portuguese game **Poker de Dados**. The goal is to create a digital experience faithful to the classic rules, with a modular architecture designed for iterative LLM-assisted development.

**Language**: English-first codebase with i18n support (English + Portuguese UI).

---

## Plataformas Alvo

| Plataforma | Distribuição |
|---|---|
| **Android** | Google Play Store |
| **Web** | Browser (hosting gratuito, ex: GitHub Pages) |

Requisito: codebase única para ambas as plataformas.

---

## Tech Stack

- **Framework**: Flutter (Dart) — codebase única para Android + Web (+ potencial iOS/Desktop)
- **Alternativa considerada**: React Native (mobile) + React (web)

---

## Conceito do Jogo

### Tipo
- Jogo de dados por turnos (semelhante a mãos de poker)
- **4 jogadores**, multiplayer local (pass-and-play) no MVP

### Dados
- 5 dados
- Faces: **A (Ace/Ás), K (King/Rei), Q (Queen/Dama), J (Jack/Valete), 10 (Ten/Dez), 9 (Nine/Nove)**
- Código e lógica em inglês; UI suporta EN + PT
- Notação interna: A, K, Q, J, 10, 9
- Notação portuguesa (UI PT): A, R, D, V, X, 9
- Hierarquia: A > K > Q > J > 10 > 9 (Queen/Dama vale mais que Jack/Valete)

### Estrutura do Turno
- Um turno = **3 lançamentos**
- Entre lançamentos, o jogador pode:
  - **Segurar dados** e relançar os restantes (para construir uma mão melhor), ou
  - **Marcar pontos** e recomeçar de novo com todos os 5 dados
- Em cada lançamento, o jogador pode marcar pontos numa linha (mesmo que diferente do lançamento anterior)
- Não se pode marcar duas vezes na mesma linha de figuras no mesmo turno
- Se no turno completo (3 lançamentos) o jogador não conseguir marcar pontos nenhuns → **perde a vez**

---

## Sistema de Pontuação

### Valores Base (Linhas de Figuras)

Cada **figura** (A, K, Q, J, 10) vale **2 pontos**.
Cada **9 ("nove")** vale **1 ponto** — funciona como **wildcard**: conta como 1 ponto da figura para a qual o jogador está a jogar.

Exemplo: a jogar para Aces, saem 2A + 1×9 → total = 2×2 + 1 = **5 pontos de Aces**.

### Multiplicadores por Figura (ao fechar linha)

| Linha | EN | PT | Multiplicador |
|---|---|---|---|
| Aces | A | A (Ás) | ×6 |
| Kings | K | R (Rei) | ×5 |
| Queens | Q | D (Dama) | ×4 |
| Jacks | J | V (Valete) | ×3 |
| Tens | 10 | X (Dez) | ×2 |

Quando uma linha de figuras é fechada: **soma dos valores das 5 colunas × multiplicador**.
Se um jogador fechou a linha sem que outro(s) a tenham aberto → **o total dobra** (×2 adicional).

Exemplo Ases: (7+8+9+8+9) × 6 = **246 pontos**.
Exemplo Damas (fechada sem o outro abrir): ((8+6+6+20+8) × 4) × 2 = **384 pontos**.

### Estrutura da Tabela de Figuras

Cada linha de figura tem **5 colunas** (quadrículas) para preencher, com mínimos:

| Coluna | Posição | Mínimo para marcar |
|---|---|---|
| 1ª | Abrir | **7** |
| 2ª | — | **6** |
| 3ª | — | **6** |
| 4ª | — | **8** |
| 5ª | Fechar | **8** |

Se o jogador não atingir o mínimo, não marca nessa coluna.

### Combinações Especiais

| Combinação | Pontos | De mão (1º lançamento) |
|---|---|---|
| Sequência mínima (K, Q, J, 10, 9) | 15 | 30 |
| Sequência máxima (A, K, Q, J, 10) | 30 | 60 |
| Cinco 9s ("5 noves") | 30 | 60 |
| Cinco figuras iguais | 20 | 40 |
| Full house ("fullen") — 3+2 quaisquer | Registado | Registado |

- **"De mão"** = conseguido no primeiro lançamento → pontuação **duplica**
- 5 figuras iguais **também contam como fullen**
- 5 noves podem ser inscritos numa quadrícula de qualquer figura (A, K, Q, J ou 10)

### Totais: Sequências e Fullens

- Sequências e Fullens têm a sua própria secção na tabela
- Os totais destas linhas **apenas se somam, NÃO se multiplicam**
- Exemplo Sequências: (60+15+30+60+30) = **195 pontos**

### Regras de Fecho de Linhas

- Quando um jogador preenche todas as 5 colunas de uma linha → **linha fechada**
- Ninguém mais pode jogar para essa linha
- Se um jogador fechou a linha sem que outro(s) a tenha(m) aberto → **pontuação dobra**
- Os outros jogadores ficam com os pontos que tinham ao momento do fecho

### Fim do Jogo
- O jogo termina quando falta apenas **uma linha** por fechar
- Vence o jogador com a **maior pontuação total**

---

## Arquitectura (6 Módulos)

1. **Game Engine** — Estado do jogo, fluxo de turnos, imposição de regras
2. **Dice / RNG** — Lógica de lançamento, sistema de hold/re-roll
3. **Scoring System** — Avaliação de mãos, atribuição de pontos, regras especiais
4. **Scoreboard System** — Pontuações por jogador, tracking de categorias abertas/fechadas
5. **UI Layer** — Menu principal, ecrã de jogo (dados + controlos), scoreboard, ecrã final
6. **Persistence** — Armazenamento local do estado/histórico (opcional no MVP)

---

## Monetização (Pós-MVP)

> Decisões detalhadas e em aberto em `Documentation/PENDING_DECISIONS.md`.

- **Modelo**: freemium por feature gating — sem anúncios durante o jogo
- **Tier gratuito**: jogo local 1v1 (humano vs 1 IA) — a confirmar o resto
- **Tier premium** (compra única): até 4 jogadores, todos os achievements, todos os perfis IA, multiplayer online, temas cosméticos
- Pacote: `in_app_purchase` (Flutter oficial, Android + iOS)
- **Não iniciado** — roadmap: Web → Android → Multiplayer → Monetização → iOS

---

## Funcionalidades Futuras

### AI Profiles (Jogadores IA)
Perfis de comportamento para jogadores controlados por IA:
- **Poker profile** — aposta agressivamente em pokers (segura 4 iguais, espera para completar de mão)
- **FromHand profile** — tenta sempre jogar "de mão" (nunca segura dados, relança sempre tudo)
- **Balanced profile** — estratégia equilibrada (mistura scoring normal com especiais)
- **Dreamer profile** — joga exclusivamente para poker; aceita resultados não-poker apenas quando surgem de mão

### Estado Actual de Balanceamento (mixed-fair, 100000 jogos)
- aggressive: 34.911% de vitórias
- balanced: 29.248% de vitórias
- cautious: 26.918% de vitórias
- dreamer: 8.923% de vitórias

Leitura rápida: o perfil Dreamer está funcional e coerente com a identidade temática, mas está claramente abaixo em competitividade quando comparado com os restantes perfis.

### Achievements (Conquistas)
Sistema de conquistas para desbloquear ao longo dos jogos:
- "Royal Poker!" — conseguir um Poker Real (4A + K de mão)
- "Cinco Noves de mão" — 5 noves no primeiro lançamento
- "Muro!" — fechar uma linha sem que outro jogador a tenha aberto
- "Sequência perfeita" — Max Straight de mão
- "Full House Master" — X fullens num jogo
- Etc. (expandir durante desenvolvimento)

---

## Deploy

| Item | Custo |
|---|---|
| Desenvolvimento | Gratuito |
| Google Play Store | ~$25 (taxa única) |
| Web hosting | Gratuito (GitHub Pages) |

---

## Questões Em Aberto (a resolver antes da implementação)

- ~~**A)** Definição completa da tabela de categorias~~ → **RESOLVIDO** (5 linhas figuras + sequências + fullens)
- ~~**B)** Requisitos mínimos por categoria~~ → **RESOLVIDO** (7/6/6/8/8 por coluna)
- **C)** Ranking / prioridade de mãos (para desempate — confirmar se necessário)
- ~~**D)** Lógica de locking de categorias~~ → **RESOLVIDO** (fechar = preencher 5 colunas; sem abrir = dobra)
- ~~**E)** Resolução de turnos~~ → **RESOLVIDO** (turno = 3 lançamentos; se não marcar nada no turno, perde a vez)
- ~~**F)** Scope multiplayer~~ → **RESOLVIDO** (MVP = 4 jogadores, local pass-and-play)
- ~~**G)** Variante para MVP~~ → **RESOLVIDO** (regras base + variantes 1 e 2 incluídas)
- ~~**H)** Notação~~ → **RESOLVIDO** (código em inglês; UI bilingue EN + PT)

---

## Variantes (Incluídas nas regras base)

### Variante 1 — Poker
- Se saírem **4 figuras iguais** (ex: V, V, V, D, V) → **Poker**
- Só pontua se for **de mão** (todos os 5 dados lançados, sem dados segurados)
- Cada poker vale **100 pontos**
- **Poker Real** (4 Ases + 1 Rei) vale **200 pontos**
- Adiciona uma linha extra no final da tabela (não é necessário fechar para concluir o jogo)

### Variante 2 — Soma das Figuras (Acumulação)
- Permite **acumular pontos** da mesma figura ao longo dos 3 lançamentos, na mesma quadrícula
- Ex: 1º lançamento D,D,D,D,9 = 9 pts → 2º lançamento D,X,R,R,9 = +3 → 3º lançamento D,R,D,V,9 = +5 → total na coluna
- Nesta variante o jogador pode segurar dados entre lançamentos para construir a combinação

### Decisão
- **MVP com variantes 1 e 2 incluídas nas regras base**

---

## Constraints de Desenvolvimento

- **LLM-friendly**: modular, testável, incremental
- **Separação clara**: lógica vs UI
- **Desenvolvimento iterativo**: gerado por LLM → revisão → teste → iteração
