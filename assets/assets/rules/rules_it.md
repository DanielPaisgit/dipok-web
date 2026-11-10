# Poker di Dadi — Regole del Gioco

> Benvenuto a Poker di Dadi! Divertiti a giocare a questo classico gioco portoghese.
> Questa pagina contiene prima una guida rapida, poi le regole complete.

> 📌 Alla fine di questa pagina troverai un [**Riepilogo Visivo**](#resumo) di tutte le regole.

---

## Guida Rapida

| | |
|---|---|
| **Giocatori** | 2 a 4 |
| **Dadi** | 5 dadi con facce: A · K · Q · J · 10 · 9 |
| **Turno** | Fino a 3 lanci |
| **Obiettivo** | Punteggio totale più alto alla fine della partita |
| **Fine partita** | Quando 6 delle 7 righe non-Poker sono chiuse |

**Facce (gerarchia decrescente):**

| Faccia | Nome |
|---|---|
| A | Asso |
| K | Re |
| Q | Donna |
| J | Fante |
| 10 | Dieci |
| 9 | Nove (jolly) |

<!-- FACE_LEGEND -->

Il **9 (Nove)** è un jolly: vale 1 punto per qualsiasi figura per cui il giocatore sta giocando.

> **Nota:** Non ci sono semi — il gioco si basa esclusivamente sulle facce dei dadi.

---

## Regole Complete

### 1. Struttura del Turno

Un turno comprende **fino a 3 lanci**. A ogni lancio il giocatore può:

- **Tenere dadi** — selezionare i dadi da conservare e rilanciare gli altri nel lancio successivo.
- **Segnare punti** — registrare il risultato in una riga ammissibile e raccogliere i 5 dadi per il lancio successivo.
- **Passare** — avanzare al lancio successivo senza segnare né tenere.

> **Nota:** All’inizio di ogni turno, i 5 dadi vengono lanciati automaticamente — questo è il primo lancio.

Se al termine dei 3 lanci il giocatore **non ha segnato nulla**, perde il turno (senza penalità).

È possibile segnare in **righe diverse** durante lo stesso turno, e anche **nella stessa riga su lanci diversi** dello stesso turno (ogni annotazione va nella colonna disponibile successiva).

---

### 2. Tabella dei Punteggi

La tabella di ogni giocatore ha **8 righe**:

| # | Riga | Tipo |
|---|---|---|
| 1 | Assi (A) | Figura |
| 2 | Re (K) | Figura |
| 3 | Regine (Q) | Figura |
| 4 | Fanti (J) | Figura |
| 5 | Dieci (10) | Figura |
| 6 | Sequenze | Speciale |
| 7 | Full House | Speciale |
| 8 | Poker | Speciale |

**Aspetto della tabella prima di qualsiasi registrazione:**

| Riga | ≥7 | ≥6 | ≥6 | ≥8 | ≥8 |
|---|:---:|:---:|:---:|:---:|:---:|
| A (×6) | | | | | |
| K (×5) | | | | | |
| Q (×4) | | | | | |
| J (×3) | | | | | |
| 10 (×2) | | | | | |
| Sequenze | | | | | |
| Full House | | | | | |
| Poker | | | | | |

---

### 3. Righe di Figura (A, K, Q, J, 10)

#### Calcolo dei punti

Per segnare in una figura:

```
punti = (numero di dadi con la figura × 2) + (numero di 9 × 1)
```

Esempi (segnando per le Regine):

**[Q, Q, Q, 9, K]** → 3×2 + 1×1 = **7 pt**
<!-- DICE: Q,Q,Q,9,K -->

**[Q, 9, 9, 9, A]** → 1×2 + 3×1 = **5 pt**
<!-- DICE: Q,9,9,9,A -->

**[Q, Q, Q, Q, 9]** → 4×2 + 1×1 = **9 pt**
<!-- DICE: Q,Q,Q,Q,9 -->

#### Colonne e minimi

Ogni riga di figura ha **5 colonne** da riempire da sinistra a destra:

| Colonna | Nome | Minimo |
|---|---|---|
| 1a | Aprire | **≥ 7** |
| 2a | — | **≥ 6** |
| 3a | — | **≥ 6** |
| 4a | — | **≥ 8** |
| 5a | Chiudere | **≥ 8** |

#### Chiudere una riga

Una riga è **chiusa** quando un giocatore riempie tutte e 5 le colonne. Nessuno può più segnare in quella riga.

#### Moltiplicatori

| Riga | Moltiplicatore |
|---|---|
| Assi (A) | × 6 |
| Re (K) | × 5 |
| Regine (Q) | × 4 |
| Fanti (J) | × 3 |
| Dieci (10) | × 2 |

**Bonus di chiusura:** Se il giocatore che ha chiuso la riga lo ha fatto senza che nessun altro giocatore l'avesse aperta, il punteggio di **tutti i giocatori che l'hanno aperta** (incluso chi ha chiuso) viene **raddoppiato**. Questa regola si applica anche alle righe Sequenze e Full House (non al Poker).

Esempio (Assi, ×6):

| Giocatore | Colonne | Calcolo | Totale |
|---|---|---|---|
| Ana (ha chiuso) | 7 · 8 · 9 · 8 · 9 = 41 | 41 × 6 × 2 | **492** |
| Bruno (ha aperto) | 7 · 8 = 15 | 15 × 6 × 2 | **180** |
| Carla (non ha aperto) | — | 0 | **0** |

---

### 4. Regola «Di Mano»

Una combinazione è **«di mano»** quando viene ottenuta in un lancio in cui **tutti e 5 i dadi vengono lanciati** (nessun dado trattenuto). In queste condizioni, il punteggio delle combinazioni speciali viene **raddoppiato**.

---

### 5. Combinazioni Speciali

#### 5.1 Sequenze

| Sequenza | Facce | Punti | Di mano |
|---|---|---|---|
| Minima | K · Q · J · 10 · 9 | 15 | **30** |
| Massima | A · K · Q · J · 10 | 30 | **60** |

Sequenza minima:
<!-- DICE: K,Q,J,10,9 -->

Sequenza massima:
<!-- DICE: A,K,Q,J,10 -->

#### 5.2 Full House

Qualsiasi combinazione di **3 di una faccia + 2 di un'altra** (inclusi i 9).

Esempio: **[A, A, A, K, K]** (3 Assi + 2 Re)
<!-- DICE: A,A,A,K,K -->

| Punti | Di mano |
|---|---|
| 15 | **30** |

#### 5.3 Cinque Uguali

Esempio: **[K, K, K, K, K]**
<!-- DICE: K,K,K,K,K -->

| Punti | Di mano |
|---|---|
| 20 | **40** |

Conta anche come Full House.

#### 5.4 Cinque 9

Esempio: **[9, 9, 9, 9, 9]**
<!-- DICE: 9,9,9,9,9 -->

| Punti | Di mano |
|---|---|
| 30 | **60** |

Può essere registrato in **qualsiasi riga di figura** (a scelta del giocatore).

#### 5.5 Poker (4 uguali — solo di mano)

| Tipo | Condizione | Punti |
|---|---|---|
| Poker | 4 uguali di mano | **100** |
| Royal Poker | 4 Assi + 1 Re di mano | **200** |

Poker — **[K, K, K, K, Q]**:
<!-- DICE: K,K,K,K,Q -->

Royal Poker — **[A, A, A, A, K]**:
<!-- DICE: A,A,A,A,K -->

---

### 6. Modalità Accumulazione

Si attiva automaticamente quando, segnando in una riga di figura, **tutti e 5 i dadi** mostrano la figura obiettivo o 9.

Esempio (giocando per le Regine — contano tutti): **[Q, Q, Q, 9, 9]**
<!-- DICE: Q,Q,Q,9,9 -->

Il giocatore può continuare a lanciare e accumulare punti. Il totale accumulato viene registrato nella colonna al momento della finalizzazione (se raggiunge il minimo).

---

### 7. Fine Partita e Vincitore

La partita termina quando **6 delle 7 righe non-Poker** sono chiuse. Contano per la fine: le 5 righe di figura + Sequenze + Full House. Il **Poker non conta** per la fine della partita.

```
Totale = (somma delle 5 righe × moltiplicatori) + Sequenze + Full House + Poker
```

Vince il giocatore con il **punteggio totale più alto**.

---

### 8. Riepilogo Visivo

```
┌────────────────────────────────────────────────────────────┐
│  TURNO: 3 lanci                                            │
│                                                            │
│  Lancio → Tenere i dadi?                                   │
│            └─ Sì → prossimo lancio (tiene i dadi)          │
│            └─ No → Segnare in una riga valida              │
│                     (raccoglie tutti, conta come di mano)  │
│                   → Passare (senza punti, senza tenere)    │
│                                                            │
│  Dopo 3 lanci → perde il turno                             │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│  RIGHE DI FIGURA: 5 colonne, da sinistra a destra              │
│  Min: ≥7 · ≥6 · ≥6 · ≥8 · ≥8                                   │
│  Totale finale × moltiplicatore (×2 se chiuso senza apertura)  │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│  SPECIALI (si sommano, non moltiplicano)       │
│  Scala min.:   15 / di mano: 30                │
│  Scala max.:   30 / di mano: 60                │
│  Full House:   15 / di mano: 30                │
│  Cinque uguali: 20 / di mano: 40               │
│  Cinque 9:     30 / di mano: 60                │
│  Poker:       100 / Reale: 200 (solo di mano)  │
└────────────────────────────────────────────────┘
```

---

*Poker di Dadi v1.0 — Basato sul tradizionale Poker con i Dadi portoghese.*

