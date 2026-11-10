# Póker de Dados — Reglas del Juego

> ¡Bienvenido a Póker de Dados! Disfruta jugando este clásico juego portugués.
> Esta página contiene primero una referencia rápida y después las reglas completas.

> 📌 Al final de esta página encontrarás un [**Resumen Visual**](#resumo) de todas las reglas.

---

## Referencia Rápida

| | |
|---|---|
| **Jugadores** | 2 a 4 |
| **Dados** | 5 dados con caras: A · K · Q · J · 10 · 9 |
| **Turno** | Hasta 3 lanzamientos |
| **Objetivo** | Mayor puntuación total cuando el juego termina |
| **Fin del juego** | Cuando 6 de las 7 filas no-póker están cerradas |

**Caras (jerarquía descendente):**

| Cara | Nombre |
|---|---|
| A | As |
| K | Rey |
| Q | Dama |
| J | Valet |
| 10 | Diez |
| 9 | Nueve (comodín) |

<!-- FACE_LEGEND -->

El **9** es un comodín: cuenta 1 punto para cualquier figura en la que el jugador esté jugando.

> **Nota:** No hay palos — el juego se basa únicamente en las caras de los dados.

---

## Reglas Completas

### 1. Estructura del Turno

Un turno consiste en **hasta 3 lanzamientos**. En cada lanzamiento, el jugador puede:

- **Guardar dados** — seleccionar dados para conservar y relanzar los demás en el siguiente lanzamiento.
- **Anotar puntos** — registrar el resultado en una fila elegible y recoger los 5 dados para el siguiente lanzamiento.
- **Pasar** — avanzar al siguiente lanzamiento sin anotar ni guardar.

> **Nota:** Al inicio de cada turno, los 5 dados se lanzan automáticamente — ese es el primer lanzamiento.

Si al final de los 3 lanzamientos el jugador **no ha anotado nada**, pierde el turno (sin penalización).

Se puede anotar en **filas diferentes** a lo largo del mismo turno, e incluso **en la misma fila en lanzamientos diferentes** dentro del mismo turno (cada anotación va a la siguiente columna disponible).

---

### 2. Tabla de Puntuación

La tabla de cada jugador tiene **8 filas**:

| # | Fila | Tipo |
|---|---|---|
| 1 | Ases (A) | Figura |
| 2 | Reyes (K) | Figura |
| 3 | Damas (Q) | Figura |
| 4 | Valets (J) | Figura |
| 5 | Diez (10) | Figura |
| 6 | Escaleras | Especial |
| 7 | Full House | Especial |
| 8 | Póker | Especial |

**Aspecto de la tabla antes de cualquier entrada:**

| Fila | ≥7 | ≥6 | ≥6 | ≥8 | ≥8 |
|---|:---:|:---:|:---:|:---:|:---:|
| A (×6) | | | | | |
| K (×5) | | | | | |
| Q (×4) | | | | | |
| J (×3) | | | | | |
| 10 (×2) | | | | | |
| Escaleras | | | | | |
| Full House | | | | | |
| Póker | | | | | |

---

### 3. Filas de Figura (A, K, Q, J, 10)

#### Cálculo de puntos

Al anotar para una figura:

```
puntos = (nº de dados con la figura × 2) + (nº de 9s × 1)
```

Ejemplos (anotando para Damas):

**[Q, Q, Q, 9, K]** → 3×2 + 1×1 = **7 pts**
<!-- DICE: Q,Q,Q,9,K -->

**[Q, 9, 9, 9, A]** → 1×2 + 3×1 = **5 pts**
<!-- DICE: Q,9,9,9,A -->

**[Q, Q, Q, Q, 9]** → 4×2 + 1×1 = **9 pts**
<!-- DICE: Q,Q,Q,Q,9 -->

#### Columnas y mínimos

Cada fila de figura tiene **5 columnas** que deben rellenarse de izquierda a derecha:

| Columna | Nombre | Mínimo |
|---|---|---|
| 1ª | Abrir | **≥ 7** |
| 2ª | — | **≥ 6** |
| 3ª | — | **≥ 6** |
| 4ª | — | **≥ 8** |
| 5ª | Cerrar | **≥ 8** |

#### Cerrar una fila

Una fila queda **cerrada** cuando un jugador rellena las 5 columnas. Nadie más puede anotar en esa fila.

#### Multiplicadores

| Fila | Multiplicador |
|---|---|
| Ases (A) | × 6 |
| Reyes (K) | × 5 |
| Damas (Q) | × 4 |
| Valets (J) | × 3 |
| Diez (10) | × 2 |

**Bonificación de cierre:** Si el cerrador cierra una fila sin que ningún jugador la haya abierto, la puntuación de **todos los jugadores que la abrieron** (incluido el cerrador) se **dobla**. Esta regla también se aplica a las filas de Escaleras y Full House (no al Póker).

Ejemplo (Ases, ×6):

| Jugador | Columnas | Cálculo | Total |
|---|---|---|---|
| Ana (cerró) | 7 · 8 · 9 · 8 · 9 = 41 | 41 × 6 × 2 | **492** |
| Bruno (abrió) | 7 · 8 = 15 | 15 × 6 × 2 | **180** |
| Carla (no abrió) | — | 0 | **0** |

---

### 4. Regla "De Mano"

Una combinación es **"de mano"** cuando se obtiene en un lanzamiento en el que **los 5 dados se lanzan sin ninguno guardado**. En esas condiciones, la puntuación de las combinaciones especiales se **dobla**.

---

### 5. Combinaciones Especiales

#### 5.1 Escaleras

| Escalera | Caras | Puntos | De mano |
|---|---|---|---|
| Mínima | K · Q · J · 10 · 9 | 15 | **30** |
| Máxima | A · K · Q · J · 10 | 30 | **60** |

Escalera mínima:
<!-- DICE: K,Q,J,10,9 -->

Escalera máxima:
<!-- DICE: A,K,Q,J,10 -->

Se registran en la fila de **Escaleras**.

#### 5.2 Full House

Cualquier combinación de **3 de una cara + 2 de otra** (incluyendo 9s).

Ejemplo: **[A, A, A, K, K]** (3 Ases + 2 Reyes)
<!-- DICE: A,A,A,K,K -->

| Puntos | De mano |
|---|---|
| 15 | **30** |

#### 5.3 Cinco Iguales

Cinco dados con la misma cara (excluyendo 9s).

Ejemplo: **[K, K, K, K, K]**
<!-- DICE: K,K,K,K,K -->

| Puntos | De mano |
|---|---|
| 20 | **40** |

También cuenta como Full House.

#### 5.4 Cinco Nueves

Ejemplo: **[9, 9, 9, 9, 9]**
<!-- DICE: 9,9,9,9,9 -->

| Puntos | De mano |
|---|---|
| 30 | **60** |

Puede registrarse en **cualquier fila de figura** (a elección del jugador).

#### 5.5 Póker (4 iguales — solo de mano)

| Tipo | Condición | Puntos |
|---|---|---|
| Póker | 4 iguales de mano | **100** |
| Póker Real | 4 Ases + 1 Rey de mano | **200** |

Póker — **[K, K, K, K, Q]**:
<!-- DICE: K,K,K,K,Q -->

Póker Real — **[A, A, A, A, K]**:
<!-- DICE: A,A,A,A,K -->

---

### 6. Modo Acumulación

Se activa automáticamente cuando, al anotar en una fila de figura, **los 5 dados** muestran la figura objetivo o 9s.

Ejemplo (jugando para Damas — todos cuentan): **[Q, Q, Q, 9, 9]**
<!-- DICE: Q,Q,Q,9,9 -->

El jugador puede continuar relanzando y acumulando puntos. El total acumulado se registra en la columna al finalizar (si alcanza el mínimo).

---

### 7. Fin del Juego y Ganador

El juego termina cuando **6 de las 7 filas no-póker** están cerradas. Cuentan para el fin: las 5 filas de figura + Escaleras + Full House. El **Póker no cuenta** para el fin del juego.

```
Total = (suma de las 5 filas × multiplicadores) + Escaleras + Full House + Póker
```

Gana el jugador con la **puntuación total más alta**.

---

### 8. Resumen Visual

```
┌────────────────────────────────────────────────────────────────┐
│  TURNO: 3 lanzamientos                                         │
│                                                                │
│  Lanzamiento → ¿Guardar dados?                                 │
│                └─ Sí → siguiente lanzamiento (mantiene dados)  │
│                └─ No → Anotar en una fila elegible             │
│                          (recoge todos, cuenta como de mano)   │
│                        → Pasar (sin puntos, sin guardar)       │
│                                                                │
│  Tras 3 lanzamientos → pierde el turno                         │
└────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────┐
│  FILAS DE FIGURA: 5 columnas, de izquierda a derecha      │
│  Mín: ≥7 · ≥6 · ≥6 · ≥8 · ≥8                              │
│  Total final × multiplicador (×2 si cierra sin apertura)  │
└───────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│  ESPECIALES (suman, no multiplican)              │
│  Escalera mín.: 15 / de mano: 30                 │
│  Escalera máx.: 30 / de mano: 60                 │
│  Full House:    15 / de mano: 30                 │
│  Cinco iguales: 20 / de mano: 40                 │
│  Cinco nueves:  30 / de mano: 60                 │
│  Póker:        100 / Real:   200 (solo de mano)  │
└──────────────────────────────────────────────────┘
```

---

*Póker de Dados v1.0 — Basado en el Póker de Dados tradicional portugués.*

