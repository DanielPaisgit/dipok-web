# Würfelpoker — Spielregeln

> Willkommen bei Würfelpoker! Viel Spaß mit diesem klassischen portugiesischen Spiel.
> Diese Seite enthält zunächst eine Kurzreferenz, gefolgt von den vollständigen Regeln.

> 📌 Am Ende dieser Seite findest du eine [**Visuelle Übersicht**](#resumo) aller Regeln.

---

## Kurzreferenz

| | |
|---|---|
| **Spieler** | 2 bis 4 |
| **Würfel** | 5 Würfel mit Seiten: A · K · Q · J · 10 · 9 |
| **Zug** | Bis zu 3 Würfe |
| **Ziel** | Höchste Gesamtpunktzahl am Spielende |
| **Spielende** | Wenn 6 von 7 Nicht-Poker-Linien geschlossen sind |

**Seiten (absteigende Hierarchie):**

| Seite | Name |
|---|---|
| A | Ass |
| K | König |
| Q | Dame |
| J | Bube |
| 10 | Zehn |
| 9 | Neun (Joker) |

<!-- FACE_LEGEND -->

Die **9 (Neun)** ist ein Joker: Sie zählt 1 Punkt für die Figur, für die der Spieler gerade spielt.

> **Hinweis:** Es gibt keine Farben (Suits) — das Spiel basiert ausschließlich auf den Würfelseiten.

---

## Vollständige Regeln

### 1. Zugstruktur

Ein Zug besteht aus **bis zu 3 Würfen**. Bei jedem Wurf kann der Spieler:

- **Würfel halten** — ausgewählte Würfel behalten und die übrigen beim nächsten Wurf neu werfen.
- **Punkte eintragen** — das Ergebnis in einer zulässigen Linie eintragen und alle 5 Würfel für den nächsten Wurf aufnehmen.
- **Passen** — zum nächsten Wurf übergehen, ohne zu werten oder zu halten.

> **Hinweis:** Zu Beginn jedes Zugs werden alle 5 Würfel geworfen — automatisch oder mit der Schaltfläche **Würfeln**, wenn *Erster Wurf manuell* aktiviert ist. Dies ist der erste Wurf.

Hat der Spieler nach allen 3 Würfen **keine Punkte eingetragen**, verliert er seinen Zug (keine Strafe).

Es ist möglich, in **verschiedenen Linien** innerhalb desselben Zugs zu werten, und auch **in derselben Linie in verschiedenen Würfen** desselben Zugs (jede Wertung geht in die nächste verfügbare Spalte).

---

### 2. Punktetabelle

Die Tabelle jedes Spielers hat **8 Linien**:

| # | Linie | Typ |
|---|---|---|
| 1 | Asse (A) | Figur |
| 2 | Könige (K) | Figur |
| 3 | Damen (Q) | Figur |
| 4 | Buben (J) | Figur |
| 5 | Zehnen (10) | Figur |
| 6 | Sequenzen | Spezial |
| 7 | Full Houses | Spezial |
| 8 | Poker | Spezial |

**Leere Tabelle vor jeder Eintragung:**

| Linie | ≥7 | ≥6 | ≥6 | ≥8 | ≥8 |
|---|:---:|:---:|:---:|:---:|:---:|
| A (×6) | | | | | |
| K (×5) | | | | | |
| Q (×4) | | | | | |
| J (×3) | | | | | |
| 10 (×2) | | | | | |
| Sequenzen | | | | | |
| Full Houses | | | | | |
| Poker | | | | | |

---

### 3. Figurenlinien (A, K, Q, J, 10)

#### Punktberechnung

Beim Werten für eine Figur:

```
Punkte = (Anzahl passender Würfel × 2) + (Anzahl der 9er × 1)
```

Beispiele (für Damen werten):

**[Q, Q, Q, 9, K]** → 3×2 + 1×1 = **7 Pkt**
<!-- DICE: Q,Q,Q,9,K -->

**[Q, 9, 9, 9, A]** → 1×2 + 3×1 = **5 Pkt**
<!-- DICE: Q,9,9,9,A -->

**[Q, Q, Q, Q, 9]** → 4×2 + 1×1 = **9 Pkt**
<!-- DICE: Q,Q,Q,Q,9 -->

#### Spalten und Mindestwerte

Jede Figurenlinie hat **5 Spalten**, die von links nach rechts gefüllt werden müssen:

| Spalte | Name | Minimum |
|---|---|---|
| 1. | Öffnen | **≥ 7** |
| 2. | — | **≥ 6** |
| 3. | — | **≥ 6** |
| 4. | — | **≥ 8** |
| 5. | Schließen | **≥ 8** |

#### Eine Linie schließen

Eine Linie ist **geschlossen**, wenn ein Spieler alle 5 Spalten füllt. Danach kann niemand mehr in dieser Linie werten.

#### Multiplikatoren

| Linie | Multiplikator |
|---|---|
| Asse (A) | × 6 |
| Könige (K) | × 5 |
| Damen (Q) | × 4 |
| Buben (J) | × 3 |
| Zehnen (10) | × 2 |

**Schließbonus:** Hat der Spieler, der die Linie schloss, dies getan, ohne dass ein anderer Spieler sie geöffnet hatte, wird der Score **aller Spieler, die sie geöffnet haben** (einschließlich des Schließers), **verdoppelt**. Diese Regel gilt auch für Sequenzen und Full Houses (nicht für Poker).

Beispiel (Asse, ×6):

| Spieler | Spalten | Berechnung | Gesamt |
|---|---|---|---|
| Ana (geschlossen) | 7 · 8 · 9 · 8 · 9 = 41 | 41 × 6 × 2 | **492** |
| Bruno (geöffnet) | 7 · 8 = 15 | 15 × 6 × 2 | **180** |
| Carla (nie geöffnet) | — | 0 | **0** |

---

### 4. Regel «Aus der Hand»

Eine Kombination ist **«aus der Hand»**, wenn sie in einem Wurf erzielt wird, bei dem **alle 5 Würfel geworfen wurden** (keine Würfel gehalten). In diesem Fall wird der Score der Spezialkombinationen **verdoppelt**.

---

### 5. Spezialkombinationen

#### 5.1 Sequenzen

| Sequenz | Seiten | Punkte | Aus der Hand |
|---|---|---|---|
| Minimal | K · Q · J · 10 · 9 | 15 | **30** |
| Maximal | A · K · Q · J · 10 | 30 | **60** |

Minimal-Sequenz:
<!-- DICE: K,Q,J,10,9 -->

Maximal-Sequenz:
<!-- DICE: A,K,Q,J,10 -->

#### 5.2 Full House

Jede Kombination aus **3 gleichen + 2 gleichen** (einschließlich 9er).

Beispiel: **[A, A, A, K, K]** (3 Asse + 2 Könige)
<!-- DICE: A,A,A,K,K -->

| Punkte | Aus der Hand |
|---|---|
| 15 | **30** |

#### 5.3 Fünf Gleiche

Beispiel: **[K, K, K, K, K]**
<!-- DICE: K,K,K,K,K -->

| Punkte | Aus der Hand |
|---|---|
| 20 | **40** |

Zählt auch als Full House.

#### 5.4 Fünf Neuner

Beispiel: **[9, 9, 9, 9, 9]**
<!-- DICE: 9,9,9,9,9 -->

| Punkte | Aus der Hand |
|---|---|
| 30 | **60** |

Kann in **jede beliebige Figurenlinie** eingetragen werden (Spielerwahl).

#### 5.5 Poker (4 Gleiche — nur aus der Hand)

| Typ | Bedingung | Punkte |
|---|---|---|
| Poker | 4 Gleiche aus der Hand | **100** |
| Royal Poker | 4 Asse + 1 König aus der Hand | **200** |

Poker — **[K, K, K, K, Q]**:
<!-- DICE: K,K,K,K,Q -->

Royal Poker — **[A, A, A, A, K]**:
<!-- DICE: A,A,A,A,K -->

---

### 6. Akkumulationsmodus

Wird automatisch aktiviert, wenn beim Werten in einer Figurenlinie **alle 5 Würfel** die Zielfigur oder 9er zeigen.

Beispiel (für Damen — alle zählen): **[Q, Q, Q, 9, 9]**
<!-- DICE: Q,Q,Q,9,9 -->

Der Spieler kann weiterwürfeln und Punkte anhäufen. Beim Abschließen wird der Gesamtwert in die Spalte eingetragen (sofern das Minimum erreicht ist).

---

### 7. Spielende und Sieger

Das Spiel endet, wenn **6 von 7 Nicht-Poker-Linien** geschlossen sind. Zählen für das Spielende: die 5 Figurenlinien + Sequenzen + Full Houses. **Poker zählt nicht** für das Spielende.

```
Gesamt = (Summe der 5 Linien × Multiplikatoren) + Sequenzen + Full Houses + Poker
```

Der Spieler mit der **höchsten Gesamtpunktzahl** gewinnt.

---

### 8. Visuelle Übersicht

```
┌───────────────────────────────────────────────────────────┐
│  ZUG: 3 Würfe                                             │
│                                                           │
│  Wurf → Würfel halten?                                    │
│          └─ Ja → nächster Wurf (behält Würfel)            │
│          └─ Nein → In einer gültigen Zeile werten         │
│                   (sammelt alle, zählt als aus der Hand)  │
│                 → Passen (keine Punkte, nichts halten)    │
│                                                           │
│  Nach 3 Würfen → verliert den Zug                         │
└───────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  FIGURZEILEN: 5 Spalten, von links nach rechts                  │
│  Min: ≥7 · ≥6 · ≥6 · ≥8 · ≥8                                    │
│  Endsumme × Multiplikator (×2 wenn ohne Eröffnung geschlossen)  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  SPEZIAL (addieren, nicht multiplizieren)           │
│  Min-Straße:   15 / aus der Hand: 30                │
│  Max-Straße:   30 / aus der Hand: 60                │
│  Full House:   15 / aus der Hand: 30                │
│  Fünf Gleiche: 20 / aus der Hand: 40                │
│  Fünf Neunen:  30 / aus der Hand: 60                │
│  Poker:       100 / Royal:  200 (nur aus der Hand)  │
└─────────────────────────────────────────────────────┘
```

---

*Würfelpoker v1.0 — Basierend auf dem traditionellen portugiesischen Würfelpoker.*

