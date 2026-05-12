import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../engine/ai_profiles.dart';
import '../../engine/game_engine.dart';
import '../../engine/models.dart';
import '../../engine/scoring.dart';

/// Achievement identifiers. Keep stable for persistence compatibility.
enum AchievementId {
  // Core set
  firstWin,
  hatTrick,
  invictus,
  royalPoker,
  pokerFace,
  piladaFromHand,
  perfectStraight,
  marathoner,
  wall,
  closer,
  accumulator,
  clutchScorer,
  strategist,
  survivor,
  aiSlayer,
  closeCall,
  dominator,
  collector,
  legend,
  chameleon,

  // Poker lifetime milestones
  poker10,
  poker30,
  poker50,
  poker100,
  poker200,
  poker500,

  // Sequence (from hand) lifetime milestones
  seqFromHand100,
  seqFromHand200,
  seqFromHand500,
  seqFromHand1000,
  seqFromHand3000,
  seqFromHand10000,

  // Full house (from hand) lifetime milestones
  fullFromHand100,
  fullFromHand200,
  fullFromHand500,
  fullFromHand1000,
  fullFromHand3000,
  fullFromHand10000,

  // Five of a kind with all 6 faces over time
  allFacesFiveOfKind,
}

class AchievementDefinition {
  final AchievementId id;
  final String title;
  final String description;
  final bool implemented;

  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    this.implemented = true,
  });
}

class RollObservation {
  final List<DieFace> faces;
  final bool fromHand;

  const RollObservation({required this.faces, required this.fromHand});
}

class AchievementSnapshot {
  final Set<AchievementId> unlocked;
  final int totalPoker;
  final int totalSeqFromHand;
  final int totalFullFromHand;
  final Set<DieFace> fiveKindFacesSeen;

  const AchievementSnapshot({
    required this.unlocked,
    required this.totalPoker,
    required this.totalSeqFromHand,
    required this.totalFullFromHand,
    required this.fiveKindFacesSeen,
  });
}

class AchievementsService {
  static const _keyUnlocked = 'achievements.unlocked.v1';
  static const _keyTotalPoker = 'achievements.totalPoker.v1';
  static const _keyTotalSeqFromHand = 'achievements.totalSeqFromHand.v1';
  static const _keyTotalFullFromHand = 'achievements.totalFullFromHand.v1';
  static const _keyConsecutiveHumanWins = 'achievements.consecutiveHumanWins.v1';
  static const _keyFiveKindFacesSeen = 'achievements.fiveKindFacesSeen.v1';
  static const _keyProfilesBeaten = 'achievements.profilesBeaten.v1';

