/// Game state management for Dipok.
///
/// Handles turn flow, score registration, accumulation mode,
/// and game lifecycle. All functions are pure — they take state in
/// and return new state out.
///
/// See game_specification.md §4, §5.

import 'dart:math';

import 'constants.dart';
import 'models.dart';
import 'scoring.dart';

// ---------------------------------------------------------------------------
// Game State
// ---------------------------------------------------------------------------

/// Complete snapshot of a game in progress.
class GameState {
  final List<Player> players;
  final int currentPlayerIndex;
  final int currentRollIndex; // 0..2
  final List<Die> dice; // exactly 5
  final Set<FigureLine> closedLines;
  final Set<SpecialLine> closedSpecialLines;
  final Set<FigureLine> scoredThisTurn;
  final bool gameOver;

  // Accumulation tracking
  final bool accumulationMode;
  final FigureLine? accumulationTarget;
  final int? accumulationColumn;
  final int accumulationRunningTotal;

  /// Tracks who closed each figure line (playerIndex).
  final Map<FigureLine, int> closedBy;

  /// Tracks who closed each special line (playerIndex).
  final Map<SpecialLine, int> closedSpecialBy;

  /// Whether any dice were scored (picked up) this turn — affects fromHand.
  final bool scoredOnPreviousRoll;

  const GameState({
    required this.players,
    this.currentPlayerIndex = 0,
    this.currentRollIndex = 0,
    required this.dice,
    this.closedLines = const {},
    this.closedSpecialLines = const {},
    this.scoredThisTurn = const {},
    this.gameOver = false,
    this.accumulationMode = false,
    this.accumulationTarget,
    this.accumulationColumn,
    this.accumulationRunningTotal = 0,
    this.closedBy = const {},
    this.closedSpecialBy = const {},
    this.scoredOnPreviousRoll = false,
  });

  Player get currentPlayer => players[currentPlayerIndex];

  /// Whether the current roll qualifies as "from hand" (all 5 dice thrown).
  bool get isFromHand => dice.every((d) => !d.held);

  GameState copyWith({
    List<Player>? players,
    int? currentPlayerIndex,
    int? currentRollIndex,
    List<Die>? dice,
    Set<FigureLine>? closedLines,
    Set<SpecialLine>? closedSpecialLines,
    Set<FigureLine>? scoredThisTurn,
    bool? gameOver,
    bool? accumulationMode,
    FigureLine? accumulationTarget,
    bool clearAccumulationTarget = false,
    int? accumulationColumn,
    bool clearAccumulationColumn = false,
    int? accumulationRunningTotal,
    Map<FigureLine, int>? closedBy,
    Map<SpecialLine, int>? closedSpecialBy,
    bool? scoredOnPreviousRoll,
  }) =>
      GameState(
        players: players ?? this.players,
        currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
        currentRollIndex: currentRollIndex ?? this.currentRollIndex,
        dice: dice ?? this.dice,
        closedLines: closedLines ?? this.closedLines,
        closedSpecialLines: closedSpecialLines ?? this.closedSpecialLines,
        scoredThisTurn: scoredThisTurn ?? this.scoredThisTurn,
        gameOver: gameOver ?? this.gameOver,
        accumulationMode: accumulationMode ?? this.accumulationMode,
        accumulationTarget: clearAccumulationTarget
            ? null
            : (accumulationTarget ?? this.accumulationTarget),
        accumulationColumn: clearAccumulationColumn
            ? null
            : (accumulationColumn ?? this.accumulationColumn),
        accumulationRunningTotal:
            accumulationRunningTotal ?? this.accumulationRunningTotal,
        closedBy: closedBy ?? this.closedBy,
        closedSpecialBy: closedSpecialBy ?? this.closedSpecialBy,
        scoredOnPreviousRoll: scoredOnPreviousRoll ?? this.scoredOnPreviousRoll,
      );
}

// ---------------------------------------------------------------------------
// Turn Actions (sealed hierarchy)
// ---------------------------------------------------------------------------

/// An action a player can take during their turn.
sealed class TurnAction {
  const TurnAction();
}

/// Score in a figure line column. (§4.3)
class ScoreFigure extends TurnAction {
  final FigureLine line;
  final int points;
  const ScoreFigure({required this.line, required this.points});
}

