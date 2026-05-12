import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dipok/engine/ai_profiles.dart';
import 'package:dipok/engine/game_engine.dart';
import 'package:dipok/engine/models.dart';
import 'package:dipok/engine/scoring.dart';

class _ProfileStats {
  int appearances = 0;
  int wins = 0;
  int totalScore = 0;
  int totalPokerEntries = 0;
  int totalSequenceEntries = 0;
  int totalFullEntries = 0;
  int totalSequenceFromHand = 0;
  int totalFullFromHand = 0;
  final List<int> scores = [];

  Map<String, dynamic> toJson() {
    return {
      'appearances': appearances,
      'wins': wins,
      'win_rate': appearances == 0 ? 0.0 : wins / appearances,
      'avg_score': appearances == 0 ? 0.0 : totalScore / appearances,
      'median_score': _median(scores),
      'std_score': _stdDev(scores),
      'avg_poker_entries': appearances == 0 ? 0.0 : totalPokerEntries / appearances,
      'avg_sequence_entries': appearances == 0 ? 0.0 : totalSequenceEntries / appearances,
      'avg_full_entries': appearances == 0 ? 0.0 : totalFullEntries / appearances,
      'avg_seq_from_hand': appearances == 0 ? 0.0 : totalSequenceFromHand / appearances,
      'avg_full_from_hand': appearances == 0 ? 0.0 : totalFullFromHand / appearances,
    };
  }
}

class _RunConfig {
  final int games;
  final int seed;
  final int maxMoves;
  final String mode;
  final AiProfile mirrorProfile;

  const _RunConfig({
    required this.games,
    required this.seed,
    required this.maxMoves,
    required this.mode,
    required this.mirrorProfile,
  });
}

