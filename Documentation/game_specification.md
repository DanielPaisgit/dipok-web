# Dice Poker — Formal Game Specification
## Version 1.1 (MVP)

> This document formalizes all game rules into precise, unambiguous definitions
> ready to be translated into code. It serves as the single source of truth
> for the game engine implementation.

---

## 1. Constants

### 1.1 Dice Faces (enum `DieFace`)
```
A   = Ace    (value weight: 6)
K   = King   (value weight: 5)
Q   = Queen  (value weight: 4)
J   = Jack   (value weight: 3)
TEN = Ten    (value weight: 2)
NINE = Nine / "Pilo"  (wildcard)
```

Hierarchy: `A > K > Q > J > TEN > NINE`

### 1.2 Figure Lines (enum `FigureLine`)
Each figure line corresponds to a die face (excluding NINE):

| FigureLine | DieFace | Multiplier | i18n PT |
|---|---|---|---|
| `aces`   | A   | ×6 | Ases (A)   |
| `kings`  | K   | ×5 | Reis (R)   |
| `queens` | Q   | ×4 | Damas (D)  |
| `jacks`  | J   | ×3 | Valetes (V)|
| `tens`   | TEN | ×2 | Dez (X)    |

### 1.3 Special Lines (enum `SpecialLine`)
| SpecialLine | Description |
|---|---|
| `sequences` | Min/Max straights |
| `fullens`   | Full house (3+2)  |
| `poker`     | 4-of-a-kind from hand (100 / Royal 200) |

### 1.4 Column Structure
Each figure line has exactly **5 columns** (slots), indexed 0–4.

| Column Index | Position Name | Minimum Score |
|---|---|---|
| 0 | Open    | **7** |
| 1 | —       | **6** |
| 2 | —       | **6** |
| 3 | —       | **8** |
| 4 | Close   | **8** |

```dart
const columnMinimums = [7, 6, 6, 8, 8];
```

Columns must be filled **in order** (left to right). A player cannot fill column `i+1` until column `i` is filled.

### 1.5 Player Count
- MVP: exactly **4 players**
- Future: configurable (2–6)

### 1.6 Rolls Per Turn
- Exactly **3 rolls** per turn

---

## 2. Scoring Rules

### 2.1 Point Calculation for Figure Lines

Given a roll of 5 dice, when scoring for a target `FigureLine`:

```
points = (count of matching DieFace × 2) + (count of NINE × 1)
```

**NINE is a wildcard**: it always contributes 1 point toward whichever figure line the player is scoring for.

Examples:
- Scoring for Aces, roll = [A, A, NINE, K, J] → 2×2 + 1×1 = **5**
- Scoring for Kings, roll = [K, K, K, NINE, NINE] → 3×2 + 2×1 = **8**
- Scoring for Tens, roll = [TEN, NINE, NINE, NINE, Q] → 1×2 + 3×1 = **5**

### 2.2 Minimum Threshold

A score can only be registered in a column if:
```
points >= columnMinimums[columnIndex]
```

If the score doesn't meet the minimum, the player **cannot** register in that column.

### 2.3 Special Combination: Five of a Kind

If all 5 dice show the **same face** (not NINE):
```
score = 20 points
if fromHand: score = 40 points
```

This score is registered in the corresponding figure's **next open column** (replaces the normal point calculation for that column).

Five of a kind **also counts as a fullen** (can be registered in the fullen line instead, if preferred).

### 2.4 Special Combination: Five Nines ("Pilada")

If all 5 dice show NINE:
```
score = 30 points
if fromHand: score = 60 points
```

This score can be inscribed in **any figure line's next open column** (player's choice: aces, kings, queens, jacks, or tens).

### 2.5 Special Combination: Sequences

The order/position of dice is irrelevant — only the **presence** of the required faces matters.

**Minimum Straight** — dice contain exactly the set {K, Q, J, TEN, NINE} (in any order):
```
score = 15 points
if fromHand: score = 30 points
```

**Maximum Straight** — dice contain exactly the set {A, K, Q, J, TEN} (in any order):
```
score = 30 points
if fromHand: score = 60 points
```

Example: [10, A, J, K, Q] is a valid maximum straight.

Sequences are registered in the **sequences line** (not in figure lines).

### 2.6 Special Combination: Full House ("Fullen")

A fullen is any combination of **3 of one face + 2 of another face** (any faces, including NINE).