/// Score a special combination using a specific value (e.g. five-of-a-kind
/// registered as a figure line entry). (§2.3, §2.4)
class ScoreSpecialInFigure extends TurnAction {
  final FigureLine line;
  final int points;
  const ScoreSpecialInFigure({required this.line, required this.points});
}

/// Score a sequence. (§2.5)
class ScoreSequence extends TurnAction {
  final int points;
  final bool fromHand;
  const ScoreSequence({required this.points, required this.fromHand});
}

/// Score a fullen. (§2.6)
class ScoreFullen extends TurnAction {
  final int points;
  final bool fromHand;
  const ScoreFullen({required this.points, required this.fromHand});
}

/// Score a poker / royal poker. (§2.10)
class ScorePoker extends TurnAction {
  final int points;
  const ScorePoker({required this.points});
}

/// Hold specific dice (by index 0..4) and re-roll the rest. (§4.2)
class HoldDice extends TurnAction {
  final Set<int> diceIndicesToHold;
  const HoldDice({required this.diceIndicesToHold});
}

/// Pass without scoring or holding — move to next roll. (§4.2)
class Pass extends TurnAction {
  const Pass();
}

/// Continue accumulation: all 5 dice are the target figure or 9,
/// so the player re-rolls all 5 dice and keeps the running total. (§2.11)
class ContinueAccumulation extends TurnAction {
  const ContinueAccumulation();
}

/// Finalize accumulation and register the total. (§2.11)
class FinalizeAccumulation extends TurnAction {
  const FinalizeAccumulation();
}

// ---------------------------------------------------------------------------
// Valid actions query
// ---------------------------------------------------------------------------

/// All legal actions available to the current player in the given state.
///
/// The UI uses this to show/enable controls without duplicating validation.
class ValidActions {
  /// Figure-line scoring options (line + actual points for current dice).
  final List<ScoreFigure> figureScoring;

  /// Special combos registerable in a figure line (five-of-a-kind, five nines).
  final List<ScoreSpecialInFigure> specialInFigure;

  /// Sequence scoring options (min/max straight).
  final List<ScoreSequence> sequences;

  /// Full house scoring options.
  final List<ScoreFullen> fullens;

  /// Poker / Royal Poker scoring options.
  final List<ScorePoker> pokers;

  /// Whether the player can hold dice and re-roll (not on last roll).
  final bool canHold;

  /// Whether the player can pass (always true while game is active).
  final bool canPass;

  /// Whether accumulation can be continued (all 5 dice match target figure or 9).
  final bool canContinueAccumulation;

  /// Whether accumulation can be finalized.
  final bool canFinalize;

  const ValidActions({
    this.figureScoring = const [],
    this.specialInFigure = const [],
    this.sequences = const [],
    this.fullens = const [],
    this.pokers = const [],
    this.canHold = false,
    this.canPass = false,
    this.canContinueAccumulation = false,
    this.canFinalize = false,
  });

  /// True if no scoring or progression actions are available.
  bool get isEmpty =>
      figureScoring.isEmpty &&
      specialInFigure.isEmpty &&
      sequences.isEmpty &&
      fullens.isEmpty &&
      pokers.isEmpty &&
      !canHold &&
      !canPass &&
      !canContinueAccumulation &&
      !canFinalize;

  /// Flat list of every concrete action (excludes HoldDice since indices
  /// are chosen by the user; HoldDice availability is indicated by [canHold]).
  List<TurnAction> toList() => [
        ...figureScoring,
        ...specialInFigure,
        ...sequences,
        ...fullens,
        ...pokers,
        if (canContinueAccumulation) const ContinueAccumulation(),
        if (canFinalize) const FinalizeAccumulation(),
        if (canPass) const Pass(),
      ];
}

