import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../engine/ai_profiles.dart';
import '../../engine/constants.dart';
import '../../engine/game_engine.dart';
import '../../engine/models.dart';

class SavedMatch {
  final GameState state;
  final Map<int, AiProfile> aiProfiles;

  const SavedMatch({required this.state, required this.aiProfiles});
}

/// Local persistence for game snapshots (resume support).
class GamePersistence {
  static const _savedMatchKey = 'game.savedMatch.v1';

  static Future<void> saveMatch({
    required GameState state,
    required Map<int, AiProfile> aiProfiles,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'state': _encodeState(state),
      'aiProfiles': {
        for (final entry in aiProfiles.entries) '${entry.key}': entry.value.name,
      },
    };
    await prefs.setString(_savedMatchKey, jsonEncode(payload));
  }

  static Future<SavedMatch?> loadMatch() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_savedMatchKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final stateMap = json['state'] as Map<String, dynamic>;
      final profilesMap = (json['aiProfiles'] as Map<String, dynamic>? ?? {});

      final state = _decodeState(stateMap);
      final aiProfiles = <int, AiProfile>{};
      for (final entry in profilesMap.entries) {
        final idx = int.tryParse(entry.key);
        final profileName = entry.value as String?;
        if (idx == null || profileName == null) continue;
        AiProfile? profile;
        for (final value in AiProfile.values) {
          if (value.name == profileName) {
            profile = value;
            break;
          }
        }
        if (profile != null) {
          aiProfiles[idx] = profile;
        }
      }

      return SavedMatch(state: state, aiProfiles: aiProfiles);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> hasSavedMatch() async {
    final match = await loadMatch();
    return match != null;
  }

