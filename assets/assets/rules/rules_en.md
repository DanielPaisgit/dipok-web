# Dice Poker — Game Rules

> Welcome to Dice Poker! Enjoy playing this classic Portuguese game.
> This page contains a quick reference first, then the complete rules.

> 📌 At the end of this page you'll find a [**Visual Summary**](#resumo) of all the rules.

---

## Quick Reference

| | |
|---|---|
| **Players** | 2 to 4 |
| **Dice** | 5 dice with faces: A · K · Q · J · 10 · 9 |
| **Turn** | Up to 3 rolls |
| **Goal** | Highest total score when the game ends |
| **End of game** | When 6 of 7 non-poker rows are closed |

**Faces (descending hierarchy):**

| Face | Name |
|---|---|
| A | Ace |
| K | King |
| Q | Queen |
| J | Jack |
| 10 | Ten |
| 9 | Nine (wildcard) |

<!-- FACE_LEGEND -->

The **9 (Nine)** is a wildcard: it scores 1 point for any figure the player is currently scoring for.

> **Note:** There are no suits — the game is based on face values only.

---

## Complete Rules

### 1. Turn Structure

A turn consists of **up to 3 rolls**. On each roll, the player may:

- **Hold dice** — select dice to keep and re-roll the rest on the next roll.
- **Score** — record the result in an eligible row and collect all 5 dice for the next roll.
- **Pass** — advance to the next roll without scoring or holding.

> **Note:** At the start of each turn, all 5 dice are rolled — automatically, or with the **Roll** button if *manual first roll* is enabled. This is the first roll.

If the player has **not scored anything** after all 3 rolls, they lose their turn (no penalty).

It is possible to score in **different rows** across the same turn, and also in **the same row on different rolls** within the same turn (each entry fills the next available column).

---

### 2. Score Table

Each player's table has **8 rows**:

| # | Row | Type |
|---|---|---|
| 1 | Aces (A) | Figure |
| 2 | Kings (K) | Figure |
| 3 | Queens (Q) | Figure |
| 4 | Jacks (J) | Figure |
| 5 | Tens (10) | Figure |
| 6 | Sequences | Special |
| 7 | Full Houses | Special |
| 8 | Poker | Special |

**Empty table before any entries:**

| Row | ≥7 | ≥6 | ≥6 | ≥8 | ≥8 |
|---|:---:|:---:|:---:|:---:|:---:|
| A (×6) | | | | | |
| K (×5) | | | | | |
| Q (×4) | | | | | |
| J (×3) | | | | | |
| 10 (×2) | | | | | |
| Sequences | | | | | |
| Full Houses | | | | | |
| Poker | | | | | |

---

### 3. Figure Rows (A, K, Q, J, 10)

#### Points calculation

When scoring for a figure:

```
points = (number of dice showing the figure × 2) + (number of Nines × 1)
```

Examples (scoring for Queens):

**[Q, Q, Q, 9, K]** → 3×2 + 1×1 = **7 pts**
<!-- DICE: Q,Q,Q,9,K -->

**[Q, 9, 9, 9, A]** → 1×2 + 3×1 = **5 pts**
<!-- DICE: Q,9,9,9,A -->

**[Q, Q, Q, Q, 9]** → 4×2 + 1×1 = **9 pts**
<!-- DICE: Q,Q,Q,Q,9 -->

#### Columns and minimums

Each figure row has **5 columns** that must be filled from left to right:

| Column | Name | Minimum |
|---|---|---|
| 1st | Open | **≥ 7** |
| 2nd | — | **≥ 6** |
| 3rd | — | **≥ 6** |
| 4th | — | **≥ 8** |
| 5th | Close | **≥ 8** |

If the roll's points don't reach the next column's minimum, **you cannot score** in that row.

#### Closing a row

A row is **closed** when a player fills all 5 columns. No one else can score in that row afterwards — everyone keeps the points they had recorded until then.

#### Multipliers (applied to the row's final total)

| Row | Multiplier |
|---|---|
| Aces (A) | × 6 |
| Kings (K) | × 5 |
| Queens (Q) | × 4 |
| Jacks (J) | × 3 |
| Tens (10) | × 2 |