/// Compute all legal actions for the current player given [state].
///
/// Returns [ValidActions.isEmpty] == true only if the game is over.
ValidActions getValidActions(GameState state) {
  if (state.gameOver) return const ValidActions();

  final card = state.currentPlayer.scoreCard;
  final faces = state.dice.map((d) => d.face).toList();
  final fromHand = state.isFromHand;
  final isLastRoll = state.currentRollIndex >= rollsPerTurn - 1;

  // ------ Accumulation mode: restricted action set ------
  if (state.accumulationMode) {
    // Check if all 5 dice are target figure or 9 → can continue accumulating
    final target = state.accumulationTarget!;
    final allMatch = faces.every(
        (f) => f == target.dieFace || f == DieFace.nine);
    final canContinue = allMatch && !isLastRoll;

    return ValidActions(
      canHold: !isLastRoll && !allMatch,
      canPass: true,
      canContinueAccumulation: canContinue,
      canFinalize: true,
    );
  }

  // ------ Normal mode ------

  // 1. Figure scoring
  final figureScoring = <ScoreFigure>[];
  for (final line in FigureLine.values) {
    if (state.closedLines.contains(line)) continue;
    if (state.scoredThisTurn.contains(line)) continue;
    final col = card.nextOpenColumn(line);
    if (col == null) continue;
    final points = calculateFigurePoints(faces, line);
    if (points >= columnMinimums[col]) {
      figureScoring.add(ScoreFigure(line: line, points: points));
    }
  }

  // 2. Special combinations
  final combos = detectSpecialCombinations(faces);
  final specialInFigure = <ScoreSpecialInFigure>[];
  final sequences = <ScoreSequence>[];
  final fullens = <ScoreFullen>[];
  final pokers = <ScorePoker>[];

  for (final combo in combos) {
    switch (combo) {
      case FiveOfAKind():
        // Can inscribe in any open, non-closed figure line
        for (final line in FigureLine.values) {
          if (state.closedLines.contains(line)) continue;
          if (card.nextOpenColumn(line) == null) continue;
          specialInFigure.add(ScoreSpecialInFigure(
            line: line,
            points: combo.score(fromHand: fromHand),
          ));
        }
      case FiveNines():
        // Can inscribe in any open, non-closed figure line
        for (final line in FigureLine.values) {
          if (state.closedLines.contains(line)) continue;
          if (card.nextOpenColumn(line) == null) continue;
          specialInFigure.add(ScoreSpecialInFigure(
            line: line,
            points: combo.score(fromHand: fromHand),
          ));
        }
      case MinStraight() || MaxStraight():
        if (!state.closedSpecialLines.contains(SpecialLine.sequences) &&
            card.sequenceEntries.length < columnsPerLine) {
          sequences.add(ScoreSequence(
            points: combo.score(fromHand: fromHand),
            fromHand: fromHand,
          ));
        }
      case FullHouse():
        if (!state.closedSpecialLines.contains(SpecialLine.fullens) &&
            card.fullenEntries.length < columnsPerLine) {
          fullens.add(ScoreFullen(
            points: combo.score(fromHand: fromHand),
            fromHand: fromHand,
          ));
        }
      case Poker() || RoyalPoker():
        // Poker only scores from hand (0 otherwise — not worth offering)
        if (fromHand &&
            !state.closedSpecialLines.contains(SpecialLine.poker) &&
            card.pokerEntries.length < columnsPerLine) {
          pokers.add(ScorePoker(
            points: combo.score(fromHand: true),
          ));
        }
    }
  }

  return ValidActions(
    figureScoring: figureScoring,
    specialInFigure: specialInFigure,
    sequences: sequences,
    fullens: fullens,
    pokers: pokers,
    canHold: !isLastRoll,
    canPass: true,
    canFinalize: false,
  );
}

// ---------------------------------------------------------------------------
// Game initialization
// ---------------------------------------------------------------------------

/// Create a new game with the given player names.
GameState createGame(List<String> playerNames, {Random? random}) {
  assert(playerNames.length >= minPlayers && playerNames.length <= maxPlayers);
  final players = [
    for (var i = 0; i < playerNames.length; i++)
      Player(name: playerNames[i], index: i, scoreCard: ScoreCard()),
  ];
  final dice = _rollAllDice(random ?? Random());
  return GameState(players: players, dice: dice);
}

// ---------------------------------------------------------------------------
// Action application
// ---------------------------------------------------------------------------