Examples: [A,A,A,K,K], [Q,Q,NINE,NINE,NINE], [J,J,J,TEN,TEN]

Five of a kind also qualifies as a fullen.

Fullens are registered in the **fullens line**. The score registered is the **point value of the fullen itself** (see section 2.8).

### 2.7 "From Hand" Rule (`fromHand`)

A combination is "from hand" if it was achieved on **any roll where all 5 dice are thrown** — i.e., no dice were held from a previous roll. This is always true on the first roll, but it can also happen on the 2nd or 3rd roll: when a player scores on a previous roll, they pick up all 5 dice for the next roll, which then qualifies as "from hand" as well.

The key condition is: **no held dice**. It can occur on any of the 3 rolls.

When `fromHand == true`, the score of any special combination **doubles**.

This applies to:
- Five of a kind: 20 → 40
- Five nines: 30 → 60
- Min straight: 15 → 30
- Max straight: 30 → 60
- Fullen: point value doubles (see 2.8)

### 2.8 Fullen Scoring

Fullens are registered in the fullen line. Each fullen entry records its point value:
```
fullen score = 15 points (base)
if fromHand: fullen score = 30 points
```

The fullen line total is the **sum** of all registered fullens.

### 2.9 Special Line Totals

Sequences, fullens, and poker lines hold individual entries (not columns like figure lines). Their totals are calculated as:

```
sequencesTotal = sum of all registered sequence scores
fullensTotal   = sum of all registered fullen scores
pokerTotal     = sum of all registered poker scores
```

These totals are **NOT multiplied** by any factor. They are added directly to the player's final score.

### 2.10 Special Combination: Poker (4 of a Kind)

A **Poker** is when 4 dice show the **same face** (excluding NINE). The 5th die can be anything. It **only** scores if achieved **from hand** (`fromHand == true`).

```
score = 100 points   (only if fromHand)
```

**Royal Poker** — a special case: exactly **4 Aces + 1 King**:
```
score = 200 points   (only if fromHand)
```

If `fromHand == false`, a 4-of-a-kind has no special score — it is treated as a normal roll and the player may score it in a figure line column as usual.

Poker entries are registered in the **poker line** (a special line, not a figure line). The poker line does NOT count toward the game-end condition (it is never "closed").

### 2.11 Accumulation Mode

Accumulation is **not** a pre-declared mode. It is triggered automatically when, after scoring in a figure line, **all 5 dice show the target figure or 9**. The player may then re-roll all 5 dice and keep accumulating points for the same figure and column.

**Trigger:**
- The player scores normally in a figure line (e.g. Queens) using the quick-score button.
- If all 5 dice happen to be the scored figure or 9, accumulation mode activates.
- The running total is set to the points just scored.

**Mechanics:**
1. **Continue**: If all 5 dice are figure/9, the player may choose to **continue accumulating** — re-roll all 5 dice and add the new figure points to the running total.
2. **Hold + Re-roll**: If after a re-roll the dice do NOT all match, the player may hold some dice and re-roll the rest (normal hold behaviour). The figure points of the new roll are added to the running total.
3. **Finalize**: At any point, the player may finalize — the accumulated total is registered in the target column if it meets the column minimum. If it does not meet the minimum, nothing is registered (turn wasted).
4. **Pass = Finalize**: Pressing "Pass" during accumulation auto-finalizes.

**Timing:**
- If triggered on roll 1 → can continue on rolls 2 and 3.
- If triggered on roll 2 → can continue on roll 3.
- If on the last roll (roll 3), accumulation does NOT trigger — normal scoring only.

**Constraints:**
- Once in accumulation, the player **cannot score in other lines** — all rolls go to the single target column.
- Special combinations (sequences, fullens, five-of-a-kind, poker) detected during an accumulation turn are **ignored**.
- `fromHand` does NOT apply to accumulation.

**Example:**
Targeting Queens, column 0 (min ≥ 7):
- Roll 1: [Q, Q, Q, Q, 9] → 4×2 + 1×1 = 9, all match → enters accumulation
- Continue (re-roll all 5): [Q, 10, K, K, 9] → 1×2 + 1×1 = 3 → running total = 12
- Hold Q and 9, re-roll 3: [Q, Q, Q, 9, 9] → 3×2 + 2×1 = 8 → running total = 20
- Finalize → 20 ≥ 7 → registered in Queens column 0

**Source:** Variante 2 — https://vamosokintressa.blogspot.com/2008/08/regras-tradicionais-portuguesas-do.html

