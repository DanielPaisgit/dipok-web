# Poker de D�s — Règles du Jeu

> Poker de D�s est la version numérique du classique jeu portugais de **Poker aux Dés**.
> Cette page contient d'abord une référence rapide, puis les règles complètes.

---

## Référence Rapide

| | |
|---|---|
| **Joueurs** | 2 à 4 |
| **Dés** | 5 dés avec faces : A · K · Q · J · 10 · 9 |
| **Tour** | Jusqu'à 3 lancers |
| **Objectif** | Score total le plus élevé à la fin de la partie |
| **Fin de partie** | Quand il ne reste plus qu'une ligne de figure à fermer |

**Faces (hiérarchie décroissante) :**

| Face | Nom |
|---|---|
| A | As |
| K | Roi |
| Q | Dame |
| J | Valet |
| 10 | Dix |
| 9 | Nove (joker) |

Le **9 (Nove)** est un joker : il compte 1 point pour n'importe quelle figure jouée par le joueur.

---

## Règles Complètes

### 1. Structure d'un Tour

Un tour comprend **jusqu'à 3 lancers**. À chaque lancer, le joueur peut :

- **Garder des dés** — sélectionner des dés à conserver et relancer les autres au prochain lancer.
- **Marquer des points** — inscrire le résultat dans une ligne éligible et ramasser les 5 dés pour le prochain lancer.
- **Passer** — avancer au prochain lancer sans marquer ni garder.

Si après les 3 lancers le joueur **n'a marqué aucun point**, il perd son tour (sans pénalité).

Il est possible de marquer dans **des lignes différentes** au cours du même tour, mais **on ne peut pas marquer deux fois dans la même ligne pendant un tour**.

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

---

### 3. Lignes de Figure (A, K, Q, J, 10)

#### Calcul des points

Pour marquer dans une figure :

```
points = (nbre de dés avec la figure × 2) + (nbre de 9 × 1)
```

Exemples (en jouant pour les Dames) :
- [Q, Q, Q, 9, K] → 3×2 + 1×1 = **7 pts**
- [Q, 9, 9, 9, A] → 1×2 + 3×1 = **5 pts**
- [Q, Q, Q, Q, 9] → 4×2 + 1×1 = **9 pts**

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

**Bonus de fermeture :** Si le joueur qui a fermé la ligne l'a fait sans qu'aucun autre joueur ne l'ait ouverte, son score pour cette ligne est **doublé**.

Exemple (As, ×6) :

| Joueur | Colonnes | Calcul | Total |
|---|---|---|---|
| Ana (a fermé) | 7 · 8 · 9 · 8 · 9 = 41 | 41 × 6 × 2 | **492** |
| Bruno (a ouvert) | 7 · 8 = 15 | 15 × 6 | **90** |
| Carla (n'a pas ouvert) | — | 0 | **0** |

---

### 4. Combinaisons Spéciales

#### 4.1 Séquences

| Séquence | Faces | Points | En main |
|---|---|---|---|
| Minimale | K · Q · J · 10 · 9 | 15 | **30** |
| Maximale | A · K · Q · J · 10 | 30 | **60** |

#### 4.2 Full House

Toute combinaison de **3 dés d'une face + 2 dés d'une autre** (y compris les 9).

| Points | En main |
|---|---|
| 15 | **30** |

#### 4.3 Cinq identiques

| Points | En main |
|---|---|
| 20 | **40** |

Compte également comme Full House.

#### 4.4 Cinq 9

| Points | En main |
|---|---|
| 30 | **60** |

Peut être inscrit dans **n'importe quelle ligne de figure** (au choix du joueur).

#### 4.5 Poker (4 identiques — en main seulement)

| Type | Condition | Points |
|---|---|---|
| Poker | 4 identiques en main | **100** |
| Poker Royal | 4 As + 1 Roi en main | **200** |

---

### 5. Règle «\u00a0En Main\u00a0»

Une combinaison est **«\u00a0en main\u00a0»** quand elle est obtenue lors d'un lancer où **les 5 dés sont lancés sans aucun dé gardé**. Dans ces conditions, le score des combinaisons spéciales est **doublé**.

---

### 6. Mode Accumulation

Activé automatiquement lorsque, en marquant dans une ligne de figure, **les 5 dés** affichent la figure cible ou des 9.

Le joueur peut continuer à relancer et accumuler des points. Le total accumulé est inscrit dans la colonne à la finalisation (s'il atteint le minimum).

---

### 7. Fin de Partie et Vainqueur

La partie se termine quand **il ne reste qu'une seule ligne de figure** à fermer.

```
Total = (somme des 5 lignes × multiplicateurs) + Séquences + Full Houses + Poker
```

Le joueur avec le **score total le plus élevé** remporte la partie.

---

*Poker de D�s v1.0 — Basé sur le Poker aux Dés traditionnel portugais.*

