/// Data models for Dipok.
///
/// See game_specification.md §1, §7.

import 'constants.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// The six faces of a poker die.
enum DieFace {
  ace,
  king,
  queen,
  jack,
  ten,
  nine; // wildcard ("nove", 9)

  /// Sorting weight (highest face = highest weight).
  int get weight => switch (this) {
        ace => 6,
        king => 5,
        queen => 4,
        jack => 3,
        ten => 2,
        nine => 1,
      };
}

/// The five figure lines on the score card.
enum FigureLine {
  aces,
  kings,
  queens,
  jacks,
  tens;

  /// The die face that scores in this line.
  DieFace get dieFace => switch (this) {
        aces => DieFace.ace,
        kings => DieFace.king,
        queens => DieFace.queen,
        jacks => DieFace.jack,
        tens => DieFace.ten,
      };

  /// Multiplier applied to the raw total when calculating the final line score.
  int get multiplier => switch (this) {
        aces => 6,
        kings => 5,
        queens => 4,
        jacks => 3,
        tens => 2,
      };

  /// Reverse lookup: DieFace → FigureLine (returns null for nine).
  static FigureLine? fromDieFace(DieFace face) => switch (face) {
        DieFace.ace => FigureLine.aces,
        DieFace.king => FigureLine.kings,
        DieFace.queen => FigureLine.queens,
        DieFace.jack => FigureLine.jacks,
        DieFace.ten => FigureLine.tens,
        DieFace.nine => null,
      };
}

/// The three special (non-figure) lines.
enum SpecialLine { sequences, fullens, poker }

// ---------------------------------------------------------------------------
// Special Combinations (sealed hierarchy)
// ---------------------------------------------------------------------------

/// A special combination detected in a set of 5 dice.
sealed class SpecialCombination {
  const SpecialCombination();

  /// Points awarded for this combination.
  /// [fromHand]: true if all 5 dice were thrown (no held dice).
  int score({required bool fromHand});
}

/// All 5 dice show the same non-nine face. (§2.3)
class FiveOfAKind extends SpecialCombination {
  final DieFace face;
  const FiveOfAKind(this.face);

  @override
  int score({required bool fromHand}) => fromHand ? 40 : 20;
}

/// All 5 dice show nine. (§2.4)
class FiveNines extends SpecialCombination {
  const FiveNines();

  @override
  int score({required bool fromHand}) => fromHand ? 60 : 30;
}

/// Minimum straight: {K, Q, J, 10, 9}. (§2.5)
class MinStraight extends SpecialCombination {
  const MinStraight();

  @override
  int score({required bool fromHand}) => fromHand ? 30 : 15;
}

/// Maximum straight: {A, K, Q, J, 10}. (§2.5)
class MaxStraight extends SpecialCombination {
  const MaxStraight();

  @override
  int score({required bool fromHand}) => fromHand ? 60 : 30;
}

/// Full house: 3 of one face + 2 of another. (§2.6)
class FullHouse extends SpecialCombination {
  final DieFace threeFace;
  final DieFace twoFace;
  const FullHouse({required this.threeFace, required this.twoFace});

  @override
  int score({required bool fromHand}) => fromHand ? 30 : 15;
}

/// Poker: exactly 4 of one non-nine face. Only scores from hand. (§2.10)
class Poker extends SpecialCombination {
  final DieFace face;
  const Poker(this.face);

  @override
  int score({required bool fromHand}) => fromHand ? 100 : 0;
}

/// Royal Poker: exactly 4 aces + 1 king. Only scores from hand. (§2.10)
class RoyalPoker extends SpecialCombination {
  const RoyalPoker();

  @override
  int score({required bool fromHand}) => fromHand ? 200 : 0;
}

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

/// A single die.
class Die {
  final DieFace face;
  final bool held;

  const Die({required this.face, this.held = false});

  Die copyWith({DieFace? face, bool? held}) => Die(
        face: face ?? this.face,
        held: held ?? this.held,
      );

  @override
  String toString() => 'Die(${face.name}, held: $held)';
}

/// An entry in a special line (sequences, fullens, poker).
class SpecialEntry {
  final int score;
  final bool fromHand;

  const SpecialEntry({required this.score, required this.fromHand});

  @override
  String toString() => 'SpecialEntry($score, fromHand: $fromHand)';
}

/// A player's score card.
class ScoreCard {
  /// Figure lines: 5 lines × 5 columns. `null` = unfilled slot.
  final Map<FigureLine, List<int?>> figureScores;

  final List<SpecialEntry> sequenceEntries;
  final List<SpecialEntry> fullenEntries;
  final List<SpecialEntry> pokerEntries;

  ScoreCard({
    Map<FigureLine, List<int?>>? figureScores,
    List<SpecialEntry>? sequenceEntries,
    List<SpecialEntry>? fullenEntries,
    List<SpecialEntry>? pokerEntries,
  })  : figureScores = figureScores ??
            {
              for (final line in FigureLine.values)
                line: List<int?>.filled(columnsPerLine, null),
            },
        sequenceEntries = sequenceEntries ?? [],
        fullenEntries = fullenEntries ?? [],
        pokerEntries = pokerEntries ?? [];

  /// Index of the next unfilled column in [line], or `null` if all filled.
  int? nextOpenColumn(FigureLine line) {
    final cols = figureScores[line]!;
    for (var i = 0; i < cols.length; i++) {
      if (cols[i] == null) return i;
    }
    return null;
  }

  /// Number of filled columns in [line].
  int filledColumns(FigureLine line) =>
      figureScores[line]!.where((v) => v != null).length;

  /// Whether all 5 columns are filled in [line].
  bool isLineComplete(FigureLine line) =>
      filledColumns(line) == columnsPerLine;

  /// Sum of all filled column values in [line].
  int rawTotal(FigureLine line) =>
      figureScores[line]!.whereType<int>().fold(0, (a, b) => a + b);
}

/// A player.
class Player {
  final String name;
  final int index;
  final ScoreCard scoreCard;

  const Player({
    required this.name,
    required this.index,
    required this.scoreCard,
  });

  Player copyWith({String? name, ScoreCard? scoreCard}) => Player(
        name: name ?? this.name,
        index: index,
        scoreCard: scoreCard ?? this.scoreCard,
      );

  @override
  String toString() => 'Player($index: $name)';
}
