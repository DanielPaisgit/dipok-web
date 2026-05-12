/// AI player profiles — pure functions, no side effects.
///
/// Each profile evaluates the current [GameState] and [ValidActions]
/// to choose the best [TurnAction]. Profiles differ in strategy:
///
/// - **Balanced**: Maximise expected value across all lines.
/// - **Aggressive**: Chase high-multiplier lines, specials, and accumulation.
/// - **Cautious**: Minimise risk — score early, avoid wasted turns.
///
/// Usage: call [chooseAction] with the current state and desired profile.
/// The function returns the [TurnAction] plus any dice indices to hold
/// (for [HoldDice] actions).

import 'dart:math' as math;

import 'constants.dart';
import 'game_engine.dart';
import 'models.dart';
import 'scoring.dart';

// ---------------------------------------------------------------------------
// Profile enum
// ---------------------------------------------------------------------------

enum AiProfile {
  balanced,
  aggressive,
  cautious,
  dreamer,
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Choose the best action for the current game state.
///
/// Returns a [TurnAction] ready to be passed to [applyAction].
/// For [HoldDice] actions, the dice indices are already set.
TurnAction chooseAction(GameState state, AiProfile profile) {
  final va = getValidActions(state);
  assert(!va.isEmpty, 'AI called with no valid actions');

  // Dreamer: hunts poker only. Accepts non-poker only if it appears from hand.
  if (profile == AiProfile.dreamer) {
    return _chooseDreamerAction(state, va);
  }

  // Accumulation mode — handle separately
  if (state.accumulationMode) {
    return _handleAccumulation(state, va, profile);
  }

  // Evaluate all scoring options
  final scored = _scoreCandidates(state, va, profile);

  // Evaluate hold+re-roll option
  final holdValue = va.canHold
      ? _evaluateHold(state, profile)
      : null;

  // On the last roll, we MUST score if possible (can't hold)
  final isLastRoll = state.currentRollIndex >= rollsPerTurn - 1;

  // Decide: score now or hold for better?
  if (scored.isNotEmpty) {
    final bestScore = scored.first;

    if (!isLastRoll && holdValue != null) {
      // Compare immediate score vs expected value of holding
      final threshold = _holdThreshold(state, profile);
      if (bestScore.value >= holdValue.expectedValue * threshold) {
        return bestScore.action;
      }
      return holdValue.action;
    }
    return bestScore.action;
  }

  // No scoring options — must hold or pass
  if (holdValue != null && !isLastRoll) {
    return holdValue.action;
  }

  return const Pass();
}

TurnAction _chooseDreamerAction(GameState state, ValidActions va) {
  // Dreamer doesn't want to stay in accumulation mode.
  if (state.accumulationMode) {
    if (va.canFinalize) return const FinalizeAccumulation();
    return const Pass();
  }

  if (state.isFromHand) {
    if (va.pokers.isNotEmpty) {
      va.pokers.sort((a, b) => b.points.compareTo(a.points));
      return va.pokers.first;
    }

    final fallbackFromHand = <TurnAction>[
      ...va.specialInFigure,
      ...va.sequences.where((s) => s.fromHand),
      ...va.fullens.where((f) => f.fromHand),
      ...va.figureScoring,
    ];

    if (fallbackFromHand.isNotEmpty) {
      fallbackFromHand.sort((a, b) => _actionPoints(b).compareTo(_actionPoints(a)));
      return fallbackFromHand.first;
    }
  }

  // Keep re-rolling all 5 dice to preserve from-hand chances.
  if (va.canPass) return const Pass();
  if (va.canHold) return const HoldDice(diceIndicesToHold: {});

  // Last-resort fallback to any scoring action if no progression action exists.
  final allScoring = <TurnAction>[
    ...va.pokers,
    ...va.specialInFigure,
    ...va.sequences,
    ...va.fullens,
    ...va.figureScoring,
  ];
  if (allScoring.isNotEmpty) {
    allScoring.sort((a, b) => _actionPoints(b).compareTo(_actionPoints(a)));
    return allScoring.first;
  }

  return const Pass();
}

int _actionPoints(TurnAction action) {
  return switch (action) {
    ScoreFigure(points: final p) => p,
    ScoreSpecialInFigure(points: final p) => p,
    ScoreSequence(points: final p) => p,
    ScoreFullen(points: final p) => p,
    ScorePoker(points: final p) => p,
    _ => 0,
  };
}

// ---------------------------------------------------------------------------
// Internal types
// ---------------------------------------------------------------------------

class _ScoredOption implements Comparable<_ScoredOption> {
  final TurnAction action;
  final double value; // weighted score

  const _ScoredOption(this.action, this.value);

  @override
  int compareTo(_ScoredOption other) => other.value.compareTo(value); // desc
}

class _HoldOption {
  final TurnAction action;
  final double expectedValue;

