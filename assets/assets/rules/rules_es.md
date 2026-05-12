# P�ker de Dados — Reglas del Juego

> P�ker de Dados es la versión digital del clásico juego portugués de **Póker de Dados**.
> Esta página contiene primero una referencia rápida y después las reglas completas.

---

## Referencia Rápida

| | |
|---|---|
| **Jugadores** | 2 a 4 |
| **Dados** | 5 dados con caras: A · K · Q · J · 10 · 9 |
| **Turno** | Hasta 3 lanzamientos |
| **Objetivo** | Mayor puntuación total cuando el juego termina |
| **Fin del juego** | Cuando solo queda 1 fila de figura por cerrar |

**Caras (jerarquía descendente):**

| Cara | Nombre |
|---|---|
| A | As |
| K | Rey |
| Q | Dama |
| J | Valet |
| 10 | Diez |
| 9 | Pilo (comodín) |

El **9 (Pilo)** es un comodín: cuenta 1 punto para cualquier figura en la que el jugador esté jugando.

---

## Reglas Completas

### 1. Estructura del Turno

Un turno consiste en **hasta 3 lanzamientos**. En cada lanzamiento, el jugador puede:

- **Guardar dados** — seleccionar dados para conservar y relanzar los demás en el siguiente lanzamiento.
- **Anotar puntos** — registrar el resultado en una fila elegible y recoger los 5 dados para el siguiente lanzamiento.
- **Pasar** — avanzar al siguiente lanzamiento sin anotar ni guardar.

Si al final de los 3 lanzamientos el jugador **no ha anotado nada**, pierde el turno (sin penalización).

Se puede anotar en **filas diferentes** a lo largo del mismo turno, pero **no es posible anotar dos veces en la misma fila en el mismo turno**.

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

---

### 3. Filas de Figura (A, K, Q, J, 10)

#### Cálculo de puntos

Al anotar para una figura:

```
puntos = (nº de dados con la figura × 2) + (nº de 9s × 1)
```

Ejemplos (anotando para Damas):
- [Q, Q, Q, 9, K] → 3×2 + 1×1 = **7 pts**
- [Q, 9, 9, 9, A] → 1×2 + 3×1 = **5 pts**
- [Q, Q, Q, Q, 9] → 4×2 + 1×1 = **9 pts**

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

**Bonificación de cierre:** Si el jugador que cerró la fila lo hizo sin que ningún otro jugador la hubiera abierto, la puntuación del cerrador se **dobla**.

Ejemplo (Ases, ×6):

| Jugador | Columnas | Cálculo | Total |
|---|---|---|---|
| Ana (cerró) | 7 · 8 · 9 · 8 · 9 = 41 | 41 × 6 × 2 | **492** |
| Bruno (abrió) | 7 · 8 = 15 | 15 × 6 | **90** |
| Carla (no abrió) | — | 0 | **0** |

---

### 4. Combinaciones Especiales

#### 4.1 Escaleras

| Escalera | Caras | Puntos | De mano |
|---|---|---|---|
| Mínima | K · Q · J · 10 · 9 | 15 | **30** |
| Máxima | A · K · Q · J · 10 | 30 | **60** |

Se registran en la fila de **Escaleras**.

#### 4.2 Full House

Cualquier combinación de **3 de una cara + 2 de otra** (incluyendo 9s).

| Puntos | De mano |
|---|---|
| 15 | **30** |

#### 4.3 Cinco Iguales

Cinco dados con la misma cara (excluyendo 9s).

| Puntos | De mano |
|---|---|
| 20 | **40** |

También cuenta como Full House.

#### 4.4 Cinco Nueves ("Pilada")

| Puntos | De mano |
|---|---|
| 30 | **60** |

Puede registrarse en **cualquier fila de figura** (a elección del jugador).

#### 4.5 Póker (4 iguales — solo de mano)

| Tipo | Condición | Puntos |
|---|---|---|
| Póker | 4 iguales de mano | **100** |
| Póker Real | 4 Ases + 1 Rey de mano | **200** |

---

### 5. Regla "De Mano"

Una combinación es **"de mano"** cuando se obtiene en un lanzamiento en el que **los 5 dados se lanzan sin ninguno guardado**. En esas condiciones, la puntuación de las combinaciones especiales se **dobla**.

---

### 6. Modo Acumulación

Se activa automáticamente cuando, al anotar en una fila de figura, **los 5 dados** muestran la figura objetivo o 9s.

El jugador puede continuar relanzando y acumulando puntos. El total acumulado se registra en la columna al finalizar (si alcanza el mínimo).

---

### 7. Fin del Juego y Ganador

El juego termina cuando **solo queda 1 fila de figura** por cerrar.

```
Total = (suma de las 5 filas × multiplicadores) + Escaleras + Full House + Póker
```

Gana el jugador con la **puntuación total más alta**.

---

*P�ker de Dados v1.0 — Basado en el Póker de Dados tradicional portugués.*