  static const List<AchievementDefinition> definitions = [
    AchievementDefinition(
      id: AchievementId.firstWin,
      title: 'Primeira Vitoria',
      description: 'Ganhar 1 jogo.',
    ),
    AchievementDefinition(
      id: AchievementId.hatTrick,
      title: 'Hat-trick',
      description: 'Ganhar 3 jogos seguidos.',
    ),
    AchievementDefinition(
      id: AchievementId.invictus,
      title: 'Invicto',
      description: 'Vencer sem o adversário alguma vez estar na frente.',
    ),
    AchievementDefinition(
      id: AchievementId.royalPoker,
      title: 'Royal Poker',
      description: 'Marcar Royal Poker (200 pts).',
    ),
    AchievementDefinition(
      id: AchievementId.pokerFace,
      title: 'Poker Face',
      description: 'Marcar 3 pokers no mesmo jogo.',
    ),
    AchievementDefinition(
      id: AchievementId.piladaFromHand,
      title: 'Cinco Noves de Mao',
      description: 'Fazer 5 noves de mao num lancamento.',
    ),
    AchievementDefinition(
      id: AchievementId.perfectStraight,
      title: 'Sequencia Perfeita',
      description: 'Fazer sequencia maxima de mao num lancamento.',
    ),
    AchievementDefinition(
      id: AchievementId.marathoner,
      title: 'Maratonista',
      description: 'Completar 5 colunas da mesma linha num jogo.',
    ),
    AchievementDefinition(
      id: AchievementId.wall,
      title: 'Muro',
      description: 'Fechar uma linha sem outro jogador abrir.',
    ),
    AchievementDefinition(
      id: AchievementId.closer,
      title: 'Fechador',
      description: 'Fechar 3 linhas no mesmo jogo.',
    ),
    AchievementDefinition(
      id: AchievementId.accumulator,
      title: 'Acumulador',
      description: 'Registar 20+ pontos numa unica celula de figura.',
    ),
    AchievementDefinition(
      id: AchievementId.clutchScorer,
      title: 'Tudo ou Nada',
      description: 'Vencer estando a perder por 50+ pontos antes do último turno.',
    ),
    AchievementDefinition(
      id: AchievementId.strategist,
      title: 'Estratega',
      description: 'Completar um jogo sem marcar 0 em nenhuma célula de figura.',
    ),
    AchievementDefinition(
      id: AchievementId.survivor,
      title: 'Última Oportunidade',
      description: 'Vencer quando o adversário estava na frente no último turno.',
    ),
    AchievementDefinition(
      id: AchievementId.aiSlayer,
      title: 'IA Slayer',
      description: 'Ganhar contra 3 AI.',
    ),
    AchievementDefinition(
      id: AchievementId.closeCall,
      title: 'Equilibrio Perfeito',
      description: 'Vencer por 10 pontos ou menos.',
    ),
    AchievementDefinition(
      id: AchievementId.dominator,
      title: 'Dominador',
      description: 'Vencer por 150+ pontos.',
    ),
    AchievementDefinition(
      id: AchievementId.collector,
      title: 'Colecionador',
      description: 'Desbloquear 10 achievements.',
    ),
    AchievementDefinition(
      id: AchievementId.legend,
      title: 'Lenda do Dipok',
      description: 'Desbloquear todos os achievements implementados.',
    ),
    AchievementDefinition(
      id: AchievementId.chameleon,
      title: 'Camaleão',
      description: 'Ganhar um jogo contra cada perfil de IA.',
    ),

    AchievementDefinition(
      id: AchievementId.poker10,
      title: 'Poker x10',
      description: 'Obter 10 pokers no total.',
    ),
    AchievementDefinition(
      id: AchievementId.poker30,
      title: 'Poker x30',
      description: 'Obter 30 pokers no total.',
    ),
    AchievementDefinition(
      id: AchievementId.poker50,
      title: 'Poker x50',
      description: 'Obter 50 pokers no total.',
    ),
    AchievementDefinition(
      id: AchievementId.poker100,
      title: 'Poker x100',
      description: 'Obter 100 pokers no total.',
    ),
    AchievementDefinition(
      id: AchievementId.poker200,
      title: 'Poker x200',
      description: 'Obter 200 pokers no total.',
    ),
    AchievementDefinition(
      id: AchievementId.poker500,
      title: 'Poker x500',
      description: 'Obter 500 pokers no total.',
    ),

    AchievementDefinition(
      id: AchievementId.seqFromHand100,
      title: 'Seq de Mao x100',
      description: 'Obter 100 sequencias de mao no total.',
    ),
    AchievementDefinition(
      id: AchievementId.seqFromHand200,
      title: 'Seq de Mao x200',
      description: 'Obter 200 sequencias de mao no total.',
    ),
    AchievementDefinition(
      id: AchievementId.seqFromHand500,
      title: 'Seq de Mao x500',
      description: 'Obter 500 sequencias de mao no total.',
    ),
    AchievementDefinition(
      id: AchievementId.seqFromHand1000,
      title: 'Seq de Mao x1000',
      description: 'Obter 1000 sequencias de mao no total.',
    ),
    AchievementDefinition(
      id: AchievementId.seqFromHand3000,
      title: 'Seq de Mao x3000',
      description: 'Obter 3000 sequencias de mao no total.',
    ),
    AchievementDefinition(
      id: AchievementId.seqFromHand10000,
      title: 'Seq de Mao x10000',
      description: 'Obter 10000 sequencias de mao no total.',
    ),

    AchievementDefinition(
      id: AchievementId.fullFromHand100,
      title: 'Full de Mao x100',
      description: 'Obter 100 full house de mao no total.',
    ),
    AchievementDefinition(
      id: AchievementId.fullFromHand200,
      title: 'Full de Mao x200',
      description: 'Obter 200 full house de mao no total.',
    ),
    AchievementDefinition(
      id: AchievementId.fullFromHand500,
      title: 'Full de Mao x500',
      description: 'Obter 500 full house de mao no total.',
    ),
    AchievementDefinition(
      id: AchievementId.fullFromHand1000,
      title: 'Full de Mao x1000',
      description: 'Obter 1000 full house de mao no total.',
    ),
    AchievementDefinition(
      id: AchievementId.fullFromHand3000,
      title: 'Full de Mao x3000',
      description: 'Obter 3000 full house de mao no total.',
    ),
    AchievementDefinition(
      id: AchievementId.fullFromHand10000,
      title: 'Full de Mao x10000',
      description: 'Obter 10000 full house de mao no total.',
    ),

    AchievementDefinition(
      id: AchievementId.allFacesFiveOfKind,
      title: 'Todas as Faces x5',
      description: 'Fazer 5 iguais com as 6 faces (A, K, Q, J, 10, 9).',
    ),
  ];