  const _HoldOption(this.action, this.expectedValue);
}

// ---------------------------------------------------------------------------
// Accumulation handling
// ---------------------------------------------------------------------------

TurnAction _handleAccumulation(
  GameState state,
  ValidActions va,
  AiProfile profile,
) {
  final rollsLeft = rollsPerTurn - 1 - state.currentRollIndex;
  final running = state.accumulationRunningTotal;
  final col = state.accumulationColumn ?? 0;
  final minRequired = columnMinimums[col];

  // If we can continue and have rolls left
  if (va.canContinueAccumulation && rollsLeft > 0) {
    switch (profile) {
      case AiProfile.aggressive:
        // Always continue if possible — chase big totals
        return const ContinueAccumulation();
      case AiProfile.balanced:
        // Continue if running total < 2× minimum, or if on early rolls
        if (running < minRequired * 2 || state.currentRollIndex == 0) {
          return const ContinueAccumulation();
        }
        return const FinalizeAccumulation();
      case AiProfile.cautious:
        // Finalize as soon as we meet minimum
        if (running >= minRequired) {
          return const FinalizeAccumulation();
        }
        return const ContinueAccumulation();
      case AiProfile.dreamer:
        // Dreamer exits accumulation as soon as possible.
        return const FinalizeAccumulation();
    }
  }

  // Can finalize?
  if (va.canFinalize) {
    return const FinalizeAccumulation();
  }

  // Hold dice that match target, re-roll the rest
  if (va.canHold) {
    final target = state.accumulationTarget;
    final indices = <int>{};
    for (var i = 0; i < diceCount; i++) {
      final face = state.dice[i].face;
      if (face == target?.dieFace || face == DieFace.nine) {
        indices.add(i);
      }
    }
    if (indices.isNotEmpty && indices.length < diceCount) {
      return HoldDice(diceIndicesToHold: indices);
    }
  }

  // Fallback: pass (auto-finalizes in accumulation)
  return const Pass();
}

// ---------------------------------------------------------------------------
// Score candidate evaluation
// ---------------------------------------------------------------------------

List<_ScoredOption> _scoreCandidates(
  GameState state,
  ValidActions va,
  AiProfile profile,
) {
  final options = <_ScoredOption>[];
  final card = state.currentPlayer.scoreCard;

  // --- Figure lines ---
  for (final sf in va.figureScoring) {
    final col = card.nextOpenColumn(sf.line);
    if (col == null) continue;
    final multiplier = sf.line.multiplier;
    final rawValue = sf.points.toDouble();

    // Weight by multiplier and profile preferences
    double weight;
    switch (profile) {
      case AiProfile.aggressive:
        // Prefer high-multiplier lines (aces ×6, kings ×5)
        weight = rawValue * multiplier * 1.2;
      case AiProfile.balanced:
        weight = rawValue * multiplier;
      case AiProfile.cautious:
        // Prefer filling low columns first (safe points)
        weight = rawValue * multiplier * (1 + (col / columnsPerLine) * 0.3);
      case AiProfile.dreamer:
        weight = rawValue * multiplier * 0.4;
    }

    // Bonus: scoring when close to closing a line
    final filled = card.filledColumns(sf.line);
    if (filled >= 3) weight *= 1.5; // 4th or 5th column = close to closing
    if (filled >= 4) weight *= 2.0; // Closing the line!

    // Penalty for high-multiplier lines if points are low (wasting columns)
    final minForCol = columnMinimums[col];
    if (sf.points <= minForCol + 1 && profile != AiProfile.cautious) {
      weight *= 0.6; // Barely above minimum — not great
    }

    options.add(_ScoredOption(sf, weight));
  }

  // --- Special in figure (five-of-a-kind / five nines in figure line) ---
  for (final sp in va.specialInFigure) {
    // Very high value — bypasses minimums
    final multiplier = sp.line.multiplier;
    options.add(_ScoredOption(sp, sp.points * multiplier * 2.0));
  }

  // --- Sequences ---
  for (final seq in va.sequences) {
    double weight = seq.points.toDouble();
    if (seq.fromHand) weight *= 1.3; // Bonus for from-hand
    if (profile == AiProfile.aggressive) weight *= 1.1;
    options.add(_ScoredOption(seq, weight));
  }

  // --- Fullens ---
  for (final ful in va.fullens) {
    double weight = ful.points.toDouble();
    if (ful.fromHand) weight *= 1.3;
    options.add(_ScoredOption(ful, weight));
  }

  // --- Pokers ---
  for (final pok in va.pokers) {
    // Pokers are from-hand only and very valuable
    double weight = pok.points.toDouble();
    if (profile == AiProfile.aggressive) weight *= 1.5;
    options.add(_ScoredOption(pok, weight));
  }

  options.sort(); // descending by value
  return options;
}

// ---------------------------------------------------------------------------
// Hold evaluation — which dice to keep?
// ---------------------------------------------------------------------------

_HoldOption? _evaluateHold(GameState state, AiProfile profile) {
  if (state.currentRollIndex >= rollsPerTurn - 1) return null; // Last roll

  final dice = state.dice;
  final card = state.currentPlayer.scoreCard;
  final faces = dice.map((d) => d.face).toList();

  // Count occurrences of each face
  final counts = <DieFace, int>{};
  for (final f in faces) {
    counts[f] = (counts[f] ?? 0) + 1;
  }

  // Strategy 1: Hold the most common face (targeting figure line)
  DieFace? bestFace;
  int bestCount = 0;
  for (final entry in counts.entries) {
    if (entry.key == DieFace.nine) continue; // Don't target nines
    final line = FigureLine.fromDieFace(entry.key);
    if (line == null) continue;
    if (state.closedLines.contains(line)) continue; // Line already closed
    if (card.isLineComplete(line)) continue; // All columns filled

    if (entry.value > bestCount) {
      bestCount = entry.value;
      bestFace = entry.key;
    }
  }

  // Strategy 2: Check for near-straights (4 of 5 sequential)
  final distinctFaces = counts.keys.toSet();
  final nearStraight = _checkNearStraight(distinctFaces);

  // Decide between grouping vs straight-chasing
  if (nearStraight != null && bestCount < 3) {
    // Chase the straight — hold all distinct sequential faces
    final holdIndices = <int>{};
    for (var i = 0; i < diceCount; i++) {
      if (nearStraight.contains(faces[i])) {
        holdIndices.add(i);
      }
    }
    if (holdIndices.isNotEmpty && holdIndices.length < diceCount) {
      final expectedValue = state.currentPlayer.scoreCard.sequenceEntries.isEmpty
          ? 25.0 // Sequence is valuable if we don't have one yet
          : 12.0;
      return _HoldOption(
        HoldDice(diceIndicesToHold: holdIndices),
        expectedValue,
      );
    }
  }

  if (bestFace != null && bestCount >= 2) {
    // Hold matching faces + nines
    final holdIndices = <int>{};
    for (var i = 0; i < diceCount; i++) {
      if (faces[i] == bestFace || faces[i] == DieFace.nine) {
        holdIndices.add(i);
      }
    }

    if (holdIndices.isNotEmpty && holdIndices.length < diceCount) {
      final line = FigureLine.fromDieFace(bestFace)!;
      final col = card.nextOpenColumn(line) ?? 0;
      final multiplier = line.multiplier;
      // Expected points: current points + ~2 per re-rolled die × 0.33 chance
      final currentPoints = calculateFigurePoints(faces, line);
      final rerolling = diceCount - holdIndices.length;
      final expectedGain = rerolling * 0.55; // ~33% chance of match (2pts) or nine (1pt)
      final expectedValue = (currentPoints + expectedGain) * multiplier;

      return _HoldOption(
        HoldDice(diceIndicesToHold: holdIndices),
        expectedValue,
      );
    }
  }

  // Nothing compelling to hold — pass (re-roll all)
  if (state.currentRollIndex < rollsPerTurn - 1) {
    return _HoldOption(const Pass(), 5.0); // Low expected value
  }

  return null;
}

/// Check if faces contain 4 of 5 for a min or max straight.
Set<DieFace>? _checkNearStraight(Set<DieFace> faces) {
  const maxStraight = {
    DieFace.ace, DieFace.king, DieFace.queen, DieFace.jack, DieFace.ten,
  };
  const minStraight = {
    DieFace.king, DieFace.queen, DieFace.jack, DieFace.ten, DieFace.nine,
  };

  final maxOverlap = faces.intersection(maxStraight);
  if (maxOverlap.length >= 4) return maxOverlap;

  final minOverlap = faces.intersection(minStraight);
  if (minOverlap.length >= 4) return minOverlap;

  return null;
}

// ---------------------------------------------------------------------------
// Profile tuning
// ---------------------------------------------------------------------------

/// How eagerly to score immediately vs hold for better.
/// Higher = more likely to score now. Lower = more likely to hold.
double _holdThreshold(GameState state, AiProfile profile) {
  final rollsLeft = rollsPerTurn - 1 - state.currentRollIndex;

  switch (profile) {
    case AiProfile.aggressive:
      // Hold longer — chase big scores
      return rollsLeft > 0 ? 0.6 : 1.0;
    case AiProfile.balanced:
      return rollsLeft > 0 ? 0.8 : 1.0;
    case AiProfile.cautious:
      // Score early — don't risk losing points
      return rollsLeft > 0 ? 1.1 : 1.0;
    case AiProfile.dreamer:
      return 0.7;
  }
}