---

## 3. Figure Line Closing & Final Scoring

### 3.1 Closing a Figure Line

A figure line is **closed** when any one player fills all 5 columns.

When a line is closed:
- **No player** may score in that line anymore
- All players keep whatever scores they had registered

### 3.2 Figure Line Final Score Calculation

When a figure line is closed, for each player:

```
rawTotal = sum of all filled columns for that player
lineScore = rawTotal × multiplier
```

### 3.3 Unopened Bonus (Double)

If the player who closed a figure line did so while one or more other players **never opened** that line (have 0 columns filled), then **only the closer** gets their score doubled:

```
hasUnopenedPlayers = any player has 0 columns filled in this line
if hasUnopenedPlayers:
    // Only the closer gets doubled
    closerLineScore = rawTotal × multiplier × 2
    // Other players who opened the line get normal score
    otherLineScore  = rawTotal × multiplier
else:
    // Everyone gets normal score
    lineScore = rawTotal × multiplier
// Players with 0 columns always get 0 for that line
```

### 3.4 Example

Aces line (multiplier ×6), 4 players:
- Player 1 (closed): columns = [7, 8, 9, 8, 9] → sum = 41
- Player 2 (opened): columns = [7, 8, _, _, _] → sum = 15
- Player 3 (never opened): columns = [_, _, _, _, _] → sum = 0
- Player 4 (opened): columns = [7, _, _, _, _] → sum = 7

Since Player 3 never opened → **double applies to closer only**:
- Player 1: 41 × 6 × 2 = **492** (closer, doubled)
- Player 2: 15 × 6 = **90** (opened, normal)
- Player 3: **0** (never opened)
- Player 4: 7 × 6 = **42** (opened, normal)

---

## 4. Turn Flow

### 4.1 Turn Structure

```
Turn:
  player: Player
  rolls: [Roll_0, Roll_1, Roll_2]   // exactly 3 rolls
  rollIndex: 0..2                    // current roll
  scoredThisTurn: Set<FigureLine>    // lines already scored in this turn
  fromHand: bool                     // true if all 5 dice were thrown this roll (no held dice)
```

### 4.2 Roll Actions

On each roll, the player:

1. **Throws dice** — all 5 dice if first roll (or if all were picked up after scoring), or unheld dice if holding
2. **Sees the result**
3. **Chooses one of:**
   - **Score** — register points in an eligible line/column, then pick up all 5 dice for next roll
   - **Hold** — select dice to keep, re-roll the rest on the next roll (does NOT score)
   - **Pass** — do nothing, move to next roll (only if no valid score or strategic choice)
   - **Accumulate** — enter/continue accumulation mode for a target figure line (see §2.11)

### 4.3 Scoring During a Turn (Normal Mode)

- A player **may score once per figure line per turn** (cannot score aces twice in the same turn)
- A player **may score in different lines** across rolls within the same turn
  - Example: Roll 1 → score aces, Roll 2 → score kings, Roll 3 → score a sequence
- When a player scores, they pick up **all 5 dice** for the next roll
- When a player holds dice, they do **NOT** score — they are building toward a better roll

### 4.3b Accumulation Mode Turn

- Accumulation is triggered automatically when scoring in a figure line and all 5 dice are figure/9
- The player may continue accumulating (re-roll all 5) if all dice still match, or hold + re-roll
- Each roll's figure points are added to a running total
- The player may finalize at any point — total registered if ≥ column minimum
- Cannot score other lines, sequences, fullens, or poker during an accumulation turn
- Passing during accumulation auto-finalizes

### 4.4 Constraints

- Cannot score in a **closed line** (one that any player has completed all 5 columns)
- Cannot score in a line **already scored this turn** (tracked in `scoredThisTurn`)
- Must meet the **minimum threshold** for the target column
- Columns must be filled **in sequential order** (column 0 before column 1, etc.)

### 4.5 Lost Turn

If after all 3 rolls the player has scored **nothing** (no entries registered in any line during the entire turn), the turn is simply lost. No penalty, no forced entry.

---

## 5. Game Flow

### 5.1 Game Setup

```
1. Create 4 players (names provided by user)
2. Initialize empty ScoreCard for each player
3. Determine turn order (e.g., player 1 → 2 → 3 → 4, rotating)
4. All lines start as OPEN
```

### 5.2 Round

A round = all 4 players take one turn each.