void main(List<String> args) async {
  final cfg = _parseArgs(args);
  final runId = _buildRunId();

  final sw = Stopwatch()..start();
  final rng = Random(cfg.seed);

  final profiles = AiProfile.values;
  final winsByProfile = <String, int>{for (final p in profiles) p.name: 0};
  final winsBySeat = <int, int>{0: 0, 1: 0, 2: 0, 3: 0};
  final statsByProfile = <AiProfile, _ProfileStats>{
    for (final p in profiles) p: _ProfileStats(),
  };

  int errors = 0;
  int completedGames = 0;
  int totalMoves = 0;
  int totalPokerEntries = 0;
  int totalSequenceEntries = 0;
  int totalFullEntries = 0;
  int totalSequenceFromHand = 0;
  int totalFullFromHand = 0;
  int totalRoyalPokerEntries = 0;

  final perGame = <Map<String, dynamic>>[];

  for (var gameIdx = 0; gameIdx < cfg.games; gameIdx++) {
    final gameSeed = rng.nextInt(1 << 31);

    try {
      final gameResult = _simulateOneGame(
        gameIndex: gameIdx,
        gameSeed: gameSeed,
        maxMoves: cfg.maxMoves,
        cfg: cfg,
      );

      completedGames++;
      totalMoves += gameResult['moves'] as int;

      final winnerSeat = gameResult['winner_seat'] as int;
      final seatProfiles = (gameResult['seat_profiles'] as List<dynamic>).cast<String>();
      final winnerProfile = seatProfiles[winnerSeat];
      winsByProfile[winnerProfile] = (winsByProfile[winnerProfile] ?? 0) + 1;
      winsBySeat[winnerSeat] = (winsBySeat[winnerSeat] ?? 0) + 1;

      final players = (gameResult['players'] as List<dynamic>).cast<Map<String, dynamic>>();
      for (var seat = 0; seat < players.length; seat++) {
        final profile = AiProfile.values.firstWhere((p) => p.name == seatProfiles[seat]);
        final st = statsByProfile[profile]!;
        st.appearances++;
        if (seat == winnerSeat) st.wins++;

        final score = players[seat]['score'] as int;
        st.totalScore += score;
        st.scores.add(score);

        final pokerEntries = players[seat]['poker_entries'] as int;
        final seqEntries = players[seat]['sequence_entries'] as int;
        final fullEntries = players[seat]['full_entries'] as int;
        final seqFromHand = players[seat]['sequence_from_hand'] as int;
        final fullFromHand = players[seat]['full_from_hand'] as int;
        final royal = players[seat]['royal_poker_entries'] as int;

        st.totalPokerEntries += pokerEntries;
        st.totalSequenceEntries += seqEntries;
        st.totalFullEntries += fullEntries;
        st.totalSequenceFromHand += seqFromHand;
        st.totalFullFromHand += fullFromHand;

        totalPokerEntries += pokerEntries;
        totalSequenceEntries += seqEntries;
        totalFullEntries += fullEntries;
        totalSequenceFromHand += seqFromHand;
        totalFullFromHand += fullFromHand;
        totalRoyalPokerEntries += royal;
      }

      perGame.add(gameResult);
    } catch (e) {
      errors++;
      perGame.add({
        'game_index': gameIdx,
        'error': e.toString(),
      });
    }
  }

  sw.stop();

  final avgMoves = completedGames == 0 ? 0.0 : totalMoves / completedGames;
  final avgMsPerGame = completedGames == 0 ? 0.0 : sw.elapsedMilliseconds / completedGames;

  final runSummary = {
    'run_id': runId,
    'timestamp_utc': DateTime.now().toUtc().toIso8601String(),
    'config': {
      'games': cfg.games,
      'seed': cfg.seed,
      'max_moves': cfg.maxMoves,
      'mode': cfg.mode,
      'mirror_profile': cfg.mirrorProfile.name,
      'players_per_game': 4,
      'profiles_pool': [for (final p in profiles) p.name],
    },
    'integrity': {
      'completed_games': completedGames,
      'errors': errors,
      'valid_rate': cfg.games == 0 ? 0.0 : completedGames / cfg.games,
    },
    'performance': {
      'elapsed_ms': sw.elapsedMilliseconds,
      'avg_ms_per_game': avgMsPerGame,
      'total_moves': totalMoves,
      'avg_moves_per_game': avgMoves,
    },
    'wins': {
      'by_profile': winsByProfile,
      'by_seat': {
        for (final entry in winsBySeat.entries) '${entry.key}': entry.value,
      },
    },
    'combos': {
      'total_poker_entries': totalPokerEntries,
      'total_royal_poker_entries': totalRoyalPokerEntries,
      'total_sequence_entries': totalSequenceEntries,
      'total_full_entries': totalFullEntries,
      'total_sequence_from_hand': totalSequenceFromHand,
      'total_full_from_hand': totalFullFromHand,
      'avg_poker_per_game': completedGames == 0 ? 0.0 : totalPokerEntries / completedGames,
      'avg_sequence_per_game': completedGames == 0 ? 0.0 : totalSequenceEntries / completedGames,
      'avg_full_per_game': completedGames == 0 ? 0.0 : totalFullEntries / completedGames,
      'avg_sequence_from_hand_per_game': completedGames == 0 ? 0.0 : totalSequenceFromHand / completedGames,
      'avg_full_from_hand_per_game': completedGames == 0 ? 0.0 : totalFullFromHand / completedGames,
    },
    'profiles': {
      for (final p in profiles) p.name: statsByProfile[p]!.toJson(),
    },
    'per_game': perGame,
  };

  final outDir = Directory('output/simulations');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  final jsonFile = File('output/simulations/${runId}.json');
  jsonFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(runSummary));

  final csvFile = File('output/simulations/${runId}_summary.csv');
  csvFile.writeAsStringSync(_buildCsv(runId, cfg, completedGames, errors, avgMoves, avgMsPerGame, statsByProfile));

  stdout.writeln('Stress simulation finished.');
  stdout.writeln('Run ID: $runId');
  stdout.writeln('Games requested: ${cfg.games}');
  stdout.writeln('Games completed: $completedGames');
  stdout.writeln('Errors: $errors');
  stdout.writeln('Elapsed: ${sw.elapsedMilliseconds} ms');
  stdout.writeln('Avg/game: ${avgMsPerGame.toStringAsFixed(2)} ms');
  stdout.writeln('JSON: ${jsonFile.path}');
  stdout.writeln('CSV: ${csvFile.path}');
}

