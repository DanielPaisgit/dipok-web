# Poker de Dados — Regras do Jogo / Game Rules

> Poker de Dados é a versão digital do clássico jogo português **Poker de Dados**.
> Esta página contém primeiro uma referência rápida e depois as regras completas.

---

## Referência Rápida

| | |
|---|---|
| **Jogadores** | 2 a 4 |
| **Dados** | 5 dados com faces: A · K · Q · J · 10 · 9 |
| **Turno** | Até 3 lançamentos |
| **Objectivo** | Maior pontuação total quando o jogo termina |
| **Fim do jogo** | Quando faltam apenas 1 linha de figura por fechar |

**Faces (hierarquia decrescente):**

| EN | PT | Pronuncia |
|---|---|---|
| A (Ace) | A (Ás) | |
| K (King) | R (Rei) | |
| Q (Queen) | D (Dama) | |
| J (Jack) | V (Valete) | |
| 10 (Ten) | X (Dez) | |
| 9 (Nine) | 9 (Pilo) | wildcard |

O **9 (Pilo)** é um wildcard: conta 1 ponto para qualquer figura em que o jogador esteja a jogar.

---

## Regras Completas

### 1. Estrutura do Turno

Um turno consiste em **até 3 lançamentos**. Em cada lançamento, o jogador pode:

- **Segurar dados** — seleccionar dados para manter e relançar os restantes no próximo lançamento.
- **Marcar pontos** — inscrever o resultado numa linha elegível e recolher todos os 5 dados para o próximo lançamento.
- **Passar** — avançar para o próximo lançamento sem marcar nem segurar.

Se no fim das 3 lançamentos o jogador **não tiver marcado pontos nenhuns**, perde a vez (sem penalização).

Pode-se marcar em **linhas diferentes** ao longo do mesmo turno (ex: marcar Ases no lançamento 1 e Reis no lançamento 2), mas **não é possível marcar duas vezes na mesma linha no mesmo turno**.

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

---

### 3. Linhas de Figura (A, K, Q, J, 10)

#### Cálculo de pontos

Ao marcar para uma figura, conta-se:

```
pontos = (nº de dados com a figura × 2) + (nº de 9s × 1)
```

Exemplos (a marcar para Damas):
- [Q, Q, Q, 9, K] → 3×2 + 1×1 = **7 pts**
- [Q, 9, 9, 9, A] → 1×2 + 3×1 = **5 pts**
- [Q, Q, Q, Q, 9] → 4×2 + 1×1 = **9 pts**

#### Colunas e mínimos

Cada linha de figura tem **5 colunas** que têm de ser preenchidas da esquerda para a direita:

| Coluna | Nome | Mínimo |
|---|---|---|
| 1ª | Abrir | **≥ 7** |
| 2ª | — | **≥ 6** |
| 3ª | — | **≥ 6** |
| 4ª | — | **≥ 8** |
| 5ª | Fechar | **≥ 8** |

Se os pontos do lançamento não atingirem o mínimo da coluna seguinte, **não é possível marcar** nessa linha.

#### Fechar uma linha

Uma linha fica **fechada** quando um jogador preenche as 5 colunas. Ninguém mais pode marcar nessa linha depois disso — todos ficam com os pontos que tinham registados até então.

#### Multiplicadores (aplicados ao total final da linha)

| Linha | Multiplicador |
|---|---|
| Ases (A) | × 6 |
| Reis (K) | × 5 |
| Damas (Q) | × 4 |
| Valetes (J) | × 3 |
| Dez (10) | × 2 |

**Bónus de fecho sem abertura:** Se o jogador que fechou a linha o fez sem que algum outro jogador tivesse aberto essa linha, a pontuação do fechador **duplica** (os outros jogadores que a abriram recebem pontuação normal).

Exemplo (Ases, ×6):

| Jogador | Colunas | Cálculo | Total |
|---|---|---|---|
| Ana (fechou) | 7 · 8 · 9 · 8 · 9 = 41 | 41 × 6 × 2 | **492** |
| Bruno (abriu) | 7 · 8 = 15 | 15 × 6 | **90** |
| Carla (nunca abriu) | — | 0 | **0** |

---

### 4. Combinações Especiais

#### 4.1 Sequências

Uma sequência é um conjunto específico de 5 faces diferentes (a ordem dos dados não importa):

| Sequência | Faces | Pontos | De mão |
|---|---|---|---|
| Mínima | K · Q · J · 10 · 9 | 15 | **30** |
| Máxima | A · K · Q · J · 10 | 30 | **60** |