/// Apply a [TurnAction] to the current [GameState] and return the new state.
///
/// Throws [StateError] if the action is invalid for the current state.
GameState applyAction(GameState state, TurnAction action, {Random? random}) {
  if (state.gameOver) throw StateError('Game is over.');

  final rng = random ?? Random();

  return switch (action) {
    ScoreFigure() => _applyScoreFigure(state, action, rng),
    ScoreSpecialInFigure() => _applyScoreSpecialInFigure(state, action, rng),
    ScoreSequence() => _applyScoreSequence(state, action, rng),
    ScoreFullen() => _applyScoreFullen(state, action, rng),
    ScorePoker() => _applyScorePoker(state, action, rng),
    HoldDice() => _applyHoldDice(state, action, rng),
    Pass() => _applyPass(state, rng),
    ContinueAccumulation() => _applyContinueAccumulation(state, rng),
    FinalizeAccumulation() => _applyFinalizeAccumulation(state, rng),
  };
}

// ---------------------------------------------------------------------------
// Scoring actions
// ---------------------------------------------------------------------------

GameState _applyScoreFigure(GameState state, ScoreFigure action, Random rng) {
  final line = action.line;
  final card = state.currentPlayer.scoreCard;

  if (state.closedLines.contains(line)) {
    throw StateError('Line $line is closed.');
  }
  if (state.scoredThisTurn.contains(line)) {
    throw StateError('Already scored $line this turn.');
  }
  if (state.accumulationMode) {
    throw StateError('Cannot score figure normally during accumulation.');
  }

  final col = card.nextOpenColumn(line);
  if (col == null) throw StateError('Line $line is full for this player.');
  if (action.points < columnMinimums[col]) {
    throw StateError(
        'Points ${action.points} below minimum ${columnMinimums[col]} for column $col.');
  }

  final faces = state.dice.map((d) => d.face).toList();

  // Check if all 5 dice are the target figure or 9 → enter accumulation mode
  final allMatch = faces.every(
      (f) => f == line.dieFace || f == DieFace.nine);

  if (allMatch && state.currentRollIndex < rollsPerTurn - 1) {
    // Enter accumulation mode — don't register yet, store running total
    return state.copyWith(
      accumulationMode: true,
      accumulationTarget: line,
      accumulationColumn: col,
      accumulationRunningTotal: action.points,
      scoredThisTurn: {...state.scoredThisTurn, line},
    );
  }

  // Normal scoring: write score into the player's card
  final newScores = _copyFigureScores(card.figureScores);
  newScores[line]![col] = action.points;
  final newCard = ScoreCard(
    figureScores: newScores,
    sequenceEntries: List.of(card.sequenceEntries),
    fullenEntries: List.of(card.fullenEntries),
    pokerEntries: List.of(card.pokerEntries),
  );

  final newPlayers = _updatePlayer(state.players, state.currentPlayerIndex,
      state.currentPlayer.copyWith(scoreCard: newCard));

  // Check if this player just closed the line
  var newClosedLines = state.closedLines;
  var newClosedBy = state.closedBy;
  if (newCard.isLineComplete(line)) {
    newClosedLines = {...state.closedLines, line};
    newClosedBy = {...state.closedBy, line: state.currentPlayerIndex};
  }

  final newScoredThisTurn = {...state.scoredThisTurn, line};

  // After scoring, pick up all dice → next roll is fromHand
  return _advanceAfterScore(state.copyWith(
    players: newPlayers,
    closedLines: newClosedLines,
    closedBy: newClosedBy,
    scoredThisTurn: newScoredThisTurn,
  ), rng);
}

