/// Unit tests for the Dipok game engine (turn flow, actions, accumulation).
///
/// Uses a mock Random for deterministic dice rolls.

import 'dart:math';

import 'package:test/test.dart';
import 'package:dipok/engine/constants.dart';
import 'package:dipok/engine/models.dart';
import 'package:dipok/engine/game_engine.dart';

/// A deterministic Random that returns faces in a predefined sequence.
class MockRandom implements Random {
  final List<int> _values;
  int _index = 0;

  MockRandom(this._values);

  @override
  int nextInt(int max) {
    final v = _values[_index % _values.length] % max;
    _index++;
    return v;
  }

  @override
  double nextDouble() => 0.5;

  @override
  bool nextBool() => false;
}

// DieFace indices: ace=0, king=1, queen=2, jack=3, ten=4, nine=5

/// Create a MockRandom that produces a specific set of 5 DieFace values.
MockRandom facesRng(List<int> faceIndices) {
  // Each die roll calls nextInt(6), so we supply values that map to the
  // desired indices. We repeat to cover subsequent rolls.
  return MockRandom([...faceIndices, ...faceIndices, ...faceIndices, ...faceIndices]);
}

/// Helper: create a game state at a specific point with known dice.
GameState _makeState({
  List<List<int?>>? acesColumns,
  int playerIndex = 0,
  int rollIndex = 0,
  List<int> diceIndices = const [0, 0, 0, 5, 5], // A,A,A,9,9
}) {
  final rng = facesRng(diceIndices);
  final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

  if (acesColumns != null) {
    // Replace P1's aces line
    final card = state.players[0].scoreCard;
    final newScores = {
      for (final line in FigureLine.values)
        line: List<int?>.from(card.figureScores[line]!),
    };
    newScores[FigureLine.aces] = acesColumns[0];
    final newCard = ScoreCard(
      figureScores: newScores,
      sequenceEntries: List.of(card.sequenceEntries),
      fullenEntries: List.of(card.fullenEntries),
      pokerEntries: List.of(card.pokerEntries),
    );
    final newPlayers = [
      state.players[0].copyWith(scoreCard: newCard),
      ...state.players.sublist(1),
    ];
    return state.copyWith(players: newPlayers, currentRollIndex: rollIndex);
  }

  return state.copyWith(currentRollIndex: rollIndex);
}

