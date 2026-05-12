import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dipok/engine/game_engine.dart';
import 'package:dipok/engine/models.dart';
import 'package:dipok/ui/services/achievements_service.dart';

ScoreCard _card({
  int aces = 0,
  List<SpecialEntry>? poker,
  List<SpecialEntry>? seq,
  List<SpecialEntry>? full,
}) {
  final figureScores = {
    for (final line in FigureLine.values) line: List<int?>.filled(5, null),
  };
  if (aces > 0) {
    figureScores[FigureLine.aces]![0] = aces;
  }

  return ScoreCard(
    figureScores: figureScores,
    sequenceEntries: seq ?? [],
    fullenEntries: full ?? [],
    pokerEntries: poker ?? [],
  );
}

GameState _buildCompletedState({
  required ScoreCard p1,
  ScoreCard? p2,
  ScoreCard? p3,
  ScoreCard? p4,
}) {
  final base = createGame(['P1', 'P2', 'P3', 'P4']);
  final players = [
    base.players[0].copyWith(scoreCard: p1),
    base.players[1].copyWith(scoreCard: p2 ?? _card()),
    base.players[2].copyWith(scoreCard: p3 ?? _card()),
    base.players[3].copyWith(scoreCard: p4 ?? _card()),
  ];

  return base.copyWith(
    players: players,
    gameOver: true,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AchievementsService.clearAll();
  });

  test('unlocks poker milestone at 10 total', () async {
    final pokerEntries = List.generate(
      10,
      (_) => const SpecialEntry(score: 100, fromHand: true),
    );

    final state = _buildCompletedState(
      p1: _card(aces: 8, poker: pokerEntries),
    );

    final unlocked = await AchievementsService.processCompletedMatch(
      state: state,
      aiProfiles: const {},
      rollObservations: const [],
    );

    expect(unlocked, contains(AchievementId.poker10));

    final snapshot = await AchievementsService.getSnapshot();
    expect(snapshot.totalPoker, 10);
  });

  test('counts sequences/full houses only when fromHand', () async {
    final seq = [
      const SpecialEntry(score: 30, fromHand: true),
      const SpecialEntry(score: 60, fromHand: true),
      const SpecialEntry(score: 15, fromHand: false),
    ];
    final full = [
      const SpecialEntry(score: 30, fromHand: true),
      const SpecialEntry(score: 15, fromHand: false),
    ];

    final state = _buildCompletedState(
      p1: _card(aces: 8, seq: seq, full: full),
    );

    await AchievementsService.processCompletedMatch(
      state: state,
      aiProfiles: const {},
      rollObservations: const [],
    );

    final snapshot = await AchievementsService.getSnapshot();
    expect(snapshot.totalSeqFromHand, 2);
    expect(snapshot.totalFullFromHand, 1);
  });

  test('unlocks all faces five-of-kind after seeing all six faces', () async {
    final state = _buildCompletedState(
      p1: _card(aces: 8),
    );

    final observations = [
      for (final f in DieFace.values)
        RollObservation(
          faces: [f, f, f, f, f],
          fromHand: true,
        ),
    ];

    final unlocked = await AchievementsService.processCompletedMatch(
      state: state,
      aiProfiles: const {},
      rollObservations: observations,
    );

    expect(unlocked, contains(AchievementId.allFacesFiveOfKind));

    final snapshot = await AchievementsService.getSnapshot();
    expect(snapshot.fiveKindFacesSeen.length, DieFace.values.length);
  });
}