**Close-without-open bonus:** If the closer closes a row without any player having opened it, the score of **all players who opened it** (including the closer) is **doubled**. This rule also applies to the Sequences and Full Houses rows (Poker doesn't count).

Example (Aces, ×6):

| Player | Columns | Calculation | Total |
|---|---|---|---|
| Ana (closed) | 7 · 8 · 9 · 8 · 9 = 41 | 41 × 6 × 2 | **492** |
| Bruno (opened) | 7 · 8 = 15 | 15 × 6 × 2 | **180** |
| Carla (never opened) | — | 0 | **0** |

---

### 4. "From Hand" Rule

A combination is **"from hand"** when it is achieved on a roll where **all 5 dice were thrown** (no dice held). This can happen on any of the 3 rolls:
- Always on the 1st roll.
- On the 2nd or 3rd whenever you re-roll all 5 dice without holding any — whether you scored on the previous roll (collected all dice) or simply chose to re-roll everything.

When a combination is "from hand", the score of special combinations is **doubled**.

---

### 5. Special Combinations

#### 5.1 Sequences

A sequence is a specific set of 5 different faces (dice order doesn't matter):

| Sequence | Faces | Points | From hand |
|---|---|---|---|
| Minimum | K · Q · J · 10 · 9 | 15 | **30** |
| Maximum | A · K · Q · J · 10 | 30 | **60** |

Minimum sequence:
<!-- DICE: K,Q,J,10,9 -->

Maximum sequence:
<!-- DICE: A,K,Q,J,10 -->

Recorded in the **Sequences** row.

#### 5.2 Full House (Fullen)

Any combination of **3 of one face + 2 of another face** (including 9s).

Example: **[A, A, A, K, K]** (3 Aces + 2 Kings)
<!-- DICE: A,A,A,K,K -->

Other examples: [Q, Q, 9, 9, 9], [J, J, J, 10, 10]

| Points | From hand |
|---|---|
| 15 | **30** |

Recorded in the **Full Houses** row (the total is the sum of all full houses entered).

#### 5.3 Five of a Kind

Five dice with the same face (excluding 9s):

Example: **[K, K, K, K, K]**
<!-- DICE: K,K,K,K,K -->

| Points | From hand |
|---|---|
| 20 | **40** |

Entered in the **next column of the matching figure**.
Also counts as a Full House (the player may choose to record it in the full houses row).

#### 5.4 Five 9s (Noves)

Five dice showing the 9 face:

Example: **[9, 9, 9, 9, 9]**
<!-- DICE: 9,9,9,9,9 -->

| Points | From hand |
|---|---|
| 30 | **60** |

May be entered in the next column of **any figure row** (player's choice).

#### 5.5 Poker (4 of a face — from hand only)

**Only counts if from hand** (no dice held on the roll). Four dice with the same face (including 9s — four 9s is a valid poker):

| Type | Condition | Points |
|---|---|---|
| Poker | 4 of a kind from hand | **100** |
| Royal Poker | 4 Aces + 1 King from hand | **200** |

Poker — **[K, K, K, K, Q]**:
<!-- DICE: K,K,K,K,Q -->

Royal Poker — **[A, A, A, A, K]**:
<!-- DICE: A,A,A,A,K -->

Recorded in the **Poker** row. This row never "closes" and doesn't count towards the end of the game.

---

### 6. Accumulation Mode

Accumulation mode is activated **automatically** when, upon scoring in a figure row, **all 5 dice** show the target figure or 9.

Example (scoring for Queens — all count): **[Q, Q, Q, 9, 9]**
<!-- DICE: Q,Q,Q,9,9 -->

**Mechanics:**
1. The player scores the current roll — that value becomes the **accumulated** total.
2. They may **continue** (re-roll all 5 dice) and add to the accumulated total.
3. If after a re-roll not all dice match, they may **hold dice** and re-roll the rest.
4. At any point they may **finalize** — the accumulated total is recorded in the column (if it reaches the minimum).
5. **Passing** during accumulation finalizes automatically.

**Limitations:**
- During accumulation you cannot score in other rows.
- Special combinations detected during accumulation are ignored.
- The "from hand" rule doesn't apply during accumulation.

---

### 7. End of Game and Winner

The game ends when **6 of the 7 non-poker rows** are closed. Counting towards the end: the 5 figure rows + Sequences + Full Houses. **Poker does not count** towards the end of the game.

Each player's final score is:

```
Total = (sum of the 5 figure rows × multipliers) + Sequences + Full Houses + Poker
```

The player with the **highest total score** wins.

---

### 8. Visual Summary

```
┌─────────────────────────────────────────────────────────────┐
│  TURN: 3 rolls                                              │
│                                                             │
│  Roll → Hold dice?                                          │
│         └─ Yes → next roll (keeps dice)                     │
│         └─ No  → Score in an eligible row                   │
│                  (collects all, counts as from hand)        │
│                → Pass (no points, no holding)               │
│                                                             │
│  After 3 rolls → lose the turn                              │
└─────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│  FIGURE ROWS: 5 columns, filled left to right              │
│  Min: ≥7 · ≥6 · ≥6 · ≥8 · ≥8                               │
│  Final total × multiplier (×2 if closed without opening)   │
└────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────┐
│  SPECIALS (add up, don't multiply)            │
│  Min seq:    15 / from hand: 30               │
│  Max seq:    30 / from hand: 60               │
│  Full house: 15 / from hand: 30               │
│  5 of a kind: 20 / from hand: 40              │
│  5 nines:    30 / from hand: 60               │
│  Poker:     100 / Royal:  200 (from hand only)│
└───────────────────────────────────────────────┘
```

---

*Dice Poker v1.0 — Based on the traditional Portuguese Poker de Dados.*
