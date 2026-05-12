# Poker de Dados — Regras do Jogo (Português do Brasil)

> Poker de Dados é a versão digital do clássico jogo português **Pôquer de Dados**.
> Esta página contém primeiro uma referência rápida e depois as regras completas.

---

## Referência Rápida

| | |
|---|---|
| **Jogadores** | 2 a 4 |
| **Dados** | 5 dados com faces: A · K · Q · J · 10 · 9 |
| **Turno** | Até 3 lançamentos |
| **Objetivo** | Maior pontuação total quando o jogo termina |
| **Fim do jogo** | Quando falta apenas 1 linha de figura por fechar |

**Faces (hierarquia decrescente):**

| Face | Nome |
|---|---|
| A | Ás |
| K | Rei |
| Q | Dama |
| J | Valete |
| 10 | Dez |
| 9 | Noves (coringa) |

O **9 (Noves)** é um coringa: conta 1 ponto para qualquer figura na qual o jogador esteja jogando.

---

## Regras Completas

### 1. Estrutura do Turno

Um turno consiste em **até 3 lançamentos**. Em cada lançamento, o jogador pode:

- **Segurar dados** — selecionar dados para manter e relançar os restantes no próximo lançamento.
- **Marcar pontos** — registrar o resultado em uma linha elegível e recolher todos os 5 dados para o próximo lançamento.
- **Passar** — avançar para o próximo lançamento sem marcar nem segurar.

Se no fim dos 3 lançamentos o jogador **não tiver marcado pontos**, perde a vez (sem penalização).

É possível marcar em **linhas diferentes** ao longo do mesmo turno (ex: marcar Ases no lançamento 1 e Reis no lançamento 2), mas **não é possível marcar duas vezes na mesma linha no mesmo turno**.

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

Exemplos (marcando para Damas):
- [Q, Q, Q, 9, K] → 3×2 + 1×1 = **7 pts**
- [Q, 9, 9, 9, A] → 1×2 + 3×1 = **5 pts**
- [Q, Q, Q, Q, 9] → 4×2 + 1×1 = **9 pts**

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

**Bônus de fechamento:** Se o jogador que fechou a linha o fez sem que algum outro jogador tivesse aberto essa linha, a pontuação do fechador **dobra**.

---

### 4. Combinações Especiais

#### 4.1 Sequências

| Sequência | Faces | Pontos | De mão |
|---|---|---|---|
| Mínima | K · Q · J · 10 · 9 | 15 | **30** |
| Máxima | A · K · Q · J · 10 | 30 | **60** |

#### 4.2 Fullen (Full House)

Qualquer combinação de **3 de uma face + 2 de outra** (incluindo 9s).

| Pontos | De mão |
|---|---|
| 15 | **30** |

#### 4.3 Cinco Iguais

| Pontos | De mão |
|---|---|
| 20 | **40** |

Também conta como Fullen.

#### 4.4 Cinco 9s ("Pilada")

| Pontos | De mão |
|---|---|
| 30 | **60** |

Pode ser registrado na coluna seguinte de **qualquer linha de figura**.

#### 4.5 Poker (4 de uma face — apenas de mão)

| Tipo | Condição | Pontos |
|---|---|---|
| Poker | 4 iguais de mão | **100** |
| Poker Real | 4 Ases + 1 Rei de mão | **200** |

---

### 5. Regra "De Mão"

Uma combinação é **"de mão"** quando é obtida em um lançamento em que **todos os 5 dados foram lançados** (sem dados segurados). Nessas condições, a pontuação das combinações especiais **dobra**.

---

### 6. Modo Acumulação

Ativado automaticamente quando, ao marcar em uma linha de figura, **todos os 5 dados** mostram a figura alvo ou 9.

O jogador pode continuar relançando e acumulando pontos. O total acumulado é registrado na coluna ao finalizar (se atingir o mínimo).

---

### 7. Fim do Jogo e Vencedor

O jogo termina quando **apenas 1 linha de figura** permanece por fechar.

```
Total = (soma das 5 linhas × multiplicadores) + Sequências + Fullens + Poker
```

Vence o jogador com a **maior pontuação total**.

---

*Poker de Dados v1.0 — Baseado no Pôquer de Dados tradicional português.*

