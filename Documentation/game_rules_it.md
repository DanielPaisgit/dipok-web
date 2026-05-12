# Poker di Dadi — Regole del Gioco

> Poker di Dadi è la versione digitale del classico gioco portoghese di **Poker con i Dadi**.
> Questa pagina contiene prima una guida rapida, poi le regole complete.

---

## Guida Rapida

| | |
|---|---|
| **Giocatori** | 2 a 4 |
| **Dadi** | 5 dadi con facce: A · K · Q · J · 10 · 9 |
| **Turno** | Fino a 3 lanci |
| **Obiettivo** | Punteggio totale più alto alla fine della partita |
| **Fine partita** | Quando rimane solo 1 riga di figura da chiudere |

**Facce (gerarchia decrescente):**

| EN | IT | |
|---|---|---|
| A (Ace) | A (Asso) | |
| K (King) | R (Re) | |
| Q (Queen) | D (Donna) | |
| J (Jack) | F (Fante) | |
| 10 (Ten) | X (Dieci) | |
| 9 (Nine) | 9 (Nove) | jolly |

Il **9 (Nove)** è un jolly: vale 1 punto per qualsiasi figura per cui il giocatore sta giocando.

---

## Regole Complete

### 1. Struttura del Turno

Un turno comprende **fino a 3 lanci**. A ogni lancio il giocatore può:

- **Tenere dadi** — selezionare i dadi da conservare e rilanciare gli altri nel lancio successivo.
- **Segnare punti** — registrare il risultato in una riga ammissibile e raccogliere i 5 dadi per il lancio successivo.
- **Passare** — avanzare al lancio successivo senza segnare né tenere.

Se al termine dei 3 lanci il giocatore **non ha segnato nulla**, perde il turno (senza penalità).

È possibile segnare in **righe diverse** durante lo stesso turno, ma **non si può segnare due volte nella stessa riga nello stesso turno**.

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

---

### 3. Righe di Figura (A, K, Q, J, 10)

#### Calcolo dei punti

Per segnare in una figura:

```
punti = (numero di dadi con la figura × 2) + (numero di 9 × 1)
```

Esempi (segnando per le Regine):
- [Q, Q, Q, 9, K] → 3×2 + 1×1 = **7 pt**
- [Q, 9, 9, 9, A] → 1×2 + 3×1 = **5 pt**
- [Q, Q, Q, Q, 9] → 4×2 + 1×1 = **9 pt**

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

**Bonus di chiusura:** Se il giocatore che ha chiuso la riga lo ha fatto senza che nessun altro giocatore l'avesse aperta, il suo punteggio per quella riga viene **raddoppiato**.

Esempio (Assi, ×6):

| Giocatore | Colonne | Calcolo | Totale |
|---|---|---|---|
| Ana (ha chiuso) | 7 · 8 · 9 · 8 · 9 = 41 | 41 × 6 × 2 | **492** |
| Bruno (ha aperto) | 7 · 8 = 15 | 15 × 6 | **90** |
| Carla (non ha aperto) | — | 0 | **0** |

---

### 4. Combinazioni Speciali

#### 4.1 Sequenze

| Sequenza | Facce | Punti | Di mano |
|---|---|---|---|
| Minima | K · Q · J · 10 · 9 | 15 | **30** |
| Massima | A · K · Q · J · 10 | 30 | **60** |

#### 4.2 Full House

Qualsiasi combinazione di **3 di una faccia + 2 di un'altra** (inclusi i 9).

| Punti | Di mano |
|---|---|
| 15 | **30** |

#### 4.3 Cinque Uguali

| Punti | Di mano |
|---|---|
| 20 | **40** |

Conta anche come Full House.

#### 4.4 Cinque 9

| Punti | Di mano |
|---|---|
| 30 | **60** |

Può essere registrato in **qualsiasi riga di figura** (a scelta del giocatore).

#### 4.5 Poker (4 uguali — solo di mano)

| Tipo | Condizione | Punti |
|---|---|---|
| Poker | 4 uguali di mano | **100** |
| Royal Poker | 4 Assi + 1 Re di mano | **200** |

---

### 5. Regola «Di Mano»

Una combinazione è **«di mano»** quando viene ottenuta in un lancio in cui **tutti e 5 i dadi vengono lanciati** (nessun dado trattenuto). In queste condizioni, il punteggio delle combinazioni speciali viene **raddoppiato**.

---

### 6. Modalità Accumulazione

Si attiva automaticamente quando, segnando in una riga di figura, **tutti e 5 i dadi** mostrano la figura obiettivo o 9.

Il giocatore può continuare a lanciare e accumulare punti. Il totale accumulato viene registrato nella colonna al momento della finalizzazione (se raggiunge il minimo).

---

### 7. Fine Partita e Vincitore

La partita termina quando **rimane solo 1 riga di figura** da chiudere.

```
Totale = (somma delle 5 righe × moltiplicatori) + Sequenze + Full House + Poker
```

Vince il giocatore con il **punteggio totale più alto**.

---

*Poker di Dadi v1.0 — Basato sul tradizionale Poker con i Dadi portoghese.*