  static Set<AchievementId> _implementedIds() {
    return {
      for (final d in definitions)
        if (d.implemented) d.id,
    };
  }

  static Future<AchievementSnapshot> getSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = _readUnlocked(prefs);
    return AchievementSnapshot(
      unlocked: unlocked,
      totalPoker: prefs.getInt(_keyTotalPoker) ?? 0,
      totalSeqFromHand: prefs.getInt(_keyTotalSeqFromHand) ?? 0,
      totalFullFromHand: prefs.getInt(_keyTotalFullFromHand) ?? 0,
      fiveKindFacesSeen: _readFaces(prefs),
    );
  }

  static Future<List<AchievementId>> processCompletedMatch({
    required GameState state,
    required Map<int, AiProfile> aiProfiles,
    required List<RollObservation> rollObservations,
    List<List<int>> scoreSnapshots = const [],
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = _readUnlocked(prefs);
    final newlyUnlocked = <AchievementId>[];

    void unlock(AchievementId id) {
      if (!unlocked.contains(id)) {
        unlocked.add(id);
        newlyUnlocked.add(id);
      }
    }

    final scores = <int>[];
    for (var i = 0; i < state.players.length; i++) {
      scores.add(calculateTotalScore(
        players: state.players,
        playerIndex: i,
        closedBy: state.closedBy,
      ));
    }

    var winnerIdx = 0;
    var winnerScore = scores.first;
    for (var i = 1; i < scores.length; i++) {
      if (scores[i] > winnerScore) {
        winnerScore = scores[i];
        winnerIdx = i;
      }
    }

    var secondScore = -1;
    for (var i = 0; i < scores.length; i++) {
      if (i == winnerIdx) continue;
      if (scores[i] > secondScore) secondScore = scores[i];
    }
    final gap = secondScore >= 0 ? (winnerScore - secondScore) : winnerScore;

    final winnerIsHuman = !aiProfiles.containsKey(winnerIdx);

    // Camaleão: beat each AI profile at least once
    if (winnerIsHuman) {
      final profilesBeaten = _readProfilesBeaten(prefs);
      for (final entry in aiProfiles.entries) {
        if (entry.key != winnerIdx) profilesBeaten.add(entry.value.name);
      }
      await prefs.setStringList(_keyProfilesBeaten, profilesBeaten.toList());
      if (AiProfile.values.every((p) => profilesBeaten.contains(p.name))) {
        unlock(AchievementId.chameleon);
      }
    }

    if (winnerIsHuman) {
      unlock(AchievementId.firstWin);
      final streak = (prefs.getInt(_keyConsecutiveHumanWins) ?? 0) + 1;
      await prefs.setInt(_keyConsecutiveHumanWins, streak);
      if (streak >= 3) unlock(AchievementId.hatTrick);

      if (state.players.length == 4) {
        var allOthersAi = true;
        for (var i = 0; i < state.players.length; i++) {
          if (i == winnerIdx) continue;
          if (!aiProfiles.containsKey(i)) {
            allOthersAi = false;
            break;
          }
        }
        if (allOthersAi) unlock(AchievementId.aiSlayer);
      }

      if (gap <= 10) unlock(AchievementId.closeCall);
      if (gap >= 150) unlock(AchievementId.dominator);

      // Estratega: no 0 in any figure cell
      var noZeros = true;
      outer:
      for (final line in FigureLine.values) {
        for (final cell in state.players[winnerIdx].scoreCard.figureScores[line]!) {
          if (cell == 0) {
            noZeros = false;
            break outer;
          }
        }
      }
      if (noZeros) unlock(AchievementId.strategist);

      // Score-snapshot achievements
      if (scoreSnapshots.isNotEmpty) {
        // Invictus: never behind at any recorded snapshot
        var neverBehind = true;
        for (final snap in scoreSnapshots) {
          if (snap.length <= winnerIdx) continue;
          final myScore = snap[winnerIdx];
          for (var i = 0; i < snap.length; i++) {
            if (i == winnerIdx) continue;
            if (i < snap.length && snap[i] > myScore) {
              neverBehind = false;
              break;
            }
          }
          if (!neverBehind) break;
        }
        if (neverBehind) unlock(AchievementId.invictus);

        // Tudo ou Nada: at some snapshot winner was down by 50+
        for (final snap in scoreSnapshots) {
          if (snap.length <= winnerIdx) continue;
          final myScore = snap[winnerIdx];
          for (var i = 0; i < snap.length; i++) {
            if (i == winnerIdx) continue;
            if (i < snap.length && snap[i] >= myScore + 50) {
              unlock(AchievementId.clutchScorer);
              break;
            }
          }
        }

        // Última Oportunidade: trailing in the last snapshot
        final lastSnap = scoreSnapshots.last;
        if (lastSnap.length > winnerIdx) {
          final myScore = lastSnap[winnerIdx];
          for (var i = 0; i < lastSnap.length; i++) {
            if (i == winnerIdx) continue;
            if (i < lastSnap.length && lastSnap[i] > myScore) {
              unlock(AchievementId.survivor);
              break;
            }
          }
        }
      }
    } else {
      await prefs.setInt(_keyConsecutiveHumanWins, 0);
    }

    var totalPoker = prefs.getInt(_keyTotalPoker) ?? 0;
    var totalSeqFromHand = prefs.getInt(_keyTotalSeqFromHand) ?? 0;
    var totalFullFromHand = prefs.getInt(_keyTotalFullFromHand) ?? 0;

    var pokerInMatch = 0;
    var seqFromHandInMatch = 0;
    var fullFromHandInMatch = 0;

    for (final player in state.players) {
      final pokerEntries = player.scoreCard.pokerEntries;
      pokerInMatch += pokerEntries.length;

      final seqEntries = player.scoreCard.sequenceEntries;
      for (final e in seqEntries) {
        if (e.fromHand) seqFromHandInMatch++;
      }

      final fullEntries = player.scoreCard.fullenEntries;
      for (final e in fullEntries) {
        if (e.fromHand) fullFromHandInMatch++;
      }

      final hasRoyal = pokerEntries.any((e) => e.score >= 200);
      if (hasRoyal) unlock(AchievementId.royalPoker);
      if (pokerEntries.length >= 3) unlock(AchievementId.pokerFace);

      for (final line in FigureLine.values) {
        if (player.scoreCard.isLineComplete(line)) {
          unlock(AchievementId.marathoner);
          break;
        }
      }

      // Proxy for high accumulation outcome (single figure cell >=20)
      var hasBigFigureCell = false;
      for (final line in FigureLine.values) {
        for (final cell in player.scoreCard.figureScores[line]!) {
          if ((cell ?? 0) >= 20) {
            hasBigFigureCell = true;
            break;
          }
        }
        if (hasBigFigureCell) break;
      }
      if (hasBigFigureCell) unlock(AchievementId.accumulator);
    }

    totalPoker += pokerInMatch;
    totalSeqFromHand += seqFromHandInMatch;
    totalFullFromHand += fullFromHandInMatch;

    await prefs.setInt(_keyTotalPoker, totalPoker);
    await prefs.setInt(_keyTotalSeqFromHand, totalSeqFromHand);
    await prefs.setInt(_keyTotalFullFromHand, totalFullFromHand);

    _unlockThreshold(totalPoker, 10, AchievementId.poker10, unlock);
    _unlockThreshold(totalPoker, 30, AchievementId.poker30, unlock);
    _unlockThreshold(totalPoker, 50, AchievementId.poker50, unlock);
    _unlockThreshold(totalPoker, 100, AchievementId.poker100, unlock);
    _unlockThreshold(totalPoker, 200, AchievementId.poker200, unlock);
    _unlockThreshold(totalPoker, 500, AchievementId.poker500, unlock);

    _unlockThreshold(totalSeqFromHand, 100, AchievementId.seqFromHand100, unlock);
    _unlockThreshold(totalSeqFromHand, 200, AchievementId.seqFromHand200, unlock);
    _unlockThreshold(totalSeqFromHand, 500, AchievementId.seqFromHand500, unlock);
    _unlockThreshold(totalSeqFromHand, 1000, AchievementId.seqFromHand1000, unlock);
    _unlockThreshold(totalSeqFromHand, 3000, AchievementId.seqFromHand3000, unlock);
    _unlockThreshold(totalSeqFromHand, 10000, AchievementId.seqFromHand10000, unlock);

    _unlockThreshold(totalFullFromHand, 100, AchievementId.fullFromHand100, unlock);
    _unlockThreshold(totalFullFromHand, 200, AchievementId.fullFromHand200, unlock);
    _unlockThreshold(totalFullFromHand, 500, AchievementId.fullFromHand500, unlock);
    _unlockThreshold(totalFullFromHand, 1000, AchievementId.fullFromHand1000, unlock);
    _unlockThreshold(totalFullFromHand, 3000, AchievementId.fullFromHand3000, unlock);
    _unlockThreshold(totalFullFromHand, 10000, AchievementId.fullFromHand10000, unlock);

    // Muro: line closed by winner while others never opened.
    for (final entry in state.closedBy.entries) {
      final line = entry.key;
      final closer = entry.value;
      var anyoneElseOpened = false;
      for (var p = 0; p < state.players.length; p++) {
        if (p == closer) continue;
        if (state.players[p].scoreCard.filledColumns(line) > 0) {
          anyoneElseOpened = true;
          break;
        }
      }
      if (!anyoneElseOpened) {
        unlock(AchievementId.wall);
        break;
      }
    }

    // Fechador: closed >=3 lines in same match (figure + special)
    final closedCountByPlayer = <int, int>{};
    for (final idx in state.closedBy.values) {
      closedCountByPlayer[idx] = (closedCountByPlayer[idx] ?? 0) + 1;
    }
    for (final idx in state.closedSpecialBy.values) {
      closedCountByPlayer[idx] = (closedCountByPlayer[idx] ?? 0) + 1;
    }
    for (final c in closedCountByPlayer.values) {
      if (c >= 3) {
        unlock(AchievementId.closer);
        break;
      }
    }

    // Roll-driven achievements
    final facesSeen = _readFaces(prefs);
    for (final obs in rollObservations) {
      if (obs.faces.length != 5) continue;
      final allSame = obs.faces.every((f) => f == obs.faces.first);
      if (allSame) {
        facesSeen.add(obs.faces.first);
        if (obs.fromHand && obs.faces.first == DieFace.nine) {
          unlock(AchievementId.piladaFromHand);
        }
      }

      if (obs.fromHand && _isMaxStraight(obs.faces)) {
        unlock(AchievementId.perfectStraight);
      }
    }

    if (facesSeen.length == DieFace.values.length) {
      unlock(AchievementId.allFacesFiveOfKind);
    }
    await prefs.setStringList(
      _keyFiveKindFacesSeen,
      [for (final f in facesSeen) f.name],
    );

    if (unlocked.length >= 10) {
      unlock(AchievementId.collector);
    }

    final implemented = _implementedIds();
    final allImplementedUnlocked = implemented.every(unlocked.contains);
    if (allImplementedUnlocked) {
      unlock(AchievementId.legend);
    }

    await prefs.setStringList(
      _keyUnlocked,
      [for (final id in unlocked) id.name],
    );

    return newlyUnlocked;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUnlocked);
    await prefs.remove(_keyTotalPoker);
    await prefs.remove(_keyTotalSeqFromHand);
    await prefs.remove(_keyTotalFullFromHand);
    await prefs.remove(_keyConsecutiveHumanWins);
    await prefs.remove(_keyFiveKindFacesSeen);
    await prefs.remove(_keyProfilesBeaten);
  }

  static bool _isMaxStraight(List<DieFace> faces) {
    final set = faces.toSet();
    return set.length == 5 &&
        set.contains(DieFace.ace) &&
        set.contains(DieFace.king) &&
        set.contains(DieFace.queen) &&
        set.contains(DieFace.jack) &&
        set.contains(DieFace.ten);
  }

  static void _unlockThreshold(
    int value,
    int threshold,
    AchievementId id,
    void Function(AchievementId id) unlock,
  ) {
    if (value >= threshold) {
      unlock(id);
    }
  }

  static Set<AchievementId> _readUnlocked(SharedPreferences prefs) {
    final raw = prefs.getStringList(_keyUnlocked) ?? [];
    final ids = <AchievementId>{};
    for (final name in raw) {
      for (final id in AchievementId.values) {
        if (id.name == name) {
          ids.add(id);
          break;
        }
      }
    }
    return ids;
  }

  static Set<String> _readProfilesBeaten(SharedPreferences prefs) {
    return (prefs.getStringList(_keyProfilesBeaten) ?? []).toSet();
  }

  static Set<DieFace> _readFaces(SharedPreferences prefs) {
    final raw = prefs.getStringList(_keyFiveKindFacesSeen) ?? [];
    final faces = <DieFace>{};
    for (final name in raw) {
      for (final face in DieFace.values) {
        if (face.name == name) {
          faces.add(face);
          break;
        }
      }
    }
    return faces;
  }

  static String exportDefinitionsAsJson() {
    final data = [
      for (final d in definitions)
        {
          'id': d.id.name,
          'title': d.title,
          'description': d.description,
          'implemented': d.implemented,
        },
    ];
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
