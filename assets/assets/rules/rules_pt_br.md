# Poker de Dados — Regras do Jogo (Português do Brasil)

> Bem-vindo ao Poker de Dados! Divirta-se jogando este clássico jogo português.
> Esta página contém primeiro uma referência rápida e depois as regras completas.

> 📌 No fim desta página você encontra um [**Resumo Visual**](#resumo) de todas as regras.

---

## Referência Rápida

| | |
|---|---|
| **Jogadores** | 2 a 4 |
| **Dados** | 5 dados com faces: A · K · Q · J · 10 · 9 |
| **Turno** | Até 3 lançamentos |
| **Objetivo** | Maior pontuação total quando o jogo termina |
| **Fim do jogo** | Quando 6 das 7 linhas não-poker estão fechadas |

**Faces (hierarquia decrescente):**

| Face | Nome |
|---|---|
| A | Ás |
| K | Rei |
| Q | Dama |
| J | Valete |
| 10 | Dez |
| 9 | Noves (coringa) |

<!-- FACE_LEGEND -->

O **9 (Noves)** é um coringa: conta 1 ponto para qualquer figura na qual o jogador esteja jogando.

> **Nota:** Não há naipes — o jogo se baseia apenas nas faces dos dados.

---

## Regras Completas

### 1. Estrutura do Turno

Um turno consiste em **até 3 lançamentos**. Em cada lançamento, o jogador pode:

- **Segurar dados** — selecionar dados para manter e relançar os restantes no próximo lançamento.
- **Marcar pontos** — registrar o resultado em uma linha elegível e recolher todos os 5 dados para o próximo lançamento.
- **Passar** — avançar para o próximo lançamento sem marcar nem segurar.

> **Nota:** No início de cada turno, você lança os 5 dados — automaticamente, ou com o botão «Lançar» se tiver o *primeiro lançamento manual* ativado. Este é o primeiro lançamento.

Se no fim dos 3 lançamentos o jogador **não tiver marcado pontos**, perde a vez (sem penalização).

É possível marcar em **linhas diferentes** ao longo do mesmo turno (ex: marcar Ases no lançamento 1 e Reis no lançamento 2), e também **na mesma linha em lançamentos diferentes** dentro do mesmo turno (cada marcação vai para a coluna seguinte disponível).

---

### 2. Tabela de Pontuação

A tabela de cada jogador tem **8 linhas**:

| # | Linha | Tipo |
|---|---|---|
| 1 | Ases (A) | Figura |
| 2 | Reis (K) | Figura |
| 3 | Damas (Q) | Figura |
| 4 | Valetes (J) | Figura |
| 5 | Dez (10) | Figura |
| 6 | Sequências | Especial |
| 7 | Fullens | Especial |
| 8 | Poker | Especial |

**Aspecto da tabela antes de qualquer entrada:**

| Linha | ≥7 | ≥6 | ≥6 | ≥8 | ≥8 |
|---|:---:|:---:|:---:|:---:|:---:|
| A (×6) | | | | | |
| K (×5) | | | | | |
| Q (×4) | | | | | |
| J (×3) | | | | | |
| 10 (×2) | | | | | |
| Sequências | | | | | |
| Fullens | | | | | |
| Poker | | | | | |

---

### 3. Linhas de Figura (A, K, Q, J, 10)

#### Cálculo de pontos

Ao marcar para uma figura, conta-se:

```
pontos = (nº de dados com a figura × 2) + (nº de 9s × 1)
```

Exemplos (marcando para Damas):

**[Q, Q, Q, 9, K]** → 3×2 + 1×1 = **7 pts**
<!-- DICE: Q,Q,Q,9,K -->

**[Q, 9, 9, 9, A]** → 1×2 + 3×1 = **5 pts**
<!-- DICE: Q,9,9,9,A -->

**[Q, Q, Q, Q, 9]** → 4×2 + 1×1 = **9 pts**
<!-- DICE: Q,Q,Q,Q,9 -->

#### Colunas e mínimos

Cada linha de figura tem **5 colunas** que devem ser preenchidas da esquerda para a direita:

| Coluna | Nome | Mínimo |
|---|---|---|
| 1ª | Abrir | **≥ 7** |
| 2ª | — | **≥ 6** |
| 3ª | — | **≥ 6** |
| 4ª | — | **≥ 8** |
| 5ª | Fechar | **≥ 8** |

Se os pontos do lançamento não atingirem o mínimo da coluna seguinte, **não é possível marcar** nessa linha.

#### Fechar uma linha

Uma linha fica **fechada** quando um jogador preenche as 5 colunas. Ninguém mais pode marcar nessa linha depois disso.

#### Multiplicadores

| Linha | Multiplicador |
|---|---|
| Ases (A) | × 6 |
| Reis (K) | × 5 |
| Damas (Q) | × 4 |
| Valetes (J) | × 3 |
| Dez (10) | × 2 |

**Bônus de fechamento:** Se o fechador fechar uma linha sem que algum jogador a tenha aberto, a pontuação de **todos os jogadores que a abriram** (incluindo o fechador) **dobra**. Esta regra se aplica também às linhas de Sequências e Fullens (o Poker não conta).

---

### 4. Regra "De Mão"

Uma combinação é **"de mão"** quando é obtida em um lançamento em que **todos os 5 dados foram lançados** (sem dados segurados). Nessas condições, a pontuação das combinações especiais **dobra**.

---

### 5. Combinações Especiais

#### 5.1 Sequências

| Sequência | Faces | Pontos | De mão |
|---|---|---|---|
| Mínima | K · Q · J · 10 · 9 | 15 | **30** |
| Máxima | A · K · Q · J · 10 | 30 | **60** |

Sequência mínima:
<!-- DICE: K,Q,J,10,9 -->

Sequência máxima:
<!-- DICE: A,K,Q,J,10 -->

#### 5.2 Fullen (Full House)

Qualquer combinação de **3 de uma face + 2 de outra** (incluindo 9s).

Exemplo: **[A, A, A, K, K]** (3 Ases + 2 Reis)
<!-- DICE: A,A,A,K,K -->

| Pontos | De mão |
|---|---|
| 15 | **30** |

#### 5.3 Cinco Iguais

Exemplo: **[K, K, K, K, K]**
<!-- DICE: K,K,K,K,K -->

| Pontos | De mão |
|---|---|
| 20 | **40** |

Também conta como Fullen.

#### 5.4 Cinco 9s (Noves)

Exemplo: **[9, 9, 9, 9, 9]**
<!-- DICE: 9,9,9,9,9 -->

| Pontos | De mão |
|---|---|
| 30 | **60** |

Pode ser registrado na coluna seguinte de **qualquer linha de figura**.

#### 5.5 Poker (4 de uma face — apenas de mão)

| Tipo | Condição | Pontos |
|---|---|---|
| Poker | 4 iguais de mão | **100** |
| Poker Real | 4 Ases + 1 Rei de mão | **200** |

Poker — **[K, K, K, K, Q]**:
<!-- DICE: K,K,K,K,Q -->

Poker Real — **[A, A, A, A, K]**:
<!-- DICE: A,A,A,A,K -->

---

### 6. Modo Acumulação

Ativado automaticamente quando, ao marcar em uma linha de figura, **todos os 5 dados** mostram a figura alvo ou 9.

Exemplo (jogando para Damas — todos contam): **[Q, Q, Q, 9, 9]**
<!-- DICE: Q,Q,Q,9,9 -->

O jogador pode continuar relançando e acumulando pontos. O total acumulado é registrado na coluna ao finalizar (se atingir o mínimo).

---

### 7. Fim do Jogo e Vencedor

O jogo termina quando **6 das 7 linhas não-poker** estão fechadas. Contam para o fim: as 5 linhas de figura + Sequências + Fullens. O **Poker não conta** para o fim do jogo.

```
Total = (soma das 5 linhas × multiplicadores) + Sequências + Fullens + Poker
```

Vence o jogador com a **maior pontuação total**.

---

### 8. Resumo Visual

```
┌──────────────────────────────────────────────────────────────┐
│  TURNO: 3 lançamentos                                        │
│                                                              │
│  Lançamento → Segurar dados?                                 │
│                └─ Sim → próximo lançamento (mantém dados)    │
│                └─ Não → Marcar numa linha elegível           │
│                          (recolhe todos, conta como de mão)  │
│                        → Passar (sem pontos, sem segurar)    │
│                                                              │
│  Após 3 lançamentos → perde a vez                            │
└──────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────┐
│  LINHAS DE FIGURA: 5 colunas, da esquerda para a direita  │
│  Mín: ≥7 · ≥6 · ≥6 · ≥8 · ≥8                              │
│  Total final × multiplicador (×2 se fechou sem abertura)  │
└───────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────┐
│  ESPECIAIS (somam, não multiplicam)        │
│  Seq. mínima: 15 / de mão: 30              │
│  Seq. máxima: 30 / de mão: 60              │
│  Fullen:      15 / de mão: 30              │
│  Cinco iguais: 20 / de mão: 40             │
│  Cinco 9s:    30 / de mão: 60              │
│  Poker:      100 / Real:  200 (só de mão)  │
└────────────────────────────────────────────┘
```

---

*Poker de Dados v1.0 — Baseado no Pôquer de Dados tradicional português.*

