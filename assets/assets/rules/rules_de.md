# W�rfelpoker — Spielregeln

> W�rfelpoker ist die digitale Version des klassischen portugiesischen Spiels **Würfelpoker**.
> Diese Seite enthält zunächst eine Kurzreferenz, gefolgt von den vollständigen Regeln.

---

## Kurzreferenz

| | |
|---|---|
| **Spieler** | 2 bis 4 |
| **Würfel** | 5 Würfel mit Seiten: A · K · Q · J · 10 · 9 |
| **Zug** | Bis zu 3 Würfe |
| **Ziel** | Höchste Gesamtpunktzahl am Spielende |
| **Spielende** | Wenn nur noch 1 Figurenlinie offen ist |

**Seiten (absteigende Hierarchie):**

| Seite | Name |
|---|---|
| A | Ass |
| K | König |
| Q | Dame |
| J | Bube |
| 10 | Zehn |
| 9 | Neun (Joker) |

Die **9 (Neun)** ist ein Joker: Sie zählt 1 Punkt für die Figur, für die der Spieler gerade spielt.

---

## Vollständige Regeln

### 1. Zugstruktur

Ein Zug besteht aus **bis zu 3 Würfen**. Bei jedem Wurf kann der Spieler:

- **Würfel halten** — ausgewählte Würfel behalten und die übrigen beim nächsten Wurf neu werfen.
- **Punkte eintragen** — das Ergebnis in einer zulässigen Linie eintragen und alle 5 Würfel für den nächsten Wurf aufnehmen.
- **Passen** — zum nächsten Wurf übergehen, ohne zu werten oder zu halten.

Hat der Spieler nach allen 3 Würfen **keine Punkte eingetragen**, verliert er seinen Zug (keine Strafe).

Es ist möglich, in **verschiedenen Linien** innerhalb desselben Zugs zu werten, aber **man kann nicht zweimal in derselben Linie in einem Zug werten**.

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

---

### 3. Figurenlinien (A, K, Q, J, 10)

#### Punktberechnung

Beim Werten für eine Figur:

```
Punkte = (Anzahl passender Würfel × 2) + (Anzahl der 9er × 1)
```

Beispiele (für Damen werten):
- [Q, Q, Q, 9, K] → 3×2 + 1×1 = **7 Pkt**
- [Q, 9, 9, 9, A] → 1×2 + 3×1 = **5 Pkt**
- [Q, Q, Q, Q, 9] → 4×2 + 1×1 = **9 Pkt**

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

**Schließbonus:** Hat der Spieler, der die Linie schloss, dies getan, ohne dass ein anderer Spieler sie geöffnet hatte, wird sein Linien-Score **verdoppelt**.

Beispiel (Asse, ×6):

| Spieler | Spalten | Berechnung | Gesamt |
|---|---|---|---|
| Ana (geschlossen) | 7 · 8 · 9 · 8 · 9 = 41 | 41 × 6 × 2 | **492** |
| Bruno (geöffnet) | 7 · 8 = 15 | 15 × 6 | **90** |
| Carla (nie geöffnet) | — | 0 | **0** |

---

### 4. Spezialkombinationen

#### 4.1 Sequenzen

| Sequenz | Seiten | Punkte | Aus der Hand |
|---|---|---|---|
| Minimal | K · Q · J · 10 · 9 | 15 | **30** |
| Maximal | A · K · Q · J · 10 | 30 | **60** |

#### 4.2 Full House

Jede Kombination aus **3 gleichen + 2 gleichen** (einschließlich 9er).

| Punkte | Aus der Hand |
|---|---|
| 15 | **30** |

#### 4.3 Fünf Gleiche

| Punkte | Aus der Hand |
|---|---|
| 20 | **40** |

Zählt auch als Full House.

#### 4.4 Fünf Neuner («Pilada»)

| Punkte | Aus der Hand |
|---|---|
| 30 | **60** |

Kann in **jede beliebige Figurenlinie** eingetragen werden (Spielerwahl).

#### 4.5 Poker (4 Gleiche — nur aus der Hand)

| Typ | Bedingung | Punkte |
|---|---|---|
| Poker | 4 Gleiche aus der Hand | **100** |
| Royal Poker | 4 Asse + 1 König aus der Hand | **200** |

---

### 5. Regel «Aus der Hand»

Eine Kombination ist **«aus der Hand»**, wenn sie in einem Wurf erzielt wird, bei dem **alle 5 Würfel geworfen wurden** (keine Würfel gehalten). In diesem Fall wird der Score der Spezialkombinationen **verdoppelt**.

---

### 6. Akkumulationsmodus

Wird automatisch aktiviert, wenn beim Werten in einer Figurenlinie **alle 5 Würfel** die Zielfigur oder 9er zeigen.

Der Spieler kann weiterwürfeln und Punkte anhäufen. Beim Abschließen wird der Gesamtwert in die Spalte eingetragen (sofern das Minimum erreicht ist).

---

### 7. Spielende und Sieger

Das Spiel endet, wenn **nur noch 1 Figurenlinie** offen ist.

```
Gesamt = (Summe der 5 Linien × Multiplikatoren) + Sequenzen + Full Houses + Poker
```

Der Spieler mit der **höchsten Gesamtpunktzahl** gewinnt.

---

*W�rfelpoker v1.0 — Basierend auf dem traditionellen portugiesischen Würfelpoker.*

