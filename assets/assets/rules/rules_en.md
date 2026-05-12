# Dice Poker — Game Rules

> Dice Poker is the digital version of the classic Portuguese game **Poker de Dados**.
> This page contains a quick reference followed by the complete rules.

---

## Quick Reference

| | |
|---|---|
| **Players** | 2 to 4 |
| **Dice** | 5 dice with faces: A · K · Q · J · 10 · 9 |
| **Turn** | Up to 3 rolls |
| **Goal** | Highest total score when the game ends |
| **End of game** | When only 1 figure row remains open |

**Faces (descending hierarchy):**

| Face | Name |
|---|---|
| A | Ace |
| K | King |
| Q | Queen |
| J | Jack |
| 10 | Ten |
| 9 | Nine (wildcard) |

The **9 (Nine)** is a wildcard: it scores 1 point for any figure the player is currently scoring for.

---

## Complete Rules

### 1. Turn Structure

A turn consists of **up to 3 rolls**. On each roll, the player may:

- **Hold dice** — select dice to keep and re-roll the rest on the next roll.
- **Score** — record the result in an eligible row and collect all 5 dice for the next roll.
- **Pass** — advance to the next roll without scoring or holding.

If the player has **not scored anything** after all 3 rolls, they lose their turn (no penalty).

It is possible to score in **different rows** across the same turn, but **you cannot score twice in the same row in the same turn**.

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

---

### 3. Figure Rows (A, K, Q, J, 10)

#### Points calculation

When scoring for a figure:

```
points = (number of dice showing the figure × 2) + (number of Nines × 1)
```

Examples (scoring for Queens):
- [Q, Q, Q, 9, K] → 3×2 + 1×1 = **7 pts**
- [Q, 9, 9, 9, A] → 1×2 + 3×1 = **5 pts**
- [Q, Q, Q, Q, 9] → 4×2 + 1×1 = **9 pts**

#### Noves (all-nine roll)

A roll of **[9, 9, 9, 9, 9]** (five Nines) is called a **Noves**. When scored for any figure row, it awards **10 points**.

---

### 4. Special Rows

#### Sequences

A sequence is a set of **at least 3 consecutive faces** (e.g. A-K-Q, K-Q-J, Q-J-10, J-10-9).

Points:
- 3-card sequence: **3 pts**
- 4-card sequence: **6 pts**
- 5-card sequence: **10 pts**

Nines may complete a sequence (acting as any adjacent face).

#### Full Houses

A full house is **3 dice of one face + 2 dice of another face** (e.g. [A, A, A, K, K]).

Points:
- Standard full house: **7 pts**
- Full house with 3 Nines: **8 pts**
- Full house with 2 Nines: **9 pts** (Nines pair)
- Five of a kind (all same face or all Nines): **10 pts**

#### Poker

A poker is **4 or 5 dice of the same face**.

Points:
- 4 of a kind: **8 pts**
- 4 of a kind + 1 Nine: **9 pts**
- 5 of a kind: **10 pts**
- Noves (5 Nines): **10 pts**

---

### 5. End of Game

The game ends when **only 1 figure row remains open** across all players. All players complete their current turn before final scores are tallied.

The player with the **highest total score** wins.
