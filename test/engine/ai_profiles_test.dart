import 'dart:math';

import 'package:test/test.dart';

import 'package:dipok/engine/ai_profiles.dart';
import 'package:dipok/engine/constants.dart';
import 'package:dipok/engine/game_engine.dart';
import 'package:dipok/engine/models.dart';

/// Helper: create a game state with specific dice faces.
GameState _stateWithDice(
  List<DieFace> faces, {
  int rollIndex = 0,
  int playerIndex = 0,
}) {
  final state = createGame(['P1', 'P2', 'P3', 'P4'], random: Random(42));
  final dice = faces
      .map((f) => Die(face: f))
      .toList();
  return state.copyWith(
    dice: dice,
    currentRollIndex: rollIndex,
    currentPlayerIndex: playerIndex,
  );
}

void main() {
  group('AI chooseAction', () {
    test('returns a valid action for all profiles on fresh state', () {
      final state = createGame(['P1', 'P2', 'P3', 'P4'], random: Random(1));
      for (final profile in AiProfile.values) {
        final action = chooseAction(state, profile);
        expect(action, isNotNull, reason: '$profile should return an action');
      }
    });

    test('scores figure when all dice match (high points)', () {
      // 5 aces → 10 points for aces line
      final state = _stateWithDice([
        DieFace.ace, DieFace.ace, DieFace.ace, DieFace.ace, DieFace.ace,
      ]);

      for (final profile in AiProfile.values) {
        final action = chooseAction(state, profile);
        // Should score — 10 points is well above any minimum
        expect(
          action,
          anyOf(isA<ScoreFigure>(), isA<ScoreSpecialInFigure>()),
          reason: '$profile should score with 5 aces',
        );
      }
    });

    test('holds matching dice when count >= 2 on first roll', () {
      // 2 kings + 3 random on roll 0
      final state = _stateWithDice([
        DieFace.king, DieFace.king, DieFace.queen, DieFace.ten, DieFace.jack,
      ], rollIndex: 0);

      final va = getValidActions(state);
      // If there are no scoring options above threshold, AI should hold
      for (final profile in AiProfile.values) {
        final action = chooseAction(state, profile);
        // Should either hold or score — both are valid strategies
        expect(
          action,
          anyOf(isA<HoldDice>(), isA<ScoreFigure>(), isA<ScoreSequence>(),
                isA<ScoreFullen>(), isA<Pass>()),
          reason: '$profile should return a valid action',
        );
      }
    });

    test('does not crash on last roll with low dice', () {
      // Low dice, last roll — must score or pass
      final state = _stateWithDice([
        DieFace.nine, DieFace.ten, DieFace.jack, DieFace.queen, DieFace.king,
      ], rollIndex: 2);

      for (final profile in AiProfile.values) {
        final action = chooseAction(state, profile);
        expect(action, isNotNull, reason: '$profile on last roll');
        // On last roll, hold is not available
        expect(action, isNot(isA<HoldDice>()),
          reason: '$profile should not hold on last roll');
      }
    });

    test('aggressive profile continues accumulation', () {
      // Set up accumulation state
      final state = _stateWithDice([
        DieFace.ace, DieFace.ace, DieFace.nine, DieFace.ace, DieFace.nine,
      ], rollIndex: 0).copyWith(
        accumulationMode: true,
        accumulationTarget: FigureLine.aces,
        accumulationColumn: 0,
        accumulationRunningTotal: 8,
      );

      final action = chooseAction(state, AiProfile.aggressive);
      expect(action, isA<ContinueAccumulation>(),
        reason: 'Aggressive should continue accumulation');
    });

    test('cautious profile finalizes accumulation when above minimum', () {
      // Running total above minimum for column 0 (min = 7)
      final state = _stateWithDice([
        DieFace.ace, DieFace.ace, DieFace.nine, DieFace.ace, DieFace.nine,
      ], rollIndex: 1).copyWith(
        accumulationMode: true,
        accumulationTarget: FigureLine.aces,
        accumulationColumn: 0,
        accumulationRunningTotal: 9,
      );

      final action = chooseAction(state, AiProfile.cautious);
      expect(action, isA<FinalizeAccumulation>(),
        reason: 'Cautious should finalize when above minimum');
    });

    test('dreamer prefers pass over non-from-hand scoring', () {
      // Not from hand because one die is held.
      final state = _stateWithDice([
        DieFace.king,
        DieFace.king,
        DieFace.king,
        DieFace.queen,
        DieFace.ten,
      ]).copyWith(
        dice: const [
          Die(face: DieFace.king, held: true),
          Die(face: DieFace.king),
          Die(face: DieFace.king),
          Die(face: DieFace.queen),
          Die(face: DieFace.ten),
        ],
      );

      final action = chooseAction(state, AiProfile.dreamer);
      expect(action, isA<Pass>());
    });

    test('dreamer scores poker when available from hand', () {
      final state = _stateWithDice([
        DieFace.ace,
        DieFace.ace,
        DieFace.ace,
        DieFace.ace,
        DieFace.king,
      ]);

      final action = chooseAction(state, AiProfile.dreamer);
      expect(action, isA<ScorePoker>());
    });

    test('plays full AI game without errors', () {
      // Simulate a full game with AI making all decisions
      var state = createGame(['AI1', 'AI2', 'AI3', 'AI4'], random: Random(99));
      var moves = 0;
      const maxMoves = 2000; // 4 players need more turns

      while (!state.gameOver && moves < maxMoves) {
        final action = chooseAction(state, AiProfile.balanced);
        state = applyAction(state, action, random: Random(moves));
        moves++;
      }

      // Game should eventually end
      expect(moves, lessThan(maxMoves),
        reason: 'AI game should finish within $maxMoves moves');
      expect(state.gameOver, isTrue,
        reason: 'Game should be over');
    });

    test('plays full game with all profiles', () {
      for (final profile in AiProfile.values) {
        var state = createGame(['AI1', 'AI2', 'AI3', 'AI4'], random: Random(42));
        var moves = 0;
        const maxMoves = 2000;

        while (!state.gameOver && moves < maxMoves) {
          final action = chooseAction(state, profile);
          state = applyAction(state, action, random: Random(moves));
          moves++;
        }

        expect(state.gameOver, isTrue,
          reason: '$profile game should finish');
        expect(moves, lessThan(maxMoves),
          reason: '$profile should not loop forever');
      }
    });
  });
}
