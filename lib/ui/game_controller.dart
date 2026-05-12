/// Game controller — bridges the pure engine with Flutter's ChangeNotifier.
///
/// Wraps [GameState] and exposes methods that call [applyAction],
/// then notify listeners so the UI rebuilds.
///
/// AI players are configured via [aiProfiles]. When the current player
/// has an AI profile, their turn is played automatically with a short delay
/// between actions so the user can follow the play.

import 'dart:math';

import 'package:flutter/foundation.dart';

import '../engine/ai_profiles.dart';
import '../engine/game_engine.dart';
import '../engine/models.dart';

class GameController extends ChangeNotifier {
  GameState _state;
  final Random _rng;

  /// Map of player index → AI profile. Human players are absent from the map.
  final Map<int, AiProfile> aiProfiles;

  /// Whether AI is currently playing (prevents user actions).
  bool _aiPlaying = false;
  bool get aiPlaying => _aiPlaying;

  GameController({
    List<String>? playerNames,
    GameState? initialState,
    this.aiProfiles = const {},
    Random? random,
  })  : assert(
          initialState != null || playerNames != null,
          'Provide either initialState or playerNames',
        ),
        _rng = random ?? Random(),
        _state = initialState ?? createGame(playerNames!, random: random ?? Random()) {
    // If the first player is AI, kick off their turn
    _scheduleAiIfNeeded();
  }

  /// Whether the current player is controlled by AI.
  bool get isCurrentPlayerAi =>
      aiProfiles.containsKey(_state.currentPlayerIndex);

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  GameState get state => _state;
  List<Player> get players => _state.players;
  Player get currentPlayer => _state.currentPlayer;
  int get currentPlayerIndex => _state.currentPlayerIndex;
  int get currentRollIndex => _state.currentRollIndex;
  List<Die> get dice => _state.dice;
  bool get gameOver => _state.gameOver;
  bool get isFromHand => _state.isFromHand;
  bool get accumulationMode => _state.accumulationMode;
  ValidActions get validActions => getValidActions(_state);

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // Rolling animation state
  // ---------------------------------------------------------------------------

  bool _isRolling = false;
  bool get isRolling => _isRolling;

  void _performActionWithRoll(TurnAction action) {
    final prevPlayer = _state.currentPlayerIndex;
    _isRolling = true;
    _state = applyAction(_state, action, random: _rng);
    // Preserve selection after HoldDice so held dice remain visually selected
    // on the next roll. Clear in all other cases (player changed, scoring, pass).
    if (action is! HoldDice || _state.currentPlayerIndex != prevPlayer) {
      _selectedDice.clear();
    }
    notifyListeners();

    // Reset rolling flag after animation duration
    Future.delayed(const Duration(milliseconds: 750), () {
      _isRolling = false;
      notifyListeners();
      // Check if next player is AI
      _scheduleAiIfNeeded();
    });
  }

  void performAction(TurnAction action) {
    _state = applyAction(_state, action, random: _rng);
    _selectedDice.clear();
    notifyListeners();
    _scheduleAiIfNeeded();
  }

  /// Toggle a die's held state for the UI checkbox.
  /// Doesn't actually re-roll — just tracks which dice the player wants to hold.
  /// The actual hold+re-roll happens when [rollWithHeld] is called.
  final Set<int> _selectedDice = {};

  Set<int> get selectedDice => Set.unmodifiable(_selectedDice);