GameState _applyScoreSpecialInFigure(
    GameState state, ScoreSpecialInFigure action, Random rng) {
  final line = action.line;
  final card = state.currentPlayer.scoreCard;

  if (state.closedLines.contains(line)) {
    throw StateError('Line $line is closed.');
  }
  if (state.accumulationMode) {
    throw StateError('Cannot score specials during accumulation.');
  }

  final col = card.nextOpenColumn(line);
  if (col == null) throw StateError('Line $line is full for this player.');

  // Special scores (five-of-a-kind, five nines) bypass column minimums
  final newScores = _copyFigureScores(card.figureScores);
  newScores[line]![col] = action.points;
  final newCard = ScoreCard(
    figureScores: newScores,
    sequenceEntries: List.of(card.sequenceEntries),
    fullenEntries: List.of(card.fullenEntries),
    pokerEntries: List.of(card.pokerEntries),
  );

  final newPlayers = _updatePlayer(state.players, state.currentPlayerIndex,
      state.currentPlayer.copyWith(scoreCard: newCard));

  var newClosedLines = state.closedLines;
  var newClosedBy = state.closedBy;
  if (newCard.isLineComplete(line)) {
    newClosedLines = {...state.closedLines, line};
    newClosedBy = {...state.closedBy, line: state.currentPlayerIndex};
  }

  final newScoredThisTurn = {...state.scoredThisTurn, line};

  return _advanceAfterScore(state.copyWith(
    players: newPlayers,
    closedLines: newClosedLines,
    closedBy: newClosedBy,
    scoredThisTurn: newScoredThisTurn,
  ), rng);
}

GameState _applyScoreSequence(
    GameState state, ScoreSequence action, Random rng) {
  if (state.accumulationMode) {
    throw StateError('Cannot score sequence during accumulation.');
  }
  if (state.closedSpecialLines.contains(SpecialLine.sequences)) {
    throw StateError('Sequence line is closed.');
  }

  final card = state.currentPlayer.scoreCard;
  if (card.sequenceEntries.length >= columnsPerLine) {
    throw StateError('Sequence line is full (max $columnsPerLine entries).');
  }
  final newCard = ScoreCard(
    figureScores: _copyFigureScores(card.figureScores),
    sequenceEntries: [
      ...card.sequenceEntries,
      SpecialEntry(score: action.points, fromHand: action.fromHand),
    ],
    fullenEntries: List.of(card.fullenEntries),
    pokerEntries: List.of(card.pokerEntries),
  );

  final newPlayers = _updatePlayer(state.players, state.currentPlayerIndex,
      state.currentPlayer.copyWith(scoreCard: newCard));

  // Close sequence line if this player filled all 5 slots
  var newClosedSpecial = state.closedSpecialLines;
  var newClosedSpecialBy = state.closedSpecialBy;
  if (newCard.sequenceEntries.length >= columnsPerLine) {
    newClosedSpecial = {...state.closedSpecialLines, SpecialLine.sequences};
    newClosedSpecialBy = {...state.closedSpecialBy, SpecialLine.sequences: state.currentPlayerIndex};
  }

  return _advanceAfterScore(state.copyWith(
    players: newPlayers,
    closedSpecialLines: newClosedSpecial,
    closedSpecialBy: newClosedSpecialBy,
  ), rng);
}

GameState _applyScoreFullen(GameState state, ScoreFullen action, Random rng) {
  if (state.accumulationMode) {
    throw StateError('Cannot score fullen during accumulation.');
  }

  final card = state.currentPlayer.scoreCard;
  if (card.fullenEntries.length >= columnsPerLine) {
    throw StateError('Fullen line is full (max $columnsPerLine entries).');
  }
  if (state.closedSpecialLines.contains(SpecialLine.fullens)) {
    throw StateError('Fullen line is closed.');
  }
  final newCard = ScoreCard(
    figureScores: _copyFigureScores(card.figureScores),
    sequenceEntries: List.of(card.sequenceEntries),
    fullenEntries: [
      ...card.fullenEntries,
      SpecialEntry(score: action.points, fromHand: action.fromHand),
    ],
    pokerEntries: List.of(card.pokerEntries),
  );

  final newPlayers = _updatePlayer(state.players, state.currentPlayerIndex,
      state.currentPlayer.copyWith(scoreCard: newCard));

  var newClosedSpecial = state.closedSpecialLines;
  var newClosedSpecialBy = state.closedSpecialBy;
  if (newCard.fullenEntries.length >= columnsPerLine) {
    newClosedSpecial = {...state.closedSpecialLines, SpecialLine.fullens};
    newClosedSpecialBy = {...state.closedSpecialBy, SpecialLine.fullens: state.currentPlayerIndex};
  }

  return _advanceAfterScore(state.copyWith(
    players: newPlayers,
    closedSpecialLines: newClosedSpecial,
    closedSpecialBy: newClosedSpecialBy,
  ), rng);
}

