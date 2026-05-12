/// Scoring engine for Dipok — pure functions, no side effects.
///
/// See game_specification.md §2, §3, §5, §8.

import 'constants.dart';
import 'models.dart';

// ---------------------------------------------------------------------------
// §2.1  Figure point calculation
// ---------------------------------------------------------------------------

/// Calculate figure points for [dice] targeting [target] line.
///
/// Formula: (count of matching face × 2) + (count of NINE × 1).
int calculateFigurePoints(List<DieFace> dice, FigureLine target) {
  final targetFace = target.dieFace;
  var matchCount = 0;
  var nineCount = 0;
  for (final face in dice) {
    if (face == targetFace) {
      matchCount++;
    } else if (face == DieFace.nine) {
      nineCount++;
    }
  }
  return matchCount * 2 + nineCount;
}

// ---------------------------------------------------------------------------
// §2.3–§2.10  Special combination detection
// ---------------------------------------------------------------------------

/// Detect all special combinations present in [dice].
///
/// A single roll can yield multiple combos (e.g. five-of-a-kind also counts
/// as a full house). NINE is **not** a wildcard for combination detection —
/// it only acts as wildcard for figure point calculation (§2.1).
List<SpecialCombination> detectSpecialCombinations(List<DieFace> dice) {
  assert(dice.length == diceCount);

  final counts = <DieFace, int>{};
  for (final face in dice) {
    counts[face] = (counts[face] ?? 0) + 1;
  }

  final combos = <SpecialCombination>[];

  // Five nines (§2.4) — exclusive, nothing else possible
  if (counts[DieFace.nine] == 5) {
    combos.add(const FiveNines());
    return combos;
  }

  // Five of a kind (§2.3) — also counts as a fullen
  for (final face in DieFace.values) {
    if (face == DieFace.nine) continue;
    if (counts[face] == 5) {
      combos.add(FiveOfAKind(face));
      combos.add(FullHouse(threeFace: face, twoFace: face));
      return combos; // can't be a straight or poker with 5-of-a-kind
    }
  }

  // Straights (§2.5) — require 5 distinct faces
  final faceSet = dice.toSet();
  if (faceSet.length == 5) {
    if (faceSet.contains(DieFace.ace) &&
        faceSet.contains(DieFace.king) &&
        faceSet.contains(DieFace.queen) &&
        faceSet.contains(DieFace.jack) &&
        faceSet.contains(DieFace.ten)) {
      combos.add(const MaxStraight());
    } else if (faceSet.contains(DieFace.king) &&
        faceSet.contains(DieFace.queen) &&
        faceSet.contains(DieFace.jack) &&
        faceSet.contains(DieFace.ten) &&
        faceSet.contains(DieFace.nine)) {
      combos.add(const MinStraight());
    }
    // Straights have 5 distinct faces → no poker, no full house possible
    return combos;
  }

  // Poker / Royal Poker (§2.10) — exactly 4 of one face
  // Royal Poker: 4 aces + 1 king
  if (counts[DieFace.ace] == 4 && counts[DieFace.king] == 1) {
    combos.add(const RoyalPoker());
  } else {
    for (final face in DieFace.values) {
      if (counts[face] == 4) {
        combos.add(Poker(face));
        break;
      }
    }
  }

  // Full house (§2.6) — exactly 3 of one face + 2 of another
  // (4+1 splits are NOT full houses)
  DieFace? threeFace;
  DieFace? twoFace;
  for (final entry in counts.entries) {
    if (entry.value == 3) threeFace = entry.key;
    if (entry.value == 2) twoFace = entry.key;
  }
  if (threeFace != null && twoFace != null) {
    combos.add(FullHouse(threeFace: threeFace, twoFace: twoFace));
  }

  return combos;
}

// ---------------------------------------------------------------------------
// §2.2  Column eligibility
// ---------------------------------------------------------------------------

/// Whether [points] can be registered in [line]'s next open column.
///
/// Returns `false` if the line is already full or points are below the
/// column's minimum threshold.
bool canScoreInLine(ScoreCard card, FigureLine line, int points) {
  final col = card.nextOpenColumn(line);
  if (col == null) return false;
  return points >= columnMinimums[col];
}

// ---------------------------------------------------------------------------
// §3  Line closing & final scoring
// ---------------------------------------------------------------------------

/// Calculate the final score for one player's figure line.
///
/// * [rawTotal] — sum of the player's filled columns in this line.
/// * [multiplier] — the line's multiplier (e.g. ×6 for aces).
/// * [isCloser] — whether this player closed the line.
/// * [hasUnopenedPlayers] — whether any player never opened this line.
int calculateLineScore({
  required int rawTotal,
  required int multiplier,
  required bool isCloser,
  required bool hasUnopenedPlayers,
}) {
  if (rawTotal == 0) return 0;
  var score = rawTotal * multiplier;
  if (hasUnopenedPlayers && isCloser) {
    score *= 2;
  }
  return score;
}

/// Calculate a player's grand total across all lines.
///
/// * [players] — all players in the game.
/// * [playerIndex] — the player to score.
/// * [closedBy] — maps each closed [FigureLine] to the index of the player
///   who closed it. Lines that haven't been closed are absent from the map.
int calculateTotalScore({
  required List<Player> players,
  required int playerIndex,
  required Map<FigureLine, int> closedBy,
}) {
  final card = players[playerIndex].scoreCard;
  var total = 0;

  for (final line in FigureLine.values) {
    final raw = card.rawTotal(line);
    if (raw == 0) continue;

    final anyUnopened =
        players.any((p) => p.scoreCard.filledColumns(line) == 0);
    final isCloser = closedBy[line] == playerIndex;

    total += calculateLineScore(
      rawTotal: raw,
      multiplier: line.multiplier,
      isCloser: isCloser,
      hasUnopenedPlayers: anyUnopened,
    );
  }

  // Special lines — just sum entries, no multiplier
  total += card.sequenceEntries.fold(0, (sum, e) => sum + e.score);
  total += card.fullenEntries.fold(0, (sum, e) => sum + e.score);
  total += card.pokerEntries.fold(0, (sum, e) => sum + e.score);

  return total;
}

// ---------------------------------------------------------------------------
// §5.3  Game end
// ---------------------------------------------------------------------------

/// Whether the game should end (4 of 8 total lines closed).
/// Total lines = 5 figure lines + 3 special lines (sequences, fullens, poker).
bool isGameOver(Set<FigureLine> closedLines, [Set<SpecialLine> closedSpecialLines = const {}]) =>
    (closedLines.length + closedSpecialLines.length) >= closedLinesForGameEnd;