### 5.3 Game End Condition

The game ends when **only 1 figure line remains open** (i.e., 4 out of 5 figure lines are closed).

Note: Sequence and fullen lines do **not** count for the end condition — they are never "closed".

### 5.4 Final Score Calculation

```
For each player:
  figureScore = sum of lineScore for each of the 5 figure lines (see §3)
  sequenceScore = sum of all registered sequences
  fullenScore = sum of all registered fullens
  pokerScore = sum of all registered pokers
  
  totalScore = figureScore + sequenceScore + fullenScore + pokerScore
```

### 5.5 Winner

The player with the **highest totalScore** wins.

Tiebreaker: if two or more players have the same totalScore, they share the victory (ties are extremely rare given the scoring magnitudes).

---

## 6. Score Table Layout

Each player has a score card with this structure:

```
FIGURE LINES (5 rows × 5 columns each):
┌─────────┬──────┬──────┬──────┬──────┬──────┬──────┬────────┐
│ Line    │ Col1 │ Col2 │ Col3 │ Col4 │ Col5 │ ×Mul │ Total  │
│         │ (≥7) │ (≥6) │ (≥6) │ (≥8) │ (≥8) │      │        │
├─────────┼──────┼──────┼──────┼──────┼──────┼──────┼────────┤
│ Aces    │      │      │      │      │      │  ×6  │        │
│ Kings   │      │      │      │      │      │  ×5  │        │
│ Queens  │      │      │      │      │      │  ×4  │        │
│ Jacks   │      │      │      │      │      │  ×3  │        │
│ Tens    │      │      │      │      │      │  ×2  │        │
└─────────┴──────┴──────┴──────┴──────┴──────┴──────┴────────┘

SPECIAL LINES (variable entries):
┌────────────┬───────────────────────────────┬────────┐
│ Sequences  │ [entry] [entry] [entry] ...   │ Total  │
├────────────┼───────────────────────────────┼────────┤
│ Fullens    │ [entry] [entry] [entry] ...   │ Total  │
├────────────┼───────────────────────────────┼────────┤
│ Poker      │ [entry] [entry] [entry] ...   │ Total  │
└────────────┴───────────────────────────────┴────────┘

                                      GRAND TOTAL: ____
```

---

## 7. Data Model (Dart)

### 7.1 Enums

```dart
enum DieFace { ace, king, queen, jack, ten, nine }

enum FigureLine { aces, kings, queens, jacks, tens }

enum SpecialLine { sequences, fullens, poker }
```

### 7.2 Core Classes

```dart
class Die {
  DieFace face;
  bool held;
}

class Player {
  String name;
  int index;        // 0..3
  ScoreCard scoreCard;
}

class ScoreCard {
  // Figure lines: 5 lines × 5 columns (nullable = unfilled)
  Map<FigureLine, List<int?>> figureScores;
  // e.g. {aces: [7, 8, null, null, null], kings: [null, ...], ...}
  
  // Special lines: variable-length list of entries
  List<SpecialEntry> sequenceEntries;
  List<SpecialEntry> fullenEntries;
  List<SpecialEntry> pokerEntries;
}

class SpecialEntry {
  int score;
  bool fromHand;
}

class GameState {
  List<Player> players;          // exactly 4
  int currentPlayerIndex;        // 0..3
  int currentRollIndex;          // 0..2
  List<Die> dice;                // exactly 5
  Set<FigureLine> closedLines;   // lines where any player filled all 5 cols
  Set<FigureLine> scoredThisTurn; // lines scored in current turn
  bool gameOver;
  
  // Accumulation mode tracking
  bool accumulationMode;            // true if current turn is in accumulation
  FigureLine? accumulationTarget;   // target figure line
  int? accumulationColumn;          // target column index
  int accumulationRunningTotal;     // sum of points across rolls so far
}

class TurnAction {
  // One of:
  // - ScoreAction(FigureLine line, int columnIndex, int points)
  // - ScoreSequence(int points, bool fromHand)
  // - ScoreFullen(int points, bool fromHand)
  // - ScorePoker(int points)  // 100 or 200 (Royal), always fromHand
  // - HoldAction(Set<int> diceIndicesToHold)
  // - PassAction()
  // - ContinueAccumulation()  // re-roll all 5 dice, keep running total (triggered when all match)
  // - FinalizeAccumulation()  // end accumulation, register total
}
```

### 7.3 Key Constants