Registam-se na linha de **Sequências**.

#### 4.2 Fullen (Full House)

Qualquer combinação de **3 de uma face + 2 de outra face** (incluindo 9s).

Exemplos: [A,A,A,K,K], [Q,Q,9,9,9], [J,J,J,10,10]

| Pontos | De mão |
|---|---|
| 15 | **30** |

Registam-se na linha de **Fullens** (o total é a soma de todos os fullens inscritos).

#### 4.3 Cinco Iguais

Cinco dados com a mesma face (excluindo 9s):

| Pontos | De mão |
|---|---|
| 20 | **40** |

Inscreve-se na **coluna seguinte da figura correspondente**.
Também conta como Fullen (o jogador pode optar por registar na linha de fullens).

#### 4.4 Cinco 9s ("Pilada")

Cinco dados com face 9:

| Pontos | De mão |
|---|---|
| 30 | **60** |

Pode ser inscrito na coluna seguinte de **qualquer linha de figura** (à escolha do jogador).

#### 4.5 Poker (4 de uma face — apenas de mão)

**Só conta se for de mão** (nenhum dado segurado no lançamento). Quatro dados com a mesma face (não 9s):

| Tipo | Condição | Pontos |
|---|---|---|
| Poker | 4 iguais de mão | **100** |
| Poker Real | 4 Ases + 1 Rei de mão | **200** |

Registam-se na linha de **Poker**. Esta linha nunca "fecha" e não conta para o fim do jogo.

---

### 5. Regra "De Mão"

Uma combinação é **"de mão"** quando é conseguida num lançamento em que **todos os 5 dados foram lançados** (sem dados segurados). Isto pode acontecer em qualquer um dos 3 lançamentos:
- Sempre no 1º lançamento.
- No 2º ou 3º se o jogador marcou pontos no lançamento anterior (recolheu todos os dados).

Quando se verifica "de mão", a pontuação das combinações especiais **duplica**.

---

### 6. Modo Acumulação

O modo acumulação é activado **automaticamente** quando, ao marcar numa linha de figura, **todos os 5 dados** mostram a figura alvo ou 9.

**Mecânica:**
1. O jogador marca o lançamento corrente — esse valor torna-se o **acumulado**.
2. Pode **continuar** (relançar todos os 5 dados) e adicionar ao acumulado.
3. Se após um relançamento nem todos os dados correspondem, pode **segurar dados** e relançar os restantes.
4. A qualquer momento pode **finalizar** — o acumulado é registado na coluna (se atingir o mínimo).
5. **Passar** durante acumulação finaliza automaticamente.

**Limitações:**
- Em modo acumulação não é possível marcar noutras linhas.
- Combinações especiais detectadas durante acumulação são ignoradas.
- A regra "de mão" não se aplica em acumulação.

---

### 7. Fim do Jogo e Vencedor

O jogo termina quando **apenas 1 linha de figura** permanece por fechar (4 de 5 fechadas).

A pontuação final de cada jogador é:

```
Total = (soma das 5 linhas de figura × multiplicadores) + Sequências + Fullens + Poker
```

Vence o jogador com a **maior pontuação total**.

---

### 8. Resumo Visual

```
┌─────────────────────────────────────────────────────────────┐
│  TURNO: 3 lançamentos                                       │
│                                                             │
│  Lançamento → Segurar dados?                                │
│              └─ Sim → próximo lançamento (mantém dados)     │
│              └─ Não  → Marcar numa linha elegível           │
│                        (recolhe todos, conta como de mão)   │
│                      → Passar (sem pontos, sem segurar)     │
│                                                             │
│  Após 3 lançamentos sem marcar nada → perde a vez           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  LINHAS DE FIGURA: 5 colunas, preenchidas da esq. p/ dir.  │
│  Min: ≥7 · ≥6 · ≥6 · ≥8 · ≥8                              │
│  Total final × multiplicador (×2 se fechou sem abertura)   │
└─────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│  ESPECIAIS (somam, não multiplicam)          │
│  Seq mínima: 15 / de mão: 30                │
│  Seq máxima: 30 / de mão: 60                │
│  Fullen:     15 / de mão: 30                │
│  5 iguais:   20 / de mão: 40                │
│  5 noves:    30 / de mão: 60                │
│  Poker:     100 / Royal:  200 (só de mão)   │
└──────────────────────────────────────────────┘
```

---

*Poker de Dados v1.0 — Baseado no Poker de Dados tradicional português.*