Map<String, dynamic> _simulateOneGame({
  required int gameIndex,
  required int gameSeed,
  required int maxMoves,
  required _RunConfig cfg,
}) {
  final rng = Random(gameSeed);

  final seatProfiles = _buildSeatProfiles(cfg, gameIndex, rng);

  final names = [for (var i = 0; i < 4; i++) 'AI${i + 1}'];
  final aiMap = {
    for (var i = 0; i < 4; i++) i: seatProfiles[i],
  };

  var state = createGame(names, random: Random(rng.nextInt(1 << 31)));
  var moves = 0;

  while (!state.gameOver && moves < maxMoves) {
    final currentProfile = aiMap[state.currentPlayerIndex]!;
    final action = chooseAction(state, currentProfile);
    state = applyAction(state, action, random: Random(rng.nextInt(1 << 31)));
    moves++;
  }

  if (!state.gameOver) {
    throw StateError('Game did not finish within maxMoves=$maxMoves');
  }

  final scores = <int>[];
  for (var i = 0; i < state.players.length; i++) {
    scores.add(calculateTotalScore(
      players: state.players,
      playerIndex: i,
      closedBy: state.closedBy,
    ));
  }

  var winnerSeat = 0;
  for (var i = 1; i < scores.length; i++) {
    if (scores[i] > scores[winnerSeat]) {
      winnerSeat = i;
    }
  }

  final players = <Map<String, dynamic>>[];
  for (var i = 0; i < state.players.length; i++) {
    final card = state.players[i].scoreCard;
    final seqFromHand = card.sequenceEntries.where((e) => e.fromHand).length;
    final fullFromHand = card.fullenEntries.where((e) => e.fromHand).length;
    final royalEntries = card.pokerEntries.where((e) => e.score >= 200).length;

    players.add({
      'seat': i,
      'name': state.players[i].name,
      'profile': seatProfiles[i].name,
      'score': scores[i],
      'poker_entries': card.pokerEntries.length,
      'royal_poker_entries': royalEntries,
      'sequence_entries': card.sequenceEntries.length,
      'full_entries': card.fullenEntries.length,
      'sequence_from_hand': seqFromHand,
      'full_from_hand': fullFromHand,
    });
  }

  return {
    'game_index': gameIndex,
    'seed': gameSeed,
    'moves': moves,
    'winner_seat': winnerSeat,
    'winner_profile': seatProfiles[winnerSeat].name,
    'seat_profiles': [for (final p in seatProfiles) p.name],
    'players': players,
  };
}

List<AiProfile> _buildSeatProfiles(_RunConfig cfg, int gameIndex, Random rng) {
  if (cfg.mode == 'mirror') {
    return [
      cfg.mirrorProfile,
      cfg.mirrorProfile,
      cfg.mirrorProfile,
      cfg.mirrorProfile,
    ];
  }

  // mixed-fair: each profile appears exactly once and rotates seats by game.
  final base = <AiProfile>[
    AiProfile.balanced,
    AiProfile.aggressive,
    AiProfile.cautious,
    AiProfile.dreamer,
  ];
  final shift = gameIndex % base.length;
  final rotated = [
    for (var i = 0; i < base.length; i++) base[(i + shift) % base.length],
  ];

  // Optional random mirror of rotation pattern to avoid deterministic rhythm.
  if (rng.nextBool()) {
    return List<AiProfile>.from(rotated.reversed);
  }
  return rotated;
}