```dart
const multipliers = {
  FigureLine.aces: 6,
  FigureLine.kings: 5,
  FigureLine.queens: 4,
  FigureLine.jacks: 3,
  FigureLine.tens: 2,
};

const columnMinimums = [7, 6, 6, 8, 8];

const maxPlayers = 4;
const rollsPerTurn = 3;
const columnsPerLine = 5;
const closedLinesForGameEnd = 4; // game ends when 4 of 5 lines are closed
```

---

## 8. Scoring Engine API (Draft)

```dart
/// Calculate points for a set of dice targeting a specific figure line.
int calculateFigurePoints(List<DieFace> dice, FigureLine target);

/// Detect if dice form a special combination.
SpecialCombination? detectSpecialCombination(List<DieFace> dice);
// Returns: MinStraight, MaxStraight, FiveOfAKind(face), FiveNines, 
//          FullHouse(face3, face2), Poker(face), RoyalPoker, or null

/// Check if a score can be registered in a given column.
bool canScore(ScoreCard card, FigureLine line, int columnIndex, int points);

/// Get all valid scoring options for a roll.
List<ScoringOption> getValidOptions(GameState state, List<DieFace> dice, bool fromHand);

/// Register a score and return updated game state.
GameState applyScore(GameState state, TurnAction action);

/// Accumulation: add current roll's figure points to running total.
GameState applyAccumulationRoll(GameState state, List<DieFace> dice);

/// Accumulation: finalize and register the accumulated total (if valid).
GameState finalizeAccumulation(GameState state);

/// Calculate final score for a player after game ends.
int calculateFinalScore(GameState state, int playerIndex);

/// Check if the game should end.
bool isGameOver(GameState state);
```

---

## 9. Validation Test Cases (Examples)

### 9.1 Point Calculation
| Dice | Target | Expected |
|---|---|---|
| [A, A, A, 9, 9] | Aces | 8 |
| [K, K, 9, J, Q] | Kings | 5 |
| [10, 10, 10, 10, 9] | Tens | 9 |
| [9, 9, 9, 9, 9] | Any figure | 5 (or 30 as five-nines) |
| [A, A, A, A, A] | Aces | 10 (or 20 as five-of-a-kind) |

### 9.2 Special Combinations
| Dice | Expected |
|---|---|
| [K, Q, J, 10, 9] | MinStraight (15/30) |
| [A, K, Q, J, 10] | MaxStraight (30/60) |
| [9, 9, 9, 9, 9] | FiveNines (30/60) |
| [Q, Q, Q, Q, Q] | FiveOfAKind (20/40) |
| [A, A, A, K, K] | FullHouse |
| [J, J, 9, 9, 9] | FullHouse |
| [K, K, K, K, Q] | Poker (100 if fromHand, else normal roll) |
| [A, A, A, A, K] | RoyalPoker (200 if fromHand) |
| [A, A, A, A, Q] | Poker (100 if fromHand — NOT Royal, needs K as 5th) |
| [A, K, Q, 9, 9] | None (no special) |

### 9.3 Minimum Threshold
| Points | Column | Can Score? |
|---|---|---|
| 7 | 0 (Open) | Yes |
| 6 | 0 (Open) | No |
| 6 | 1 | Yes |
| 5 | 1 | No |
| 8 | 3 | Yes |
| 7 | 3 | No |
| 8 | 4 (Close) | Yes |

### 9.4 Line Closing (4 players)
| Player | Columns Filled | Line Closed By P1 | Score (×6 Aces) |
|---|---|---|---|
| P1 | [7,8,9,8,9] = 41 | Closer | 41×6×2 = 492 (doubled, closer + P3 never opened) |
| P2 | [7,8,_,_,_] = 15 | Opened | 15×6 = 90 (normal) |
| P3 | [_,_,_,_,_] = 0 | Never opened | 0 |
| P4 | [7,_,_,_,_] = 7 | Opened | 7×6 = 42 (normal) |

### 9.5 Game End
- Lines closed: aces, kings, queens, jacks (4 closed) → **Game Over**
- Lines closed: aces, kings, queens (3 closed) → Continue
- Sequences/fullens — irrelevant for game end condition

---

## 10. Future Extensions (Post-MVP)

- **Online multiplayer** — real-time or async
- **AI opponents** — single player mode
- **Configurable player count** (2–6)
- **Monetization hooks** — ads (AdMob), IAP (remove ads, themes)