void main() {
  // -----------------------------------------------------------------------
  // Game creation
  // -----------------------------------------------------------------------
  group('createGame', () {
    test('creates 4 players with empty score cards', () {
      final rng = facesRng([0, 1, 2, 3, 4]);
      final state = createGame(['A', 'B', 'C', 'D'], random: rng);

      expect(state.players, hasLength(4));
      expect(state.players[0].name, 'A');
      expect(state.players[3].name, 'D');
      expect(state.currentPlayerIndex, 0);
      expect(state.currentRollIndex, 0);
      expect(state.dice, hasLength(5));
      expect(state.gameOver, isFalse);
      expect(state.closedLines, isEmpty);
      expect(state.scoredThisTurn, isEmpty);
    });

    test('all score cards are empty', () {
      final rng = facesRng([0, 0, 0, 0, 0]);
      final state = createGame(['A', 'B', 'C', 'D'], random: rng);
      for (final p in state.players) {
        for (final line in FigureLine.values) {
          expect(p.scoreCard.filledColumns(line), 0);
        }
      }
    });
  });

  // -----------------------------------------------------------------------
  // ScoreFigure action
  // -----------------------------------------------------------------------
  group('ScoreFigure', () {
    test('scores in next open column and advances', () {
      // A,A,K,9,9 → not all ace/nine (K present) → normal scoring
      final rng = facesRng([0, 0, 1, 5, 5]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);
      // Fill col 0 so we score in col 1 (min 6); points = 2×2+2×1 = 6
      final card = state.players[0].scoreCard;
      final newScores = {
        for (final line in FigureLine.values)
          line: List<int?>.from(card.figureScores[line]!),
      };
      newScores[FigureLine.aces] = [7, null, null, null, null];
      final newCard = ScoreCard(figureScores: newScores);
      state = state.copyWith(
        players: [
          state.players[0].copyWith(scoreCard: newCard),
          ...state.players.sublist(1),
        ],
      );

      final next = applyAction(
        state,
        const ScoreFigure(line: FigureLine.aces, points: 6),
        random: rng,
      );

      expect(next.players[0].scoreCard.figureScores[FigureLine.aces]![1], 6);
      expect(next.scoredThisTurn, contains(FigureLine.aces));
      expect(next.currentRollIndex, 1); // advanced to roll 1
    });

    test('rejects score below column minimum', () {
      final rng = facesRng([0, 0, 5, 5, 5]);
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      expect(
        () => applyAction(
          state,
          const ScoreFigure(line: FigureLine.aces, points: 5),
          random: rng,
        ),
        throwsStateError,
      );
    });

    test('rejects scoring same line twice in a turn', () {
      final rng = facesRng([0, 0, 0, 5, 5]);
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      final s1 = applyAction(
        state,
        const ScoreFigure(line: FigureLine.aces, points: 8),
        random: rng,
      );

      expect(
        () => applyAction(
          s1,
          const ScoreFigure(line: FigureLine.aces, points: 8),
          random: rng,
        ),
        throwsStateError,
      );
    });

    test('scoring on last roll ends turn, advances to next player', () {
      final rng = facesRng([0, 0, 0, 5, 5]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);
      state = state.copyWith(currentRollIndex: 2); // last roll

      final next = applyAction(
        state,
        const ScoreFigure(line: FigureLine.aces, points: 8),
        random: rng,
      );

      expect(next.currentPlayerIndex, 1); // P2's turn
      expect(next.currentRollIndex, 0);
      expect(next.scoredThisTurn, isEmpty);
    });
  });

  // -----------------------------------------------------------------------
  // ScoreSequence / ScoreFullen / ScorePoker
  // -----------------------------------------------------------------------
  group('Special scoring actions', () {
    test('ScoreSequence adds entry', () {
      final rng = facesRng([0, 1, 2, 3, 4]); // A,K,Q,J,10 = max straight
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      final next = applyAction(
        state,
        const ScoreSequence(points: 60, fromHand: true),
        random: rng,
      );

      expect(next.players[0].scoreCard.sequenceEntries, hasLength(1));
      expect(next.players[0].scoreCard.sequenceEntries.first.score, 60);
    });

    test('ScoreFullen adds entry', () {
      final rng = facesRng([0, 0, 0, 1, 1]); // A,A,A,K,K
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      final next = applyAction(
        state,
        const ScoreFullen(points: 15, fromHand: false),
        random: rng,
      );

      expect(next.players[0].scoreCard.fullenEntries, hasLength(1));
      expect(next.players[0].scoreCard.fullenEntries.first.score, 15);
    });

    test('ScorePoker adds entry', () {
      final rng = facesRng([1, 1, 1, 1, 2]); // K,K,K,K,Q
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      final next = applyAction(
        state,
        const ScorePoker(points: 100),
        random: rng,
      );

      expect(next.players[0].scoreCard.pokerEntries, hasLength(1));
      expect(next.players[0].scoreCard.pokerEntries.first.score, 100);
    });
  });

  // -----------------------------------------------------------------------
  // HoldDice
  // -----------------------------------------------------------------------
  group('HoldDice', () {
    test('re-rolls unheld dice, keeps held', () {
      final rng = facesRng([0, 0, 0, 0, 0]); // all aces initially
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      expect(state.dice[0].face, DieFace.ace);

      final next = applyAction(
        state,
        const HoldDice(diceIndicesToHold: {0, 1}),
        random: facesRng([5, 5, 5, 5, 5]), // re-rolled dice become nines
      );

      expect(next.dice[0].face, DieFace.ace); // held
      expect(next.dice[0].held, isTrue);
      expect(next.dice[1].held, isTrue);
      expect(next.dice[2].face, DieFace.nine); // re-rolled
      expect(next.currentRollIndex, 1);
    });

    test('cannot hold on last roll', () {
      final rng = facesRng([0, 0, 0, 0, 0]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);
      state = state.copyWith(currentRollIndex: 2);

      expect(
        () => applyAction(
          state,
          const HoldDice(diceIndicesToHold: {0}),
          random: rng,
        ),
        throwsStateError,
      );
    });
  });

  // -----------------------------------------------------------------------
  // Pass
  // -----------------------------------------------------------------------
  group('Pass', () {
    test('on non-last roll: advances to next roll', () {
      final rng = facesRng([0, 0, 0, 0, 0]);
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      final next = applyAction(state, const Pass(), random: rng);
      expect(next.currentRollIndex, 1);
      expect(next.currentPlayerIndex, 0); // same player
    });

    test('on last roll: ends turn, moves to next player', () {
      final rng = facesRng([0, 0, 0, 0, 0]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);
      state = state.copyWith(currentRollIndex: 2);

      final next = applyAction(state, const Pass(), random: rng);
      expect(next.currentPlayerIndex, 1);
      expect(next.currentRollIndex, 0);
    });
  });

  // -----------------------------------------------------------------------
  // Accumulation mode (new: triggered when all 5 dice match figure/9)
  // -----------------------------------------------------------------------
  group('Accumulation mode', () {
    test('scoring when all 5 dice match enters accumulation mode', () {
      // Dice: A,A,A,9,9 → all are ace or nine → triggers accumulation
      final rng = facesRng([0, 0, 0, 5, 5]);
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);
      // Aces points = 3×2 + 2×1 = 8, min col 0 = 7 → scoreable
      final next = applyAction(
        state,
        const ScoreFigure(line: FigureLine.aces, points: 8),
        random: rng,
      );

      expect(next.accumulationMode, isTrue);
      expect(next.accumulationTarget, FigureLine.aces);
      expect(next.accumulationColumn, 0);
      expect(next.accumulationRunningTotal, 8);
      // Still roll 0 — no auto-advance, waiting for player to continue or finalize
      expect(next.currentRollIndex, 0);
    });

    test('scoring on last roll does NOT enter accumulation', () {
      // All dice match, but it's roll index 2 (last) — just scores normally
      final rng = facesRng([0, 0, 0, 5, 5]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);
      state = state.copyWith(currentRollIndex: 2);

      final next = applyAction(
        state,
        const ScoreFigure(line: FigureLine.aces, points: 8),
        random: rng,
      );

      // Should NOT be in accumulation; score registered, turn ended
      expect(next.accumulationMode, isFalse);
      expect(next.players[0].scoreCard.figureScores[FigureLine.aces]![0], 8);
      expect(next.currentPlayerIndex, 1); // next player
    });

    test('scoring when NOT all 5 dice match does normal scoring', () {
      // Dice: A,A,K,9,9 → not all ace/nine (K present)
      final rng = facesRng([0, 0, 1, 5, 5]);
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);
      // Aces points = 2×2 + 2×1 = 6, but min col 0 = 7 → below minimum
      // Let's use a state where col 0 is already filled (min 6 for col 1)
      // Actually, 6 < 7, so can't score. Let me use queens instead.
      // Queens: 0 queens + 2 nines = 2 → too low.
      // Let's just use 3A + 2×9 in a column with min 6
      final state2 = _makeState(
        acesColumns: [[7, null, null, null, null]],
        diceIndices: [0, 0, 1, 5, 5], // A,A,K,9,9 → aces pts = 2×2+2×1=6
      );

      final next = applyAction(
        state2,
        const ScoreFigure(line: FigureLine.aces, points: 6),
        random: rng,
      );

      // Normal score — not accumulation (K is not ace or nine)
      expect(next.accumulationMode, isFalse);
      expect(next.players[0].scoreCard.figureScores[FigureLine.aces]![1], 6);
    });

    test('continue accumulation re-rolls all 5 and adds points', () {
      // Roll 1: A,A,A,9,9 → 8pts, enters accumulation
      final rng = facesRng([0, 0, 0, 5, 5]);
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      var s = applyAction(
        state,
        const ScoreFigure(line: FigureLine.aces, points: 8),
        random: rng,
      );
      expect(s.accumulationMode, isTrue);
      expect(s.accumulationRunningTotal, 8);

      // Continue accumulation → re-rolls all 5 dice
      // New dice: A,A,9,K,A → aces pts = 3×2 + 1×1 = 7
      final rng2 = facesRng([0, 0, 5, 1, 0]);
      s = applyAction(s, const ContinueAccumulation(), random: rng2);

      expect(s.accumulationRunningTotal, 15); // 8 + 7
      expect(s.currentRollIndex, 1);
      expect(s.accumulationMode, isTrue);
    });

    test('hold in accumulation adds to running total', () {
      // Start in accumulation: A,A,A,9,9 → 8pts
      final rng = facesRng([0, 0, 0, 5, 5]);
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      var s = applyAction(
        state,
        const ScoreFigure(line: FigureLine.aces, points: 8),
        random: rng,
      );
      expect(s.accumulationRunningTotal, 8);

      // After continue accumulation, dice may not all match → hold some
      final rng2 = facesRng([0, 0, 5, 1, 0]); // A,A,9,K,A → not all match
      s = applyAction(s, const ContinueAccumulation(), random: rng2);
      expect(s.accumulationRunningTotal, 15); // 8+7

      // Now hold A,A,A (indices 0,1,4), re-roll index 2(9) and 3(K)
      final rng3 = facesRng([0, 0, 0, 0, 0]); // re-rolled become aces
      s = applyAction(
        s,
        const HoldDice(diceIndicesToHold: {0, 1, 4}),
        random: rng3,
      );

      // New dice: A(held),A(held),A(rolled),A(rolled),A(held) → 5×2 = 10
      expect(s.accumulationRunningTotal, 25); // 15+10
      expect(s.currentRollIndex, 2);
    });

    test('finalize accumulation registers score if above minimum', () {
      // Enter accumulation: A,A,A,9,9 → 8pts
      final rng = facesRng([0, 0, 0, 5, 5]);
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      var s = applyAction(
        state,
        const ScoreFigure(line: FigureLine.aces, points: 8),
        random: rng,
      );

      // Finalize with 8pts >= 7 (col 0 min)
      final next = applyAction(s, const FinalizeAccumulation(), random: rng);

      expect(next.players[0].scoreCard.figureScores[FigureLine.aces]![0], 8);
      expect(next.currentPlayerIndex, 1); // turn ended
      expect(next.accumulationMode, isFalse);
    });

    test('finalize accumulation rejects if below minimum', () {
      // Enter accumulation manually with low score by crafting state
      final rng = facesRng([0, 0, 0, 5, 5]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      // Force accumulation state with running total = 3 (< 7)
      state = state.copyWith(
        accumulationMode: true,
        accumulationTarget: FigureLine.aces,
        accumulationColumn: 0,
        accumulationRunningTotal: 3,
      );

      final next = applyAction(state, const FinalizeAccumulation(), random: rng);

      expect(next.players[0].scoreCard.figureScores[FigureLine.aces]![0], isNull);
      expect(next.currentPlayerIndex, 1);
      expect(next.accumulationMode, isFalse);
    });

    test('pass during accumulation auto-finalizes', () {
      final rng = facesRng([0, 0, 0, 5, 5]);
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      var s = applyAction(
        state,
        const ScoreFigure(line: FigureLine.aces, points: 8),
        random: rng,
      );
      expect(s.accumulationMode, isTrue);

      // Pass = finalize
      final next = applyAction(s, const Pass(), random: rng);

      expect(next.players[0].scoreCard.figureScores[FigureLine.aces]![0], 8);
      expect(next.currentPlayerIndex, 1);
      expect(next.accumulationMode, isFalse);
    });

    test('cannot score other lines during accumulation', () {
      final rng = facesRng([0, 0, 0, 5, 5]);
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      final s = applyAction(
        state,
        const ScoreFigure(line: FigureLine.aces, points: 8),
        random: rng,
      );

      expect(
        () => applyAction(
          s,
          const ScoreFigure(line: FigureLine.kings, points: 8),
          random: rng,
        ),
        throwsStateError,
      );
      expect(
        () => applyAction(
          s,
          const ScoreSequence(points: 30, fromHand: true),
          random: rng,
        ),
        throwsStateError,
      );
    });

    test('full accumulation flow: enter → continue → hold → finalize', () {
      // Roll 1: all aces/9 → enter accumulation
      final rng1 = facesRng([0, 0, 0, 5, 5]); // A,A,A,9,9 → 8pts
      var s = createGame(['P1', 'P2', 'P3', 'P4'], random: rng1);

      s = applyAction(
        s,
        const ScoreFigure(line: FigureLine.aces, points: 8),
        random: rng1,
      );
      expect(s.accumulationRunningTotal, 8);
      expect(s.currentRollIndex, 0);

      // Continue: re-roll all 5 → A,9,K,A,9 → 2×2+2×1 = 6
      final rng2 = facesRng([0, 5, 1, 0, 5]);
      s = applyAction(s, const ContinueAccumulation(), random: rng2);
      expect(s.accumulationRunningTotal, 14); // 8+6
      expect(s.currentRollIndex, 1);

      // Hold aces (0,3), re-roll rest → all aces
      final rng3 = facesRng([0, 0, 0, 0, 0]);
      s = applyAction(
        s,
        const HoldDice(diceIndicesToHold: {0, 3}),
        random: rng3,
      );
      // Dice: A(held),A(roll),A(roll),A(held),A(roll) → 5×2 = 10
      expect(s.accumulationRunningTotal, 24); // 14+10
      expect(s.currentRollIndex, 2);

      // Finalize → 24 >= 7 → registered
      final next = applyAction(s, const FinalizeAccumulation(), random: rng3);
      expect(next.players[0].scoreCard.figureScores[FigureLine.aces]![0], 24);
      expect(next.currentPlayerIndex, 1);
    });
  });

  // -----------------------------------------------------------------------
  // Game over
  // -----------------------------------------------------------------------
  group('Game over', () {
    test('game ends when action closes the 4th line', () {
      // Set up: 3 lines already closed, P1 about to close the 4th
      final rng = facesRng([0, 0, 0, 0, 0]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      // Give P1 aces line [7,8,9,8,null] → one column left
      final card = state.players[0].scoreCard;
      final newScores = {
        for (final line in FigureLine.values)
          line: List<int?>.from(card.figureScores[line]!),
      };
      newScores[FigureLine.aces] = [7, 8, 9, 8, null];
      final newCard = ScoreCard(figureScores: newScores);
      final newPlayers = [
        state.players[0].copyWith(scoreCard: newCard),
        ...state.players.sublist(1),
      ];

      state = state.copyWith(
        players: newPlayers,
        closedLines: {FigureLine.kings, FigureLine.queens, FigureLine.jacks},
        closedBy: {
          FigureLine.kings: 1,
          FigureLine.queens: 2,
          FigureLine.jacks: 3,
        },
        currentRollIndex: 2, // last roll so scoring ends the turn
      );

      // Score aces column 4 (min 8) → closes aces → 4th line → game over
      final next = applyAction(
        state,
        const ScoreFigure(line: FigureLine.aces, points: 9),
        random: rng,
      );

      expect(next.closedLines, hasLength(4));
      expect(next.gameOver, isTrue);
    });

    test('cannot act after game is over', () {
      final rng = facesRng([0, 0, 0, 0, 0]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);
      state = state.copyWith(gameOver: true);

      expect(
        () => applyAction(state, const Pass(), random: rng),
        throwsStateError,
      );
    });
  });

  // -----------------------------------------------------------------------
  // Turn cycling
  // -----------------------------------------------------------------------
  group('Turn cycling', () {
    test('players rotate P1→P2→P3→P4→P1', () {
      final rng = facesRng([0, 0, 0, 0, 0]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      // Each player passes all 3 rolls
      for (var p = 0; p < 4; p++) {
        expect(state.currentPlayerIndex, p);
        for (var r = 0; r < 2; r++) {
          state = applyAction(state, const Pass(), random: rng);
        }
        // Last pass ends the turn
        state = applyAction(state, const Pass(), random: rng);
      }

      // Back to P1
      expect(state.currentPlayerIndex, 0);
    });

    test('scoredThisTurn resets between turns', () {
      final rng = facesRng([0, 0, 0, 5, 5]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      // P1 scores aces
      state = applyAction(
        state,
        const ScoreFigure(line: FigureLine.aces, points: 8),
        random: rng,
      );
      expect(state.scoredThisTurn, contains(FigureLine.aces));

      // Pass remaining rolls to end P1's turn (roll 1→2, then 2→end)
      state = applyAction(state, const Pass(), random: rng);
      state = applyAction(state, const Pass(), random: rng);
      // Now it's P2's turn
      expect(state.currentPlayerIndex, 1);
      expect(state.scoredThisTurn, isEmpty);
    });
  });

  // -----------------------------------------------------------------------
  // fromHand detection
  // -----------------------------------------------------------------------
  group('fromHand', () {
    test('first roll is always fromHand', () {
      final rng = facesRng([0, 0, 0, 0, 0]);
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);
      expect(state.isFromHand, isTrue);
    });

    test('after scoring (pick up all dice), next roll is fromHand', () {
      // A,A,K,9,9 → not all ace/nine (K present) → normal scoring
      final rng = facesRng([0, 0, 1, 5, 5]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);
      // Move to col 1 (min 6) so 6 pts is enough
      final card = state.players[0].scoreCard;
      final newScores = {
        for (final line in FigureLine.values)
          line: List<int?>.from(card.figureScores[line]!),
      };
      newScores[FigureLine.aces] = [7, null, null, null, null];
      final newCard = ScoreCard(figureScores: newScores);
      state = state.copyWith(
        players: [
          state.players[0].copyWith(scoreCard: newCard),
          ...state.players.sublist(1),
        ],
      );

      final next = applyAction(
        state,
        const ScoreFigure(line: FigureLine.aces, points: 6),
        random: rng,
      );

      // All dice were re-rolled after scoring → fromHand
      expect(next.isFromHand, isTrue);
    });

    test('after holding dice, NOT fromHand', () {
      final rng = facesRng([0, 0, 0, 0, 0]);
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      final next = applyAction(
        state,
        const HoldDice(diceIndicesToHold: {0, 1}),
        random: rng,
      );

      expect(next.isFromHand, isFalse);
      expect(next.dice[0].held, isTrue);
    });
  });

  // -----------------------------------------------------------------------
  // Line closing
  // -----------------------------------------------------------------------
  group('Line closing', () {
    test('closing a line prevents further scoring in it', () {
      final rng = facesRng([0, 0, 0, 0, 0]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);
      state = state.copyWith(
        closedLines: {FigureLine.aces},
        closedBy: {FigureLine.aces: 0},
      );

      expect(
        () => applyAction(
          state,
          const ScoreFigure(line: FigureLine.aces, points: 10),
          random: rng,
        ),
        throwsStateError,
      );
    });

    test('closedBy tracks who closed each line', () {
      final rng = facesRng([0, 0, 0, 0, 0]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      // Give P1 aces nearly complete
      final card = state.players[0].scoreCard;
      final newScores = {
        for (final line in FigureLine.values)
          line: List<int?>.from(card.figureScores[line]!),
      };
      newScores[FigureLine.aces] = [7, 8, 9, 8, null];
      final newCard = ScoreCard(figureScores: newScores);
      state = state.copyWith(
        players: [
          state.players[0].copyWith(scoreCard: newCard),
          ...state.players.sublist(1),
        ],
        currentRollIndex: 2, // last roll → no accumulation trigger
      );

      final next = applyAction(
        state,
        const ScoreFigure(line: FigureLine.aces, points: 9),
        random: rng,
      );

      expect(next.closedLines, contains(FigureLine.aces));
      expect(next.closedBy[FigureLine.aces], 0); // P1 closed it
    });
  });

  // -----------------------------------------------------------------------
  // getValidActions
  // -----------------------------------------------------------------------
  group('getValidActions', () {
    test('game over → empty', () {
      final rng = facesRng([0, 0, 0, 0, 0]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);
      state = state.copyWith(gameOver: true);

      final va = getValidActions(state);
      expect(va.isEmpty, isTrue);
      expect(va.toList(), isEmpty);
    });

    test('initial roll with all aces → aces scoring available', () {
      final rng = facesRng([0, 0, 0, 0, 0]); // 5 aces → 10 pts
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      final va = getValidActions(state);
      expect(va.figureScoring.any((a) => a.line == FigureLine.aces), isTrue);
      final acesAction =
          va.figureScoring.firstWhere((a) => a.line == FigureLine.aces);
      expect(acesAction.points, 10); // 5×2 = 10
    });

    test('five aces → includes five-of-a-kind in specialInFigure', () {
      final rng = facesRng([0, 0, 0, 0, 0]);
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      final va = getValidActions(state);
      // Five-of-a-kind can be inscribed in any open figure line
      expect(va.specialInFigure, isNotEmpty);
      expect(
        va.specialInFigure.length,
        FigureLine.values.length, // all 5 lines open
      );
      expect(va.specialInFigure.first.points, 40); // fromHand = true
    });

    test('five aces → also detected as fullen', () {
      final rng = facesRng([0, 0, 0, 0, 0]);
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      final va = getValidActions(state);
      expect(va.fullens, hasLength(1));
      expect(va.fullens.first.points, 30); // fromHand fullen
    });

    test('max straight → sequence available', () {
      final rng = facesRng([0, 1, 2, 3, 4]); // A,K,Q,J,10
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      final va = getValidActions(state);
      expect(va.sequences, hasLength(1));
      expect(va.sequences.first.points, 60); // max straight from hand
      expect(va.sequences.first.fromHand, isTrue);
    });

    test('four aces + king from hand → royal poker', () {
      final rng = facesRng([0, 0, 0, 0, 1]); // A,A,A,A,K
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      final va = getValidActions(state);
      expect(va.pokers, hasLength(1));
      expect(va.pokers.first.points, 200); // royal poker from hand
    });

    test('poker NOT from hand → not offered', () {
      final rng = facesRng([1, 1, 1, 1, 2]); // K,K,K,K,Q
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);
      // Simulate held dice (not fromHand)
      final heldDice = [
        Die(face: DieFace.king, held: true),
        Die(face: DieFace.king),
        Die(face: DieFace.king),
        Die(face: DieFace.king),
        Die(face: DieFace.queen),
      ];
      state = state.copyWith(dice: heldDice);

      final va = getValidActions(state);
      expect(va.pokers, isEmpty); // poker gives 0 if not from hand
    });

    test('canHold true on roll 0, false on roll 2', () {
      final rng = facesRng([0, 0, 0, 0, 0]);
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      expect(getValidActions(state).canHold, isTrue);
      expect(
        getValidActions(state.copyWith(currentRollIndex: 2)).canHold,
        isFalse,
      );
    });

    test('canPass always true while game active', () {
      final rng = facesRng([0, 0, 0, 0, 0]);
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      expect(getValidActions(state).canPass, isTrue);
      expect(
        getValidActions(state.copyWith(currentRollIndex: 2)).canPass,
        isTrue,
      );
    });

    test('closed line not offered for scoring', () {
      final rng = facesRng([0, 0, 0, 0, 0]); // all aces
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);
      state = state.copyWith(
        closedLines: {FigureLine.aces},
        closedBy: {FigureLine.aces: 1},
      );

      final va = getValidActions(state);
      expect(va.figureScoring.any((a) => a.line == FigureLine.aces), isFalse);
    });

    test('scoredThisTurn line not offered again', () {
      final rng = facesRng([0, 0, 0, 0, 0]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);
      state = state.copyWith(scoredThisTurn: {FigureLine.aces});

      final va = getValidActions(state);
      expect(va.figureScoring.any((a) => a.line == FigureLine.aces), isFalse);
    });

    test('points below column minimum → not offered', () {
      // A,K,Q,J,10 → aces points = 1×2 = 2 (below min 7 for col 0)
      final rng = facesRng([0, 1, 2, 3, 4]);
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      final va = getValidActions(state);
      expect(va.figureScoring.any((a) => a.line == FigureLine.aces), isFalse);
    });

    test('accumulation mode after all-match score → canContinue + canFinalize', () {
      // A,A,A,9,9 → all ace/nine → scoring enters accumulation
      final rng = facesRng([0, 0, 0, 5, 5]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);
      state = applyAction(
        state,
        const ScoreFigure(line: FigureLine.aces, points: 8),
        random: rng,
      );

      final va = getValidActions(state);
      expect(va.figureScoring, isEmpty);
      expect(va.specialInFigure, isEmpty);
      expect(va.sequences, isEmpty);
      expect(va.fullens, isEmpty);
      expect(va.pokers, isEmpty);
      expect(va.canContinueAccumulation, isTrue); // all 5 still match
      expect(va.canHold, isFalse); // canHold false when all match
      expect(va.canPass, isTrue);
      expect(va.canFinalize, isTrue);
    });

    test('accumulation mode after continue (not all match) → hold/finalize, no continue', () {
      final rng = facesRng([0, 0, 0, 5, 5]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);
      state = applyAction(
        state,
        const ScoreFigure(line: FigureLine.aces, points: 8),
        random: rng,
      );

      // Continue → new dice not all ace/9
      final rng2 = facesRng([0, 0, 1, 5, 0]); // A,A,K,9,A → K breaks match
      state = applyAction(state, const ContinueAccumulation(), random: rng2);

      final va = getValidActions(state);
      expect(va.canContinueAccumulation, isFalse);
      expect(va.canHold, isTrue);
      expect(va.canFinalize, isTrue);
      expect(va.canPass, isTrue);
    });

    test('toList returns all concrete actions', () {
      final rng = facesRng([0, 0, 0, 0, 0]); // all aces
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      final va = getValidActions(state);
      final list = va.toList();
      // Should contain: figure actions + specials + fullen + accumulations + pass
      expect(list, isNotEmpty);
      expect(list.whereType<Pass>(), hasLength(1));
    });

    test('full figure line → not offered for scoring', () {
      final rng = facesRng([0, 0, 0, 0, 0]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      // Fill P1's aces line completely
      final card = state.players[0].scoreCard;
      final newScores = {
        for (final line in FigureLine.values)
          line: List<int?>.from(card.figureScores[line]!),
      };
      newScores[FigureLine.aces] = [7, 8, 9, 8, 8];
      final newCard = ScoreCard(figureScores: newScores);
      state = state.copyWith(
        players: [
          state.players[0].copyWith(scoreCard: newCard),
          ...state.players.sublist(1),
        ],
      );

      final va = getValidActions(state);
      expect(va.figureScoring.any((a) => a.line == FigureLine.aces), isFalse);
    });
  });

  // -----------------------------------------------------------------------
  // Regression tests — bugs detected during play
  // -----------------------------------------------------------------------
  group('Regression', () {
    test('Dice are all unheld after scoring and re-rolling (HOLD badge bug)', () {
      // The actual bug was in GameController._selectedDice not clearing,
      // but we verify the engine always produces unheld dice after scoring.
      final rng = MockRandom([0,0,0,5,5, 1,2, 0,0,0,0,0]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      // Hold first 3 dice (aces)
      state = applyAction(state, const HoldDice(diceIndicesToHold: {0, 1, 2}), random: rng);
      expect(state.dice.where((d) => d.held).length, 3);

      // Score kings (re-roll dice 3,4 gave K,Q → kings line: 1×2=2, too low for col0)
      // Instead, score any available figure line via valid actions
      final va = getValidActions(state);
      if (va.figureScoring.isNotEmpty) {
        state = applyAction(state, va.figureScoring.first, random: rng);
        // After scoring, dice are re-rolled → all unheld
        expect(state.dice.every((d) => !d.held), isTrue);
      } else {
        // Pass on last roll → turn ends → next player's dice are unheld
        state = state.copyWith(currentRollIndex: rollsPerTurn - 1);
        state = applyAction(state, const Pass(), random: rng);
        expect(state.dice.every((d) => !d.held), isTrue);
      }
    });

    test('Special line (sequences) closes after 5 entries', () {
      final rng = facesRng([0, 1, 2, 3, 4]); // A,K,Q,J,10 = max straight
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      // Give P1 four sequence entries already
      final card = state.players[0].scoreCard;
      final newCard = ScoreCard(
        figureScores: _copyScores(card.figureScores),
        sequenceEntries: [
          for (var i = 0; i < 4; i++)
            const SpecialEntry(score: 30, fromHand: true),
        ],
        fullenEntries: List.of(card.fullenEntries),
        pokerEntries: List.of(card.pokerEntries),
      );
      state = state.copyWith(
        players: [
          state.players[0].copyWith(scoreCard: newCard),
          ...state.players.sublist(1),
        ],
      );

      // Score the 5th sequence — line should close
      state = applyAction(
        state,
        const ScoreSequence(points: 60, fromHand: true),
        random: rng,
      );
      expect(state.closedSpecialLines.contains(SpecialLine.sequences), isTrue);
    });

    test('Closed special line blocks other players from scoring', () {
      final rng = facesRng([0, 1, 2, 3, 4]); // max straight
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      // Pre-close the sequence line
      state = state.copyWith(
        closedSpecialLines: {SpecialLine.sequences},
        closedSpecialBy: {SpecialLine.sequences: 0},
      );

      // Even though P1 has a straight, sequences should not be offered
      final va = getValidActions(state);
      expect(va.sequences, isEmpty);
    });

    test('Special line closures count toward game over', () {
      final rng = facesRng([0, 0, 0, 5, 5]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      // Close 2 figure lines + 2 special lines = 4 total → game over
      // Set to last roll so Pass triggers _endTurn
      state = state.copyWith(
        closedLines: {FigureLine.aces, FigureLine.kings},
        closedSpecialLines: {SpecialLine.sequences, SpecialLine.fullens},
        currentRollIndex: rollsPerTurn - 1,
      );

      // End turn should trigger game over
      state = applyAction(state, const Pass(), random: rng);
      expect(state.gameOver, isTrue);
    });

    test('Fullen line closes after 5 entries', () {
      // 3 aces + 2 kings = full house
      final rng = facesRng([0, 0, 0, 1, 1]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      final card = state.players[0].scoreCard;
      final newCard = ScoreCard(
        figureScores: _copyScores(card.figureScores),
        sequenceEntries: List.of(card.sequenceEntries),
        fullenEntries: [
          for (var i = 0; i < 4; i++)
            const SpecialEntry(score: 30, fromHand: true),
        ],
        pokerEntries: List.of(card.pokerEntries),
      );
      state = state.copyWith(
        players: [
          state.players[0].copyWith(scoreCard: newCard),
          ...state.players.sublist(1),
        ],
      );

      state = applyAction(
        state,
        const ScoreFullen(points: 30, fromHand: true),
        random: rng,
      );
      expect(state.closedSpecialLines.contains(SpecialLine.fullens), isTrue);
    });

    test('Poker line closes after 5 entries', () {
      // 4 kings + 1 ace = poker (from hand)
      final rng = facesRng([1, 1, 1, 1, 0]);
      var state = createGame(['P1', 'P2', 'P3', 'P4'], random: rng);

      final card = state.players[0].scoreCard;
      final newCard = ScoreCard(
        figureScores: _copyScores(card.figureScores),
        sequenceEntries: List.of(card.sequenceEntries),
        fullenEntries: List.of(card.fullenEntries),
        pokerEntries: [
          for (var i = 0; i < 4; i++)
            const SpecialEntry(score: 100, fromHand: true),
        ],
      );
      state = state.copyWith(
        players: [
          state.players[0].copyWith(scoreCard: newCard),
          ...state.players.sublist(1),
        ],
      );

      state = applyAction(
        state,
        const ScorePoker(points: 100),
        random: rng,
      );
      expect(state.closedSpecialLines.contains(SpecialLine.poker), isTrue);
    });
  });
}

Map<FigureLine, List<int?>> _copyScores(Map<FigureLine, List<int?>> original) {
  return {
    for (final entry in original.entries)
      entry.key: List<int?>.from(entry.value),
  };
}