  static Future<void> clearSavedMatch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedMatchKey);
  }

  static Map<String, dynamic> _encodeState(GameState state) {
    return {
      'players': [for (final p in state.players) _encodePlayer(p)],
      'currentPlayerIndex': state.currentPlayerIndex,
      'currentRollIndex': state.currentRollIndex,
      'dice': [for (final d in state.dice) _encodeDie(d)],
      'closedLines': [for (final l in state.closedLines) l.name],
      'closedSpecialLines': [for (final l in state.closedSpecialLines) l.name],
      'scoredThisTurn': [for (final l in state.scoredThisTurn) l.name],
      'gameOver': state.gameOver,
      'accumulationMode': state.accumulationMode,
      'accumulationTarget': state.accumulationTarget?.name,
      'accumulationColumn': state.accumulationColumn,
      'accumulationRunningTotal': state.accumulationRunningTotal,
      'closedBy': {
        for (final entry in state.closedBy.entries) entry.key.name: entry.value,
      },
      'closedSpecialBy': {
        for (final entry in state.closedSpecialBy.entries)
          entry.key.name: entry.value,
      },
      'scoredOnPreviousRoll': state.scoredOnPreviousRoll,
    };
  }

  static GameState _decodeState(Map<String, dynamic> json) {
    return GameState(
      players: [
        for (final p in (json['players'] as List<dynamic>))
          _decodePlayer(p as Map<String, dynamic>),
      ],
      currentPlayerIndex: (json['currentPlayerIndex'] as num?)?.toInt() ?? 0,
      currentRollIndex: (json['currentRollIndex'] as num?)?.toInt() ?? 0,
      dice: [
        for (final d in (json['dice'] as List<dynamic>))
          _decodeDie(d as Map<String, dynamic>),
      ],
      closedLines: {
        for (final name in (json['closedLines'] as List<dynamic>? ?? []))
          FigureLine.values.firstWhere((l) => l.name == name),
      },
      closedSpecialLines: {
        for (final name in (json['closedSpecialLines'] as List<dynamic>? ?? []))
          SpecialLine.values.firstWhere((l) => l.name == name),
      },
      scoredThisTurn: {
        for (final name in (json['scoredThisTurn'] as List<dynamic>? ?? []))
          FigureLine.values.firstWhere((l) => l.name == name),
      },
      gameOver: (json['gameOver'] as bool?) ?? false,
      accumulationMode: (json['accumulationMode'] as bool?) ?? false,
      accumulationTarget: _figureLineOrNull(json['accumulationTarget'] as String?),
      accumulationColumn: (json['accumulationColumn'] as num?)?.toInt(),
      accumulationRunningTotal:
          (json['accumulationRunningTotal'] as num?)?.toInt() ?? 0,
      closedBy: {
        for (final entry in (json['closedBy'] as Map<String, dynamic>? ?? {}).entries)
          FigureLine.values.firstWhere((l) => l.name == entry.key):
              (entry.value as num).toInt(),
      },
      closedSpecialBy: {
        for (final entry in (json['closedSpecialBy'] as Map<String, dynamic>? ?? {})
            .entries)
          SpecialLine.values.firstWhere((l) => l.name == entry.key):
              (entry.value as num).toInt(),
      },
      scoredOnPreviousRoll: (json['scoredOnPreviousRoll'] as bool?) ?? false,
    );
  }

  static Player _decodePlayer(Map<String, dynamic> json) {
    return Player(
      name: json['name'] as String,
      index: (json['index'] as num).toInt(),
      scoreCard: _decodeScoreCard(json['scoreCard'] as Map<String, dynamic>),
    );
  }

  static Map<String, dynamic> _encodePlayer(Player player) {
    return {
      'name': player.name,
      'index': player.index,
      'scoreCard': _encodeScoreCard(player.scoreCard),
    };
  }

  static ScoreCard _decodeScoreCard(Map<String, dynamic> json) {
    final figureRaw = json['figureScores'] as Map<String, dynamic>;
    final figureScores = <FigureLine, List<int?>>{};

    for (final line in FigureLine.values) {
      final rawValues = (figureRaw[line.name] as List<dynamic>? ?? <dynamic>[])
          .map((v) => (v as num?)?.toInt())
          .toList();
      final values = List<int?>.filled(columnsPerLine, null);
      for (var i = 0; i < rawValues.length && i < columnsPerLine; i++) {
        values[i] = rawValues[i];
      }
      figureScores[line] = values;
    }

    return ScoreCard(
      figureScores: figureScores,
      sequenceEntries: _decodeEntries(json['sequenceEntries'] as List<dynamic>? ?? []),
      fullenEntries: _decodeEntries(json['fullenEntries'] as List<dynamic>? ?? []),
      pokerEntries: _decodeEntries(json['pokerEntries'] as List<dynamic>? ?? []),
    );
  }

  static Map<String, dynamic> _encodeScoreCard(ScoreCard card) {
    return {
      'figureScores': {
        for (final line in FigureLine.values)
          line.name: [for (final value in card.figureScores[line]!) value],
      },
      'sequenceEntries': [for (final e in card.sequenceEntries) _encodeEntry(e)],
      'fullenEntries': [for (final e in card.fullenEntries) _encodeEntry(e)],
      'pokerEntries': [for (final e in card.pokerEntries) _encodeEntry(e)],
    };
  }

  static List<SpecialEntry> _decodeEntries(List<dynamic> raw) {
    return [
      for (final e in raw)
        SpecialEntry(
          score: ((e as Map<String, dynamic>)['score'] as num).toInt(),
          fromHand: e['fromHand'] as bool,
        ),
    ];
  }

  static Map<String, dynamic> _encodeEntry(SpecialEntry entry) {
    return {
      'score': entry.score,
      'fromHand': entry.fromHand,
    };
  }

  static Die _decodeDie(Map<String, dynamic> json) {
    return Die(
      face: DieFace.values.firstWhere((f) => f.name == json['face']),
      held: (json['held'] as bool?) ?? false,
    );
  }

  static Map<String, dynamic> _encodeDie(Die die) {
    return {
      'face': die.face.name,
      'held': die.held,
    };
  }

  static FigureLine? _figureLineOrNull(String? name) {
    if (name == null) return null;
    for (final line in FigureLine.values) {
      if (line.name == name) return line;
    }
    return null;
  }
}