String _buildCsv(
  String runId,
  _RunConfig cfg,
  int completedGames,
  int errors,
  double avgMoves,
  double avgMsPerGame,
  Map<AiProfile, _ProfileStats> statsByProfile,
) {
  final b = StringBuffer();
  b.writeln(
      'run_id,games_requested,games_completed,errors,profile,appearances,wins,win_rate,avg_score,median_score,std_score,avg_poker_entries,avg_sequence_entries,avg_full_entries,avg_seq_from_hand,avg_full_from_hand,avg_moves_per_game,avg_ms_per_game');

  for (final profile in AiProfile.values) {
    final st = statsByProfile[profile]!;
    final winRate = st.appearances == 0 ? 0.0 : st.wins / st.appearances;
    final avgScore = st.appearances == 0 ? 0.0 : st.totalScore / st.appearances;

    b.writeln([
      runId,
      cfg.games,
      completedGames,
      errors,
      profile.name,
      st.appearances,
      st.wins,
      winRate.toStringAsFixed(6),
      avgScore.toStringAsFixed(3),
      _median(st.scores).toStringAsFixed(3),
      _stdDev(st.scores).toStringAsFixed(3),
      (st.appearances == 0 ? 0.0 : st.totalPokerEntries / st.appearances).toStringAsFixed(3),
      (st.appearances == 0 ? 0.0 : st.totalSequenceEntries / st.appearances).toStringAsFixed(3),
      (st.appearances == 0 ? 0.0 : st.totalFullEntries / st.appearances).toStringAsFixed(3),
      (st.appearances == 0 ? 0.0 : st.totalSequenceFromHand / st.appearances).toStringAsFixed(3),
      (st.appearances == 0 ? 0.0 : st.totalFullFromHand / st.appearances).toStringAsFixed(3),
      avgMoves.toStringAsFixed(3),
      avgMsPerGame.toStringAsFixed(3),
    ].join(','));
  }

  return b.toString();
}

_RunConfig _parseArgs(List<String> args) {
  var games = 1000;
  var seed = 20260423;
  var maxMoves = 2500;
  var mode = 'mixed-fair';
  var mirrorProfile = AiProfile.balanced;

  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--games' && i + 1 < args.length) {
      games = int.tryParse(args[++i]) ?? games;
    } else if (a == '--seed' && i + 1 < args.length) {
      seed = int.tryParse(args[++i]) ?? seed;
    } else if (a == '--max-moves' && i + 1 < args.length) {
      maxMoves = int.tryParse(args[++i]) ?? maxMoves;
    } else if (a == '--mode' && i + 1 < args.length) {
      final requested = args[++i].toLowerCase();
      if (requested == 'mixed-fair' || requested == 'mirror') {
        mode = requested;
      }
    } else if (a == '--profile' && i + 1 < args.length) {
      final requested = args[++i].toLowerCase();
      for (final p in AiProfile.values) {
        if (p.name.toLowerCase() == requested) {
          mirrorProfile = p;
          break;
        }
      }
    }
  }

  return _RunConfig(
    games: games,
    seed: seed,
    maxMoves: maxMoves,
    mode: mode,
    mirrorProfile: mirrorProfile,
  );
}

String _buildRunId() {
  final now = DateTime.now().toUtc();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${now.year}${two(now.month)}${two(now.day)}_${two(now.hour)}${two(now.minute)}${two(now.second)}';
}

double _median(List<int> values) {
  if (values.isEmpty) return 0.0;
  final sorted = List<int>.from(values)..sort();
  final mid = sorted.length ~/ 2;
  if (sorted.length.isOdd) {
    return sorted[mid].toDouble();
  }
  return (sorted[mid - 1] + sorted[mid]) / 2.0;
}

double _stdDev(List<int> values) {
  if (values.isEmpty) return 0.0;
  final n = values.length;
  var sum = 0.0;
  for (final v in values) {
    sum += v;
  }
  final mean = sum / n;
  var varSum = 0.0;
  for (final v in values) {
    final d = v - mean;
    varSum += d * d;
  }
  return sqrt(varSum / n);
}
