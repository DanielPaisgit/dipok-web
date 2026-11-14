# Poker de Dés — Règles du Jeu

> Bienvenue au Poker de Dés ! Amusez-vous avec ce jeu portugais classique.
> Cette page contient d'abord une référence rapide, puis les règles complètes.

> 📌 À la fin de cette page, vous trouverez un [**Résumé Visuel**](#resumo) de toutes les règles.

---

## Référence Rapide

| | |
|---|---|
| **Joueurs** | 2 à 4 |
| **Dés** | 5 dés avec faces : A · K · Q · J · 10 · 9 |
| **Tour** | Jusqu'à 3 lancers |
| **Objectif** | Score total le plus élevé à la fin de la partie |
| **Fin de partie** | Quand 6 des 7 lignes non-Poker sont fermées |

**Faces (hiérarchie décroissante) :**

| Face | Nom |
|---|---|
| A | As |
| K | Roi |
| Q | Dame |
| J | Valet |
| 10 | Dix |
| 9 | Nove (joker) |

<!-- FACE_LEGEND -->

Le **9 (Nove)** est un joker : il compte 1 point pour n'importe quelle figure jouée par le joueur.
> **Note :** Il n’y a pas d’enseignes (couleurs) — le jeu repose uniquement sur les faces des dés.
---

## Règles Complètes

### 1. Structure d'un Tour

Un tour comprend **jusqu'à 3 lancers**. À chaque lancer, le joueur peut :

- **Garder des dés** — sélectionner des dés à conserver et relancer les autres au prochain lancer.
- **Marquer des points** — inscrire le résultat dans une ligne éligible et ramasser les 5 dés pour le prochain lancer.
- **Passer** — avancer au prochain lancer sans marquer ni garder.

> **Note :** Au début de chaque tour, les 5 dés sont lancés — automatiquement, ou avec le bouton « Lancer » si le *premier lancer manuel* est activé. C’est le premier lancer.

Si après les 3 lancers le joueur **n'a marqué aucun point**, il perd son tour (sans pénalité).

Il est possible de marquer dans **des lignes différentes** au cours du même tour, et aussi **dans la même ligne sur des lancers différents** du même tour (chaque inscription va dans la colonne disponible suivante).

---

### 2. Tableau de Score

Le tableau de chaque joueur comporte **8 lignes** :

| # | Ligne | Type |
|---|---|---|
| 1 | As (A) | Figure |
| 2 | Rois (K) | Figure |
| 3 | Dames (Q) | Figure |
| 4 | Valets (J) | Figure |
| 5 | Dix (10) | Figure |
| 6 | Séquences | Spécial |
| 7 | Full Houses | Spécial |
| 8 | Poker | Spécial |

**Aspect du tableau avant toute saisie :**

| Ligne | ≥7 | ≥6 | ≥6 | ≥8 | ≥8 |
|---|:---:|:---:|:---:|:---:|:---:|
| A (×6) | | | | | |
| K (×5) | | | | | |
| Q (×4) | | | | | |
| J (×3) | | | | | |
| 10 (×2) | | | | | |
| Séquences | | | | | |
| Full Houses | | | | | |
| Poker | | | | | |

---

### 3. Lignes de Figure (A, K, Q, J, 10)

#### Calcul des points

Pour marquer dans une figure :

```
points = (nbre de dés avec la figure × 2) + (nbre de 9 × 1)
```

Exemples (en jouant pour les Dames) :

**[Q, Q, Q, 9, K]** → 3×2 + 1×1 = **7 pts**
<!-- DICE: Q,Q,Q,9,K -->

**[Q, 9, 9, 9, A]** → 1×2 + 3×1 = **5 pts**
<!-- DICE: Q,9,9,9,A -->

**[Q, Q, Q, Q, 9]** → 4×2 + 1×1 = **9 pts**
<!-- DICE: Q,Q,Q,Q,9 -->

#### Colonnes et minimums

Chaque ligne de figure comporte **5 colonnes** à remplir de gauche à droite :

| Colonne | Nom | Minimum |
|---|---|---|
| 1re | Ouvrir | **≥ 7** |
| 2e | — | **≥ 6** |
| 3e | — | **≥ 6** |
| 4e | — | **≥ 8** |
| 5e | Fermer | **≥ 8** |

#### Fermer une ligne

Une ligne est **fermée** quand un joueur remplit ses 5 colonnes. Plus personne ne peut marquer dans cette ligne.

#### Multiplicateurs

| Ligne | Multiplicateur |
|---|---|
| As (A) | × 6 |
| Rois (K) | × 5 |
| Dames (Q) | × 4 |
| Valets (J) | × 3 |
| Dix (10) | × 2 |

**Bonus de fermeture :** Si le joueur qui a fermé la ligne l'a fait sans qu'aucun autre joueur ne l'ait ouverte, le score de **tous les joueurs qui l'ont ouverte** (y compris le fermeur) est **doublé**. Cette règle s'applique aussi aux lignes Séquences et Full Houses (pas au Poker).

Exemple (As, ×6) :

| Joueur | Colonnes | Calcul | Total |
|---|---|---|---|
| Ana (a fermé) | 7 · 8 · 9 · 8 · 9 = 41 | 41 × 6 × 2 | **492** |
| Bruno (a ouvert) | 7 · 8 = 15 | 15 × 6 × 2 | **180** |
| Carla (n'a pas ouvert) | — | 0 | **0** |

---

### 4. Règle «\u00a0En Main\u00a0»

Une combinaison est **«\u00a0en main\u00a0»** quand elle est obtenue lors d'un lancer où **les 5 dés sont lancés sans aucun dé gardé**. Dans ces conditions, le score des combinaisons spéciales est **doublé**.

---

### 5. Combinaisons Spéciales

#### 5.1 Séquences

| Séquence | Faces | Points | En main |
|---|---|---|---|
| Minimale | K · Q · J · 10 · 9 | 15 | **30** |
| Maximale | A · K · Q · J · 10 | 30 | **60** |

Séquence minimale :
<!-- DICE: K,Q,J,10,9 -->

Séquence maximale :
<!-- DICE: A,K,Q,J,10 -->

#### 5.2 Full House

Toute combinaison de **3 dés d'une face + 2 dés d'une autre** (y compris les 9).

Exemple : **[A, A, A, K, K]** (3 As + 2 Rois)
<!-- DICE: A,A,A,K,K -->

| Points | En main |
|---|---|
| 15 | **30** |

#### 5.3 Cinq identiques

Exemple : **[K, K, K, K, K]**
<!-- DICE: K,K,K,K,K -->

| Points | En main |
|---|---|
| 20 | **40** |

Compte également comme Full House.

#### 5.4 Cinq 9

Exemple : **[9, 9, 9, 9, 9]**
<!-- DICE: 9,9,9,9,9 -->

| Points | En main |
|---|---|
| 30 | **60** |

Peut être inscrit dans **n'importe quelle ligne de figure** (au choix du joueur).

#### 5.5 Poker (4 identiques — en main seulement)

| Type | Condition | Points |
|---|---|---|
| Poker | 4 identiques en main | **100** |
| Poker Royal | 4 As + 1 Roi en main | **200** |

Poker — **[K, K, K, K, Q]** :
<!-- DICE: K,K,K,K,Q -->

Poker Royal — **[A, A, A, A, K]** :
<!-- DICE: A,A,A,A,K -->

---

### 6. Mode Accumulation

Activé automatiquement lorsque, en marquant dans une ligne de figure, **les 5 dés** affichent la figure cible ou des 9.

Exemple (en jouant pour les Dames — toutes comptent) : **[Q, Q, Q, 9, 9]**
<!-- DICE: Q,Q,Q,9,9 -->

Le joueur peut continuer à relancer et accumuler des points. Le total accumulé est inscrit dans la colonne à la finalisation (s'il atteint le minimum).

---

### 7. Fin de Partie et Vainqueur

La partie se termine quand **6 des 7 lignes non-Poker** sont fermées. Comptent pour la fin : les 5 lignes de figure + Séquences + Full Houses. Le **Poker ne compte pas** pour la fin de partie.

```
Total = (somme des 5 lignes × multiplicateurs) + Séquences + Full Houses + Poker
```

Le joueur avec le **score total le plus élevé** remporte la partie.

---

### 8. Résumé Visuel

```
┌───────────────────────────────────────────────────────────┐
│  TOUR : 3 lancers                                         │
│                                                           │
│  Lancer → Garder des dés ?                                │
│            └─ Oui → prochain lancer (garde les dés)       │
│            └─ Non → Marquer dans une ligne éligible       │
│                     (ramasse tout, compte comme en main)  │
│                   → Passer (sans points, sans garder)     │
│                                                           │
│  Après 3 lancers → perd son tour                          │
└───────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  LIGNES DE FIGURE : 5 colonnes, de gauche à droite          │
│  Min : ≥7 · ≥6 · ≥6 · ≥8 · ≥8                               │
│  Total final × multiplicateur (×2 si fermé sans ouverture)  │
└─────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────┐
│  SPÉCIALES (s'additionnent, ne multiplient pas)      │
│  Séq. min. :   15 / en main : 30                     │
│  Séq. max. :   30 / en main : 60                     │
│  Full House :  15 / en main : 30                     │
│  Cinq ident. : 20 / en main : 40                     │
│  Cinq 9 :      30 / en main : 60                     │
│  Poker :      100 / Royal : 200 (en main seulement)  │
└──────────────────────────────────────────────────────┘
```

---

*Poker de Dés v1.0 — Basé sur le Poker aux Dés traditionnel portugais.*