  void toggleDie(int index) {
    if (_selectedDice.contains(index)) {
      _selectedDice.remove(index);
    } else {
      _selectedDice.add(index);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedDice.clear();
    notifyListeners();
  }

  /// Hold selected dice and re-roll the rest.
  /// Selection is preserved so held dice stay selected for next roll.
  void rollWithHeld() {
    _performActionWithRoll(HoldDice(diceIndicesToHold: Set.from(_selectedDice)));
  }

  /// Pass (re-roll all / end turn).
  void pass() => _performActionWithRoll(const Pass());

  /// Score in a figure line.
  void scoreFigure(FigureLine line, int points) =>
      _performActionWithRoll(ScoreFigure(line: line, points: points));

  /// Score a special combo in a figure line.
  void scoreSpecialInFigure(FigureLine line, int points) =>
      _performActionWithRoll(ScoreSpecialInFigure(line: line, points: points));

  /// Score a sequence.
  void scoreSequence(int points, {required bool fromHand}) =>
      _performActionWithRoll(ScoreSequence(points: points, fromHand: fromHand));

  /// Score a fullen.
  void scoreFullen(int points, {required bool fromHand}) =>
      _performActionWithRoll(ScoreFullen(points: points, fromHand: fromHand));

  /// Score a poker.
  void scorePoker(int points) => _performActionWithRoll(ScorePoker(points: points));

  /// Continue accumulation (re-roll all 5 dice, keep running total).
  void continueAccumulation() =>
      _performActionWithRoll(const ContinueAccumulation());

  /// Finalize accumulation.
  void finalizeAccumulation() =>
      performAction(const FinalizeAccumulation());

  // ---------------------------------------------------------------------------
  // AI turn execution
  // ---------------------------------------------------------------------------

  /// If the current player is AI and the game is not over, schedule their turn.
  void _scheduleAiIfNeeded() {
    if (_state.gameOver) return;
    if (_aiPlaying) return;
    if (!isCurrentPlayerAi) return;

    _aiPlaying = true;
    notifyListeners();

    // Short delay so the UI shows the player change before AI acts
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!_state.gameOver && isCurrentPlayerAi) {
        _executeAiAction();
      }
    });
  }

  /// Execute one AI action, then schedule the next (or hand off to human).
  void _executeAiAction() {
    if (_state.gameOver || !isCurrentPlayerAi) {
      _aiPlaying = false;
      notifyListeners();
      return;
    }

    final profile = aiProfiles[_state.currentPlayerIndex]!;
    final action = chooseAction(_state, profile);

    // Apply the action — use _performActionWithRoll for rolling actions
    // so the dice animation plays
    final isRolling = action is HoldDice ||
        action is Pass ||
        action is ContinueAccumulation;

    final prevPlayer = _state.currentPlayerIndex;

    if (isRolling) {
      _isRolling = true;
      _state = applyAction(_state, action, random: _rng);
      if (_state.currentPlayerIndex != prevPlayer) _selectedDice.clear();
      notifyListeners();

      // Wait for dice animation, then continue
      Future.delayed(const Duration(milliseconds: 900), () {
        _isRolling = false;
        notifyListeners();

        if (_state.currentPlayerIndex != prevPlayer) {
          // Turn ended — hand off
          _aiPlaying = false;
          notifyListeners();
          _scheduleAiIfNeeded(); // Next player might also be AI
        } else {
          // Same player, schedule next action
          Future.delayed(const Duration(milliseconds: 500), () {
            _executeAiAction();
          });
        }
      });
    } else {
      // Scoring/finalize — no rolling animation needed
      _state = applyAction(_state, action, random: _rng);
      if (_state.currentPlayerIndex != prevPlayer) _selectedDice.clear();
      notifyListeners();

      if (_state.currentPlayerIndex != prevPlayer) {
        // Turn ended
        _aiPlaying = false;
        notifyListeners();
        _scheduleAiIfNeeded();
      } else {
        // Continue AI turn after brief pause
        Future.delayed(const Duration(milliseconds: 700), () {
          _executeAiAction();
        });
      }
    }
  }

  /// Start a new game with the same player names.
  void restart() {
    final names = _state.players.map((p) => p.name).toList();
    _state = createGame(names, random: _rng);
    _selectedDice.clear();
    _aiPlaying = false;
    notifyListeners();
    _scheduleAiIfNeeded();
  }
}