GameState _applyScorePoker(GameState state, ScorePoker action, Random rng) {
  if (state.accumulationMode) {
    throw StateError('Cannot score poker during accumulation.');
  }

  final card = state.currentPlayer.scoreCard;
  if (card.pokerEntries.length >= columnsPerLine) {
    throw StateError('Poker line is full (max $columnsPerLine entries).');
  }
  if (state.closedSpecialLines.contains(SpecialLine.poker)) {
    throw StateError('Poker line is closed.');
  }
  final newCard = ScoreCard(
    figureScores: _copyFigureScores(card.figureScores),
    sequenceEntries: List.of(card.sequenceEntries),
    fullenEntries: List.of(card.fullenEntries),
    pokerEntries: [
      ...card.pokerEntries,
      SpecialEntry(score: action.points, fromHand: true),
    ],
  );

  final newPlayers = _updatePlayer(state.players, state.currentPlayerIndex,
      state.currentPlayer.copyWith(scoreCard: newCard));

  var newClosedSpecial = state.closedSpecialLines;
  var newClosedSpecialBy = state.closedSpecialBy;
  if (newCard.pokerEntries.length >= columnsPerLine) {
    newClosedSpecial = {...state.closedSpecialLines, SpecialLine.poker};
    newClosedSpecialBy = {...state.closedSpecialBy, SpecialLine.poker: state.currentPlayerIndex};
  }

  return _advanceAfterScore(state.copyWith(
    players: newPlayers,
    closedSpecialLines: newClosedSpecial,
    closedSpecialBy: newClosedSpecialBy,
  ), rng);
}

// ---------------------------------------------------------------------------
// Hold / Pass
// ---------------------------------------------------------------------------

GameState _applyHoldDice(GameState state, HoldDice action, Random rng) {
  if (state.currentRollIndex >= rollsPerTurn - 1) {
    throw StateError('No more rolls left — cannot hold.');
  }
  if (state.accumulationMode) {
    // In accumulation mode, holding is part of building the combo.
    // Re-roll non-held dice, calculate new points for the target.
    final newDice = _rollWithHeld(state.dice, action.diceIndicesToHold, rng);
    final faces = newDice.map((d) => d.face).toList();
    final accTarget = state.accumulationTarget!;
    final rollPoints = calculateFigurePoints(faces, accTarget);

    return state.copyWith(
      dice: newDice,
      currentRollIndex: state.currentRollIndex + 1,
      accumulationRunningTotal:
          state.accumulationRunningTotal + rollPoints,
    );
  }

  final newDice = _rollWithHeld(state.dice, action.diceIndicesToHold, rng);
  return state.copyWith(
    dice: newDice,
    currentRollIndex: state.currentRollIndex + 1,
    scoredOnPreviousRoll: false,
  );
}

GameState _applyPass(GameState state, Random rng) {
  // If in accumulation mode, passing finalizes the accumulation
  if (state.accumulationMode) {
    return _applyFinalizeAccumulation(state, rng);
  }

  if (state.currentRollIndex >= rollsPerTurn - 1) {
    // Last roll — end turn
    return _endTurn(state, rng);
  }

  // Advance to next roll, re-roll all unheld dice
  final newDice = _rollWithHeld(state.dice, {}, rng);
  return state.copyWith(
    dice: newDice,
    currentRollIndex: state.currentRollIndex + 1,
  );
}

// ---------------------------------------------------------------------------
// Accumulation mode
// ---------------------------------------------------------------------------

/// Continue accumulation: re-roll all 5 dice, add new points to running total.
/// Triggered when all 5 dice match the target figure or 9.
GameState _applyContinueAccumulation(GameState state, Random rng) {
  if (!state.accumulationMode) {
    throw StateError('Not in accumulation mode.');
  }
  if (state.currentRollIndex >= rollsPerTurn - 1) {
    throw StateError('No more rolls left — cannot continue accumulation.');
  }

  // Re-roll all 5 dice
  final newDice = _rollAllDice(rng);
  final faces = newDice.map((d) => d.face).toList();
  final accTarget = state.accumulationTarget!;
  final rollPoints = calculateFigurePoints(faces, accTarget);

  return state.copyWith(
    dice: newDice,
    currentRollIndex: state.currentRollIndex + 1,
    accumulationRunningTotal:
        state.accumulationRunningTotal + rollPoints,
  );
}

