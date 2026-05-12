/// Unit tests for the Dipok scoring engine.
///
/// Test cases from game_specification.md §9.

import 'package:test/test.dart';
import 'package:dipok/engine/constants.dart';
import 'package:dipok/engine/models.dart';
import 'package:dipok/engine/scoring.dart';

// Shorthand aliases for readability
const A = DieFace.ace;
const K = DieFace.king;
const Q = DieFace.queen;
const J = DieFace.jack;
const T = DieFace.ten;
const N = DieFace.nine;

void main() {
  // -----------------------------------------------------------------------
  // §9.1 — Figure point calculation
  // -----------------------------------------------------------------------
  group('calculateFigurePoints', () {
    test('[A, A, A, 9, 9] for Aces → 8', () {
      expect(calculateFigurePoints([A, A, A, N, N], FigureLine.aces), 8);
    });

    test('[K, K, 9, J, Q] for Kings → 5', () {
      expect(calculateFigurePoints([K, K, N, J, Q], FigureLine.kings), 5);
    });

    test('[10, 10, 10, 10, 9] for Tens → 9', () {
      expect(calculateFigurePoints([T, T, T, T, N], FigureLine.tens), 9);
    });

    test('[9, 9, 9, 9, 9] for any figure → 5', () {
      for (final line in FigureLine.values) {
        expect(calculateFigurePoints([N, N, N, N, N], line), 5);
      }
    });

    test('[A, A, A, A, A] for Aces → 10', () {
      expect(calculateFigurePoints([A, A, A, A, A], FigureLine.aces), 10);
    });

    test('no matching face and no nines → 0', () {
      expect(calculateFigurePoints([K, Q, J, T, K], FigureLine.aces), 0);
    });

    test('only nines contribute 1 pt each', () {
      expect(calculateFigurePoints([N, N, N, K, Q], FigureLine.aces), 3);
    });

    test('matching face without nines', () {
      expect(calculateFigurePoints([Q, Q, Q, K, J], FigureLine.queens), 6);
    });
  });

  // -----------------------------------------------------------------------
  // §9.2 — Special combination detection
  // -----------------------------------------------------------------------
  group('detectSpecialCombinations', () {
    test('MinStraight: [K, Q, J, 10, 9]', () {
      final combos = detectSpecialCombinations([K, Q, J, T, N]);
      expect(combos, hasLength(1));
      expect(combos.first, isA<MinStraight>());
      expect(combos.first.score(fromHand: false), 15);
      expect(combos.first.score(fromHand: true), 30);
    });

    test('MaxStraight: [A, K, Q, J, 10]', () {
      final combos = detectSpecialCombinations([A, K, Q, J, T]);
      expect(combos, hasLength(1));
      expect(combos.first, isA<MaxStraight>());
      expect(combos.first.score(fromHand: false), 30);
      expect(combos.first.score(fromHand: true), 60);
    });

    test('MaxStraight order-independent: [10, A, J, K, Q]', () {
      final combos = detectSpecialCombinations([T, A, J, K, Q]);
      expect(combos, hasLength(1));
      expect(combos.first, isA<MaxStraight>());
    });

    test('FiveNines: [9, 9, 9, 9, 9]', () {
      final combos = detectSpecialCombinations([N, N, N, N, N]);
      expect(combos, hasLength(1));
      expect(combos.first, isA<FiveNines>());
      expect(combos.first.score(fromHand: false), 30);
      expect(combos.first.score(fromHand: true), 60);
    });

    test('FiveOfAKind: [Q, Q, Q, Q, Q] — also yields FullHouse', () {
      final combos = detectSpecialCombinations([Q, Q, Q, Q, Q]);
      expect(combos, hasLength(2));
      expect(combos.whereType<FiveOfAKind>(), hasLength(1));
      expect(combos.whereType<FullHouse>(), hasLength(1));

      final foak = combos.whereType<FiveOfAKind>().first;
      expect(foak.face, Q);
      expect(foak.score(fromHand: false), 20);
      expect(foak.score(fromHand: true), 40);
    });

    test('FullHouse: [A, A, A, K, K]', () {
      final combos = detectSpecialCombinations([A, A, A, K, K]);
      expect(combos, hasLength(1));
      final fh = combos.first as FullHouse;
      expect(fh.threeFace, A);
      expect(fh.twoFace, K);
      expect(fh.score(fromHand: false), 15);
      expect(fh.score(fromHand: true), 30);
    });

    test('FullHouse with nines: [J, J, 9, 9, 9]', () {
      final combos = detectSpecialCombinations([J, J, N, N, N]);
      expect(combos, hasLength(1));
      final fh = combos.first as FullHouse;
      expect(fh.threeFace, N);
      expect(fh.twoFace, J);
    });

    test('Poker: [K, K, K, K, Q]', () {
      final combos = detectSpecialCombinations([K, K, K, K, Q]);
      expect(combos, hasLength(1));
      final p = combos.first as Poker;
      expect(p.face, K);
      expect(p.score(fromHand: true), 100);
      expect(p.score(fromHand: false), 0);
    });

    test('RoyalPoker: [A, A, A, A, K]', () {
      final combos = detectSpecialCombinations([A, A, A, A, K]);
      expect(combos, hasLength(1));
      expect(combos.first, isA<RoyalPoker>());
      expect(combos.first.score(fromHand: true), 200);
      expect(combos.first.score(fromHand: false), 0);
    });

    test('Poker (not Royal): [A, A, A, A, Q]', () {
      final combos = detectSpecialCombinations([A, A, A, A, Q]);
      expect(combos, hasLength(1));
      expect(combos.first, isA<Poker>());
      expect((combos.first as Poker).face, A);
      expect(combos.first.score(fromHand: true), 100);
    });

    test('No special: [A, K, Q, 9, 9]', () {
      final combos = detectSpecialCombinations([A, K, Q, N, N]);
      expect(combos, isEmpty);
    });

    test('No special: [A, A, K, Q, J] — just a pair', () {
      final combos = detectSpecialCombinations([A, A, K, Q, J]);
      expect(combos, isEmpty);
    });

    test('Four nines IS a poker', () {
      final combos = detectSpecialCombinations([N, N, N, N, A]);
      expect(combos.whereType<Poker>(), hasLength(1));
      expect(combos.whereType<Poker>().first.face, DieFace.nine);
    });
  });

  // -----------------------------------------------------------------------
  // §9.3 — Minimum threshold
  // -----------------------------------------------------------------------
  group('canScoreInLine', () {
    late ScoreCard emptyCard;

    setUp(() {
      emptyCard = ScoreCard();
    });

    test('column 0 (min 7): 7 → yes, 6 → no', () {
      expect(canScoreInLine(emptyCard, FigureLine.aces, 7), isTrue);
      expect(canScoreInLine(emptyCard, FigureLine.aces, 6), isFalse);
    });

    test('column 1 (min 6): 6 → yes, 5 → no', () {
      // Fill column 0 first
      final card = ScoreCard(figureScores: {
        FigureLine.aces: [7, null, null, null, null],
        for (final l in FigureLine.values.where((l) => l != FigureLine.aces))
          l: List<int?>.filled(columnsPerLine, null),
      });
      expect(canScoreInLine(card, FigureLine.aces, 6), isTrue);
      expect(canScoreInLine(card, FigureLine.aces, 5), isFalse);
    });

    test('column 3 (min 8): 8 → yes, 7 → no', () {
      final card = ScoreCard(figureScores: {
        FigureLine.aces: [7, 6, 6, null, null],
        for (final l in FigureLine.values.where((l) => l != FigureLine.aces))
          l: List<int?>.filled(columnsPerLine, null),
      });
      expect(canScoreInLine(card, FigureLine.aces, 8), isTrue);
      expect(canScoreInLine(card, FigureLine.aces, 7), isFalse);
    });

    test('column 4 (min 8): 8 → yes', () {
      final card = ScoreCard(figureScores: {
        FigureLine.aces: [7, 6, 6, 8, null],
        for (final l in FigureLine.values.where((l) => l != FigureLine.aces))
          l: List<int?>.filled(columnsPerLine, null),
      });
      expect(canScoreInLine(card, FigureLine.aces, 8), isTrue);
    });

    test('full line → cannot score', () {
      final card = ScoreCard(figureScores: {
        FigureLine.aces: [7, 8, 9, 8, 9],
        for (final l in FigureLine.values.where((l) => l != FigureLine.aces))
          l: List<int?>.filled(columnsPerLine, null),
      });
      expect(canScoreInLine(card, FigureLine.aces, 10), isFalse);
    });
  });

  // -----------------------------------------------------------------------
  // §9.4 — Line closing & final scoring
  // -----------------------------------------------------------------------
  group('calculateLineScore', () {
    test('normal scoring (no unopened bonus)', () {
      // rawTotal 41, aces ×6, no bonus
      expect(
        calculateLineScore(
          rawTotal: 41,
          multiplier: 6,
          isCloser: true,
          hasUnopenedPlayers: false,
        ),
        246,
      );
    });

    test('closer gets doubled when unopened players exist', () {
      expect(
        calculateLineScore(
          rawTotal: 41,
          multiplier: 6,
          isCloser: true,
          hasUnopenedPlayers: true,
        ),
        492,
      );
    });

    test('non-closer does NOT double even with unopened players', () {
      expect(
        calculateLineScore(
          rawTotal: 15,
          multiplier: 6,
          isCloser: false,
          hasUnopenedPlayers: true,
        ),
        90,
      );
    });

    test('zero raw total always yields zero', () {
      expect(
        calculateLineScore(
          rawTotal: 0,
          multiplier: 6,
          isCloser: true,
          hasUnopenedPlayers: true,
        ),
        0,
      );
    });
  });

  group('calculateTotalScore (§9.4 full example)', () {
    test('4-player aces line closing scenario', () {
      // P1 closed aces: [7,8,9,8,9] = 41 → 41×6×2 = 492
      // P2 opened:      [7,8,_,_,_] = 15 → 15×6   = 90
      // P3 never opened:[_,_,_,_,_] = 0  → 0
      // P4 opened:      [7,_,_,_,_] = 7  → 7×6    = 42
      final emptyLine = List<int?>.filled(columnsPerLine, null);
      final players = [
        Player(
          name: 'P1',
          index: 0,
          scoreCard: ScoreCard(figureScores: {
            FigureLine.aces: [7, 8, 9, 8, 9],
            FigureLine.kings: List<int?>.from(emptyLine),
            FigureLine.queens: List<int?>.from(emptyLine),
            FigureLine.jacks: List<int?>.from(emptyLine),
            FigureLine.tens: List<int?>.from(emptyLine),
          }),
        ),
        Player(
          name: 'P2',
          index: 1,
          scoreCard: ScoreCard(figureScores: {
            FigureLine.aces: [7, 8, null, null, null],
            FigureLine.kings: List<int?>.from(emptyLine),
            FigureLine.queens: List<int?>.from(emptyLine),
            FigureLine.jacks: List<int?>.from(emptyLine),
            FigureLine.tens: List<int?>.from(emptyLine),
          }),
        ),
        Player(
          name: 'P3',
          index: 2,
          scoreCard: ScoreCard(figureScores: {
            FigureLine.aces: List<int?>.from(emptyLine),
            FigureLine.kings: List<int?>.from(emptyLine),
            FigureLine.queens: List<int?>.from(emptyLine),
            FigureLine.jacks: List<int?>.from(emptyLine),
            FigureLine.tens: List<int?>.from(emptyLine),
          }),
        ),
        Player(
          name: 'P4',
          index: 3,
          scoreCard: ScoreCard(figureScores: {
            FigureLine.aces: [7, null, null, null, null],
            FigureLine.kings: List<int?>.from(emptyLine),
            FigureLine.queens: List<int?>.from(emptyLine),
            FigureLine.jacks: List<int?>.from(emptyLine),
            FigureLine.tens: List<int?>.from(emptyLine),
          }),
        ),
      ];

      final closedBy = {FigureLine.aces: 0}; // P1 closed aces

      expect(calculateTotalScore(players: players, playerIndex: 0, closedBy: closedBy), 492);
      expect(calculateTotalScore(players: players, playerIndex: 1, closedBy: closedBy), 90);
      expect(calculateTotalScore(players: players, playerIndex: 2, closedBy: closedBy), 0);
      expect(calculateTotalScore(players: players, playerIndex: 3, closedBy: closedBy), 42);
    });

    test('special line entries are summed without multiplier', () {
      final players = [
        Player(
          name: 'P1',
          index: 0,
          scoreCard: ScoreCard(
            sequenceEntries: [
              const SpecialEntry(score: 15, fromHand: false),
              const SpecialEntry(score: 60, fromHand: true),
            ],
            fullenEntries: [
              const SpecialEntry(score: 15, fromHand: false),
            ],
            pokerEntries: [
              const SpecialEntry(score: 100, fromHand: true),
            ],
          ),
        ),
      ];
      // 15 + 60 + 15 + 100 = 190
      expect(
        calculateTotalScore(players: players, playerIndex: 0, closedBy: {}),
        190,
      );
    });
  });

  // -----------------------------------------------------------------------
  // §9.5 — Game end
  // -----------------------------------------------------------------------
  group('isGameOver', () {
    test('4 lines closed → game over', () {
      expect(
        isGameOver({FigureLine.aces, FigureLine.kings, FigureLine.queens, FigureLine.jacks}),
        isTrue,
      );
    });

    test('5 lines closed → game over', () {
      expect(isGameOver(FigureLine.values.toSet()), isTrue);
    });

    test('3 lines closed → not over', () {
      expect(
        isGameOver({FigureLine.aces, FigureLine.kings, FigureLine.queens}),
        isFalse,
      );
    });

    test('0 lines closed → not over', () {
      expect(isGameOver({}), isFalse);
    });
  });

  // -----------------------------------------------------------------------
  // Model helpers
  // -----------------------------------------------------------------------
  group('ScoreCard helpers', () {
    test('nextOpenColumn on empty line → 0', () {
      final card = ScoreCard();
      expect(card.nextOpenColumn(FigureLine.aces), 0);
    });

    test('nextOpenColumn after filling two columns → 2', () {
      final card = ScoreCard(figureScores: {
        FigureLine.aces: [7, 8, null, null, null],
        for (final l in FigureLine.values.where((l) => l != FigureLine.aces))
          l: List<int?>.filled(columnsPerLine, null),
      });
      expect(card.nextOpenColumn(FigureLine.aces), 2);
    });

    test('nextOpenColumn on full line → null', () {
      final card = ScoreCard(figureScores: {
        FigureLine.aces: [7, 8, 9, 8, 9],
        for (final l in FigureLine.values.where((l) => l != FigureLine.aces))
          l: List<int?>.filled(columnsPerLine, null),
      });
      expect(card.nextOpenColumn(FigureLine.aces), isNull);
    });

    test('rawTotal sums only filled columns', () {
      final card = ScoreCard(figureScores: {
        FigureLine.aces: [7, 8, null, null, null],
        for (final l in FigureLine.values.where((l) => l != FigureLine.aces))
          l: List<int?>.filled(columnsPerLine, null),
      });
      expect(card.rawTotal(FigureLine.aces), 15);
    });

    test('filledColumns counts non-null entries', () {
      final card = ScoreCard(figureScores: {
        FigureLine.aces: [7, 8, null, null, null],
        for (final l in FigureLine.values.where((l) => l != FigureLine.aces))
          l: List<int?>.filled(columnsPerLine, null),
      });
      expect(card.filledColumns(FigureLine.aces), 2);
      expect(card.filledColumns(FigureLine.kings), 0);
    });

    test('isLineComplete', () {
      final card = ScoreCard(figureScores: {
        FigureLine.aces: [7, 8, 9, 8, 9],
        for (final l in FigureLine.values.where((l) => l != FigureLine.aces))
          l: List<int?>.filled(columnsPerLine, null),
      });
      expect(card.isLineComplete(FigureLine.aces), isTrue);
      expect(card.isLineComplete(FigureLine.kings), isFalse);
    });
  });

  // -----------------------------------------------------------------------
  // Edge cases
  // -----------------------------------------------------------------------
  group('edge cases', () {
    test('MinStraight order-independent: [9, 10, J, Q, K]', () {
      final combos = detectSpecialCombinations([N, T, J, Q, K]);
      expect(combos.whereType<MinStraight>(), hasLength(1));
    });

    test('[A, A, K, K, K] → FullHouse (K=three, A=two)', () {
      final combos = detectSpecialCombinations([A, A, K, K, K]);
      expect(combos, hasLength(1));
      final fh = combos.first as FullHouse;
      expect(fh.threeFace, K);
      expect(fh.twoFace, A);
    });

    test('FiveOfAKind score values', () {
      final foak = const FiveOfAKind(DieFace.ace);
      expect(foak.score(fromHand: false), 20);
      expect(foak.score(fromHand: true), 40);
    });

    test('FiveNines score values', () {
      const fn = FiveNines();
      expect(fn.score(fromHand: false), 30);
      expect(fn.score(fromHand: true), 60);
    });

    test('all multipliers match spec', () {
      expect(FigureLine.aces.multiplier, 6);
      expect(FigureLine.kings.multiplier, 5);
      expect(FigureLine.queens.multiplier, 4);
      expect(FigureLine.jacks.multiplier, 3);
      expect(FigureLine.tens.multiplier, 2);
    });

    test('columnMinimums match spec', () {
      expect(columnMinimums, [7, 6, 6, 8, 8]);
    });

    test('FigureLine.fromDieFace round-trip', () {
      for (final line in FigureLine.values) {
        expect(FigureLine.fromDieFace(line.dieFace), line);
      }
      expect(FigureLine.fromDieFace(DieFace.nine), isNull);
    });
  });
}