GameState _applyFinalizeAccumulation(GameState state, Random rng) {
  if (!state.accumulationMode) {
    throw StateError('Not in accumulation mode.');
  }

  final line = state.accumulationTarget!;
  final col = state.accumulationColumn!;
  final total = state.accumulationRunningTotal;

  // Check minimum
  if (total < columnMinimums[col]) {
    // Total doesn't meet minimum — turn wasted, nothing registered
    return _endTurn(state.copyWith(
      accumulationMode: false,
    ), rng);
  }

  // Register the accumulated total
  final card = state.currentPlayer.scoreCard;
  final newScores = _copyFigureScores(card.figureScores);
  newScores[line]![col] = total;
  final newCard = ScoreCard(
    figureScores: newScores,
    sequenceEntries: List.of(card.sequenceEntries),
    fullenEntries: List.of(card.fullenEntries),
    pokerEntries: List.of(card.pokerEntries),
  );

  final newPlayers = _updatePlayer(state.players, state.currentPlayerIndex,
      state.currentPlayer.copyWith(scoreCard: newCard));

  var newClosedLines = state.closedLines;
  var newClosedBy = state.closedBy;
  if (newCard.isLineComplete(line)) {
    newClosedLines = {...state.closedLines, line};
    newClosedBy = {...state.closedBy, line: state.currentPlayerIndex};
  }

  return _endTurn(state.copyWith(
    players: newPlayers,
    closedLines: newClosedLines,
    closedBy: newClosedBy,
    accumulationMode: false,
  ), rng);
}

// ---------------------------------------------------------------------------
// Turn / round progression
// ---------------------------------------------------------------------------

/// After a scoring action: pick up all dice and advance to next roll,
/// or end turn if this was the last roll.
GameState _advanceAfterScore(GameState state, Random rng) {
  if (state.currentRollIndex >= rollsPerTurn - 1) {
    // Was the last roll — end turn
    return _endTurn(state, rng);
  }

  // Pick up all dice → next roll is fromHand
  final newDice = _rollAllDice(rng);
  return state.copyWith(
    dice: newDice,
    currentRollIndex: state.currentRollIndex + 1,
    scoredOnPreviousRoll: true,
  );
}

/// End the current player's turn and move to next player (or end game).
GameState _endTurn(GameState state, Random rng) {
  // Check game end
  if (isGameOver(state.closedLines, state.closedSpecialLines)) {
    return state.copyWith(gameOver: true);
  }

  // Next player
  final nextPlayer = (state.currentPlayerIndex + 1) % state.players.length;
  final newDice = _rollAllDice(rng);

  return state.copyWith(
    currentPlayerIndex: nextPlayer,
    currentRollIndex: 0,
    dice: newDice,
    scoredThisTurn: {},
    accumulationMode: false,
    clearAccumulationTarget: true,
    clearAccumulationColumn: true,
    accumulationRunningTotal: 0,
    scoredOnPreviousRoll: false,
  );
}

// ---------------------------------------------------------------------------
// Dice helpers
// ---------------------------------------------------------------------------

List<Die> _rollAllDice(Random rng) => List.generate(
      diceCount,
      (_) => Die(face: _randomFace(rng)),
    );

List<Die> _rollWithHeld(
    List<Die> current, Set<int> holdIndices, Random rng) {
  return [
    for (var i = 0; i < current.length; i++)
      if (holdIndices.contains(i))
        current[i].copyWith(held: true)
      else
        Die(face: _randomFace(rng)),
  ];
}

DieFace _randomFace(Random rng) => DieFace.values[rng.nextInt(DieFace.values.length)];

// ---------------------------------------------------------------------------
// State helpers
// ---------------------------------------------------------------------------

Map<FigureLine, List<int?>> _copyFigureScores(
    Map<FigureLine, List<int?>> original) {
  return {
    for (final entry in original.entries)
      entry.key: List<int?>.from(entry.value),
  };
}

List<Player> _updatePlayer(
    List<Player> players, int index, Player updated) {
  return [
    for (var i = 0; i < players.length; i++)
      if (i == index) updated else players[i],
  ];
}
