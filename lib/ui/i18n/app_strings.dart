import 'package:flutter/widgets.dart';

import '../../engine/ai_profiles.dart';
import '../services/achievements_service.dart';

/// Supported application languages.
enum AppLang { en, ptPT, ptBR, es, fr, de, it }

/// Multi-language runtime localization helper.
///
/// Covers EN, PT-PT, PT-BR, ES, FR, DE, IT.
/// Override locale is provided by [LocaleController] in main.dart.
class AppStrings {
  final Locale locale;

  const AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    return AppStrings(Localizations.localeOf(context));
  }

  AppLang get _lang {
    final code = locale.languageCode.toLowerCase();
    final country = (locale.countryCode ?? '').toUpperCase();
    if (code == 'pt') {
      return country == 'BR' ? AppLang.ptBR : AppLang.ptPT;
    }
    return switch (code) {
      'es' => AppLang.es,
      'fr' => AppLang.fr,
      'de' => AppLang.de,
      'it' => AppLang.it,
      _ => AppLang.en,
    };
  }

  // ── Core ──────────────────────────────────────────────────────────────────
  String get appTitle => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Poker de Dados',
        AppLang.es => 'Póker de Dados',
        AppLang.fr => 'Poker de Dés',
        AppLang.de => 'Würfelpoker',
        AppLang.it => 'Poker di Dadi',
        AppLang.en => 'Dice Poker',
      };

  String get setupTitle => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Configuração',
        AppLang.es => 'Configuración',
        AppLang.fr => 'Configuration',
        AppLang.de => 'Einstellungen',
        AppLang.it => 'Configurazione',
        AppLang.en => 'Setup',
      };

  String get rulesTitle => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Regras',
        AppLang.es => 'Reglas',
        AppLang.fr => 'Règles',
        AppLang.de => 'Regeln',
        AppLang.it => 'Regole',
        AppLang.en => 'Rules',
      };

  String get gameRulesAsset => switch (_lang) {
        AppLang.ptBR => 'assets/rules/rules_pt_br.md',
        AppLang.es => 'assets/rules/rules_es.md',
        AppLang.fr => 'assets/rules/rules_fr.md',
        AppLang.de => 'assets/rules/rules_de.md',
        AppLang.it => 'assets/rules/rules_it.md',
        AppLang.en => 'assets/rules/rules_en.md',
        AppLang.ptPT => 'assets/rules/rules_pt.md',
      };

  String get gameConfiguration => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Configuração do Jogo',
        AppLang.es => 'Configuración del Juego',
        AppLang.fr => 'Configuration du Jeu',
        AppLang.de => 'Spielkonfiguration',
        AppLang.it => 'Configurazione del Gioco',
        AppLang.en => 'Game Configuration',
      };

  String get players => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Jogadores',
        AppLang.es => 'Jugadores',
        AppLang.fr => 'Joueurs',
        AppLang.de => 'Spieler',
        AppLang.it => 'Giocatori',
        AppLang.en => 'Players',
      };

  String playerLabel(int index) {
    final n = index + 1;
    return switch (_lang) {
      AppLang.ptPT || AppLang.ptBR => 'Jogador $n',
      AppLang.es => 'Jugador $n',
      AppLang.fr => 'Joueur $n',
      AppLang.de => 'Spieler $n',
      AppLang.it => 'Giocatore $n',
      AppLang.en => 'Player $n',
    };
  }

  String get name => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Nome',
        AppLang.es => 'Nombre',
        AppLang.fr => 'Nom',
        AppLang.de => 'Name',
        AppLang.it => 'Nome',
        AppLang.en => 'Name',
      };

  String get aiPlayer => switch (_lang) {
        AppLang.ptPT => 'Jogador AI',
        AppLang.ptBR => 'Jogador IA',
        AppLang.es => 'Jugador IA',
        AppLang.fr => 'Joueur IA',
        AppLang.de => 'KI-Spieler',
        AppLang.it => 'Giocatore IA',
        AppLang.en => 'AI Player',
      };

  String get aiProfile => switch (_lang) {
        AppLang.ptPT => 'Perfil AI',
        AppLang.ptBR => 'Perfil IA',
        AppLang.es => 'Perfil IA',
        AppLang.fr => 'Profil IA',
        AppLang.de => 'KI-Profil',
        AppLang.it => 'Profilo IA',
        AppLang.en => 'AI Profile',
      };

  String get continueSavedGame => switch (_lang) {
        AppLang.ptPT => 'Continuar Jogo Guardado',
        AppLang.ptBR => 'Continuar Jogo Salvo',
        AppLang.es => 'Continuar Partida Guardada',
        AppLang.fr => 'Reprendre la Partie',
        AppLang.de => 'Gespeichertes Spiel fortsetzen',
        AppLang.it => 'Continua Partita Salvata',
        AppLang.en => 'Continue Saved Game',
      };

  String get startGame => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Iniciar Jogo',
        AppLang.es => 'Iniciar Juego',
        AppLang.fr => 'Démarrer le Jeu',
        AppLang.de => 'Spiel starten',
        AppLang.it => 'Avvia Gioco',
        AppLang.en => 'Start Game',
      };

  String get noSavedGame => switch (_lang) {
        AppLang.ptPT => 'Nenhum jogo guardado encontrado.',
        AppLang.ptBR => 'Nenhum jogo salvo encontrado.',
        AppLang.es => 'No se encontró ninguna partida guardada.',
        AppLang.fr => 'Aucune partie sauvegardée trouvée.',
        AppLang.de => 'Kein gespeichertes Spiel gefunden.',
        AppLang.it => 'Nessuna partita salvata trovata.',
        AppLang.en => 'No saved game found.',
      };

  // ── AI Profiles ───────────────────────────────────────────────────────────
  String aiProfileName(AiProfile profile) {
    return switch (profile) {
      AiProfile.balanced => switch (_lang) {
          AppLang.ptPT || AppLang.ptBR => 'Equilibrado',
          AppLang.es => 'Equilibrado',
          AppLang.fr => 'Équilibré',
          AppLang.de => 'Ausgewogen',
          AppLang.it => 'Equilibrato',
          AppLang.en => 'Balanced',
        },
      AiProfile.aggressive => switch (_lang) {
          AppLang.ptPT || AppLang.ptBR => 'Agressivo',
          AppLang.es => 'Agresivo',
          AppLang.fr => 'Agressif',
          AppLang.de => 'Aggressiv',
          AppLang.it => 'Aggressivo',
          AppLang.en => 'Aggressive',
        },
      AiProfile.cautious => switch (_lang) {
          AppLang.ptPT || AppLang.ptBR => 'Cauteloso',
          AppLang.es => 'Cauteloso',
          AppLang.fr => 'Prudent',
          AppLang.de => 'Vorsichtig',
          AppLang.it => 'Cauto',
          AppLang.en => 'Cautious',
        },
      AiProfile.dreamer => switch (_lang) {
          AppLang.ptPT || AppLang.ptBR => 'Sonhador',
          AppLang.es => 'Soñador',
          AppLang.fr => 'Rêveur',
          AppLang.de => 'Träumer',
          AppLang.it => 'Sognatore',
          AppLang.en => 'Dreamer',
        },
    };
  }

  // ── Turn / Roll ───────────────────────────────────────────────────────────
  String playerThinking(String name) => switch (_lang) {
        AppLang.ptPT => '$name está a pensar...',
        AppLang.ptBR => '$name está pensando...',
        AppLang.es => '$name está pensando...',
        AppLang.fr => '$name réfléchit...',
        AppLang.de => '$name denkt nach...',
        AppLang.it => '$name sta pensando...',
        AppLang.en => '$name is thinking...',
      };

  String playerTurn(String name) => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Vez de $name',
        AppLang.es => 'Turno de $name',
        AppLang.fr => 'Tour de $name',
        AppLang.de => '$name ist dran',
        AppLang.it => 'Turno di $name',
        AppLang.en => "$name's turn",
      };

  String rollLabel(int rollIndex, {required bool fromHand}) {
    final n = rollIndex + 1;
    final base = switch (_lang) {
      AppLang.ptPT || AppLang.ptBR => 'Lançamento $n / 3',
      AppLang.es => 'Lanzamiento $n / 3',
      AppLang.fr => 'Lancer $n / 3',
      AppLang.de => 'Wurf $n / 3',
      AppLang.it => 'Lancio $n / 3',
      AppLang.en => 'Roll $n / 3',
    };
    if (!fromHand) return base;
    final tag = switch (_lang) {
      AppLang.ptPT || AppLang.ptBR => '(de mão)',
      AppLang.es => '(de mano)',
      AppLang.fr => '(en main)',
      AppLang.de => '(aus der Hand)',
      AppLang.it => '(di mano)',
      AppLang.en => '(from hand)',
    };
    return '$base  $tag';
  }

  String get accumulationChip => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Acum',
        AppLang.es || AppLang.fr || AppLang.it => 'Acum',
        AppLang.de => 'Akkum',
        AppLang.en => 'Accum',
      };

  // ── Actions ───────────────────────────────────────────────────────────────
  String get holdAndRoll => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Segurar e Lançar',
        AppLang.es => 'Guardar y Lanzar',
        AppLang.fr => 'Garder et Lancer',
        AppLang.de => 'Halten und Würfeln',
        AppLang.it => 'Tieni e Lancia',
        AppLang.en => 'Hold & Roll',
      };

  String get endTurn => switch (_lang) {
        AppLang.ptPT => 'Terminar Turno',
        AppLang.ptBR => 'Encerrar Turno',
        AppLang.es => 'Finalizar Turno',
        AppLang.fr => 'Terminer le Tour',
        AppLang.de => 'Zug beenden',
        AppLang.it => 'Fine Turno',
        AppLang.en => 'End Turn',
      };

  String get pass => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Passar',
        AppLang.es => 'Pasar',
        AppLang.fr => 'Passer',
        AppLang.de => 'Passen',
        AppLang.it => 'Passa',
        AppLang.en => 'Pass',
      };

  String figurePoints(String shortLine, int points) => '$shortLine ${points}pts';

  String specialToFigure(String shortLine, int points) {
    final prefix = switch (_lang) {
      AppLang.ptPT || AppLang.ptBR => 'Especial→',
      AppLang.es => 'Especial→',
      AppLang.fr => 'Spécial→',
      AppLang.de => 'Spezial→',
      AppLang.it => 'Speciale→',
      AppLang.en => 'Special→',
    };
    return '$prefix$shortLine ${points}pts';
  }

  String sequencePoints(int points) {
    final label = switch (_lang) {
      AppLang.fr => 'Séq',
      _ => 'Seq',
    };
    return '$label ${points}pts';
  }

  String fullPoints(int points) => 'Full ${points}pts';
  String pokerPoints(int points) => 'Poker ${points}pts';

  String get continueAccum => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Continuar Acum',
        AppLang.es => 'Continuar Acum',
        AppLang.fr => 'Continuer Accum',
        AppLang.de => 'Akkum fortsetzen',
        AppLang.it => 'Continua Accum',
        AppLang.en => 'Continue Accum',
      };

  String get finalizeAccum => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Finalizar Acum',
        AppLang.es => 'Finalizar Acum',
        AppLang.fr => 'Finaliser Accum',
        AppLang.de => 'Akkum abschließen',
        AppLang.it => 'Finalizza Accum',
        AppLang.en => 'Finalize Accum',
      };

  // ── Scorecard ─────────────────────────────────────────────────────────────
  String get line => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Linha',
        AppLang.es => 'Línea',
        AppLang.fr => 'Ligne',
        AppLang.de => 'Linie',
        AppLang.it => 'Riga',
        AppLang.en => 'Line',
      };

  String get special => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Especiais',
        AppLang.es => 'Especiales',
        AppLang.fr => 'Spéciales',
        AppLang.de => 'Spezial',
        AppLang.it => 'Speciali',
        AppLang.en => 'Special',
      };

  String get seqShort => switch (_lang) {
        AppLang.fr => 'Séq',
        _ => 'Seq',
      };

  String get fullShort => 'Full';
  String get pokerShort => 'Poker';

  String get totals => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Totais',
        AppLang.es => 'Totales',
        AppLang.fr => 'Totaux',
        AppLang.de => 'Gesamt',
        AppLang.it => 'Totali',
        AppLang.en => 'Totals',
      };

  String get overall => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Geral',
        AppLang.es => 'Total',
        AppLang.fr => 'Global',
        AppLang.de => 'Total',
        AppLang.it => 'Totale',
        AppLang.en => 'Overall',
      };

  // ── Game Over ─────────────────────────────────────────────────────────────
  String get finalScores => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Pontuações Finais',
        AppLang.es => 'Puntuación Final',
        AppLang.fr => 'Scores Finaux',
        AppLang.de => 'Endpunkte',
        AppLang.it => 'Punteggi Finali',
        AppLang.en => 'Final Scores',
      };

  String winnerTitle(String name) => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => '$name venceu!',
        AppLang.es => '¡$name ganó!',
        AppLang.fr => '$name a gagné\u00a0!',
        AppLang.de => '$name gewinnt!',
        AppLang.it => '$name ha vinto!',
        AppLang.en => '$name wins!',
      };

  String pointsSuffix(int score) => '$score pts';

  String get gameOver => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Fim do Jogo',
        AppLang.es => 'Fin del Juego',
        AppLang.fr => 'Fin du Jeu',
        AppLang.de => 'Spielende',
        AppLang.it => 'Fine Partita',
        AppLang.en => 'Game Over',
      };

  String get newGame => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Novo Jogo',
        AppLang.es => 'Nueva Partida',
        AppLang.fr => 'Nouvelle Partie',
        AppLang.de => 'Neues Spiel',
        AppLang.it => 'Nuova Partita',
        AppLang.en => 'New Game',
      };

  // ── Achievements dialog ───────────────────────────────────────────────────
  String get achievements => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Conquistas',
        AppLang.es => 'Logros',
        AppLang.fr => 'Succès',
        AppLang.de => 'Erfolge',
        AppLang.it => 'Risultati',
        AppLang.en => 'Achievements',
      };

  String achievementsUnlocked(int count, int total) => switch (_lang) {
        AppLang.ptPT ||
        AppLang.ptBR =>
          'Desbloqueadas: $count/$total',
        AppLang.es => 'Desbloqueados: $count/$total',
        AppLang.fr => 'Débloqués\u00a0: $count/$total',
        AppLang.de => 'Freigeschaltet: $count/$total',
        AppLang.it => 'Sbloccati: $count/$total',
        AppLang.en => 'Unlocked: $count/$total',
      };

  String get pendingSuffix => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => '(em aberto)',
        AppLang.es => '(pendiente)',
        AppLang.fr => '(en attente)',
        AppLang.de => '(ausstehend)',
        AppLang.it => '(in sospeso)',
        AppLang.en => '(pending)',
      };

  String get close => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Fechar',
        AppLang.es => 'Cerrar',
        AppLang.fr => 'Fermer',
        AppLang.de => 'Schließen',
        AppLang.it => 'Chiudi',
        AppLang.en => 'Close',
      };

  // ── Language screen ───────────────────────────────────────────────────────
  String get language => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Idioma',
        AppLang.es => 'Idioma',
        AppLang.fr => 'Langue',
        AppLang.de => 'Sprache',
        AppLang.it => 'Lingua',
        AppLang.en => 'Language',
      };

  String get languageScreenTitle => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Selecionar Idioma',
        AppLang.es => 'Seleccionar Idioma',
        AppLang.fr => 'Choisir la Langue',
        AppLang.de => 'Sprache wählen',
        AppLang.it => 'Scegli Lingua',
        AppLang.en => 'Select Language',
      };

  String get languageSystemDefault => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Padrão do sistema',
        AppLang.es => 'Idioma del sistema',
        AppLang.fr => 'Langue du système',
        AppLang.de => 'Systemsprache',
        AppLang.it => 'Lingua di sistema',
        AppLang.en => 'System default',
      };

  // ── Achievement titles & descriptions ────────────────────────────────────
  String achievementTitle(AchievementId id) => switch (id) {
        AchievementId.firstWin => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Primeira Vitória',
            AppLang.es => 'Primera Victoria',
            AppLang.fr => 'Première Victoire',
            AppLang.de => 'Erster Sieg',
            AppLang.it => 'Prima Vittoria',
            AppLang.en => 'First Victory',
          },
        AchievementId.hatTrick => 'Hat-trick',
        AchievementId.invictus => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Invicto',
            AppLang.es => 'Invicto',
            AppLang.fr => 'Invaincu',
            AppLang.de => 'Unbesiegt',
            AppLang.it => 'Invitto',
            AppLang.en => 'Invictus',
          },
        AchievementId.royalPoker => 'Royal Poker',
        AchievementId.pokerFace => 'Poker Face',
        AchievementId.piladaFromHand => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Cinco Noves!',
            AppLang.es => '¡Cinco Nueves!',
            AppLang.fr => 'Cinq Neuf\u00a0!',
            AppLang.de => 'Fünf Neuner!',
            AppLang.it => 'Cinque Noni!',
            AppLang.en => 'Five Nines!',
          },
        AchievementId.perfectStraight => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Sequência Perfeita',
            AppLang.es => 'Escalera Perfecta',
            AppLang.fr => 'Suite Parfaite',
            AppLang.de => 'Perfekte Sequenz',
            AppLang.it => 'Sequenza Perfetta',
            AppLang.en => 'Perfect Straight',
          },
        AchievementId.marathoner => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Maratonista',
            AppLang.es => 'Maratonista',
            AppLang.fr => 'Marathonien',
            AppLang.de => 'Marathonläufer',
            AppLang.it => 'Maratoneta',
            AppLang.en => 'Marathoner',
          },
        AchievementId.wall => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR || AppLang.es || AppLang.it => 'Muro!',
            AppLang.fr => 'Mur\u00a0!',
            AppLang.de => 'Mauer!',
            AppLang.en => 'Wall!',
          },
        AchievementId.closer => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Fechador',
            AppLang.es => 'Cerrador',
            AppLang.fr => 'Finisseur',
            AppLang.de => 'Abschluss',
            AppLang.it => 'Chiusore',
            AppLang.en => 'Closer',
          },
        AchievementId.accumulator => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR || AppLang.es => 'Acumulador',
            AppLang.fr => 'Accumulateur',
            AppLang.de => 'Sammler',
            AppLang.it => 'Accumulatore',
            AppLang.en => 'Accumulator',
          },
        AchievementId.clutchScorer => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Tudo ou Nada',
            AppLang.es => 'Todo o Nada',
            AppLang.fr => 'Tout ou Rien',
            AppLang.de => 'Alles oder Nichts',
            AppLang.it => 'Tutto o Niente',
            AppLang.en => 'All or Nothing',
          },
        AchievementId.strategist => switch (_lang) {
            AppLang.ptPT => 'Estratega',
            AppLang.ptBR => 'Estrategista',
            AppLang.es => 'Estratega',
            AppLang.fr => 'Stratège',
            AppLang.de => 'Stratege',
            AppLang.it => 'Stratega',
            AppLang.en => 'Strategist',
          },
        AchievementId.survivor => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Última Oportunidade',
            AppLang.es => 'Última Oportunidad',
            AppLang.fr => 'Dernière Chance',
            AppLang.de => 'Letzte Chance',
            AppLang.it => 'Ultima Chance',
            AppLang.en => 'Last Shot',
          },
        AchievementId.aiSlayer => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Caçador de IA',
            AppLang.es => 'Cazador de IA',
            AppLang.fr => "Tueur d'IA",
            AppLang.de => 'KI-Jäger',
            AppLang.it => 'Cacciatore IA',
            AppLang.en => 'AI Slayer',
          },
        AchievementId.closeCall => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Equilíbrio Perfeito',
            AppLang.es => 'Equilibrio Perfecto',
            AppLang.fr => 'Équilibre Parfait',
            AppLang.de => 'Perfekte Balance',
            AppLang.it => 'Equilibrio Perfetto',
            AppLang.en => 'Perfect Balance',
          },
        AchievementId.dominator => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR || AppLang.es => 'Dominador',
            AppLang.fr => 'Dominateur',
            AppLang.de => 'Dominator',
            AppLang.it => 'Dominatore',
            AppLang.en => 'Dominator',
          },
        AchievementId.collector => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Colecionador',
            AppLang.es => 'Coleccionista',
            AppLang.fr => 'Collectionneur',
            AppLang.de => 'Sammler',
            AppLang.it => 'Collezionista',
            AppLang.en => 'Collector',
          },
        AchievementId.legend => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Lenda do Poker de Dados',
            AppLang.es => 'Leyenda del Póker de Dados',
            AppLang.fr => 'Légende du Poker de Dés',
            AppLang.de => 'Würfelpoker-Legende',
            AppLang.it => 'Leggenda del Poker di Dadi',
            AppLang.en => 'Dice Poker Legend',
          },
        AchievementId.chameleon => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Camaleão',
            AppLang.es => 'Camaleón',
            AppLang.fr => 'Caméléon',
            AppLang.de => 'Chamäleon',
            AppLang.it => 'Camaleonte',
            AppLang.en => 'Chameleon',
          },
        // Poker milestones
        AchievementId.poker10 => 'Poker ×10',
        AchievementId.poker30 => 'Poker ×30',
        AchievementId.poker50 => 'Poker ×50',
        AchievementId.poker100 => 'Poker ×100',
        AchievementId.poker200 => 'Poker ×200',
        AchievementId.poker500 => 'Poker ×500',
        // Sequence milestones
        AchievementId.seqFromHand100 => _seqMilestone(100),
        AchievementId.seqFromHand200 => _seqMilestone(200),
        AchievementId.seqFromHand500 => _seqMilestone(500),
        AchievementId.seqFromHand1000 => _seqMilestone(1000),
        AchievementId.seqFromHand3000 => _seqMilestone(3000),
        AchievementId.seqFromHand10000 => _seqMilestone(10000),
        // Full milestones
        AchievementId.fullFromHand100 => _fullMilestone(100),
        AchievementId.fullFromHand200 => _fullMilestone(200),
        AchievementId.fullFromHand500 => _fullMilestone(500),
        AchievementId.fullFromHand1000 => _fullMilestone(1000),
        AchievementId.fullFromHand3000 => _fullMilestone(3000),
        AchievementId.fullFromHand10000 => _fullMilestone(10000),
        // All faces five-of-a-kind
        AchievementId.allFacesFiveOfKind => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Todas as Faces ×5',
            AppLang.es => 'Todas las Caras ×5',
            AppLang.fr => 'Toutes les Faces ×5',
            AppLang.de => 'Alle Seiten ×5',
            AppLang.it => 'Tutte le Facce ×5',
            AppLang.en => 'All Faces ×5',
          },
      };

  String _seqMilestone(int n) {
    final label = switch (_lang) {
      AppLang.fr => 'Séq de Main',
      AppLang.de => 'Seq aus der Hand',
      AppLang.it => 'Seq di Mano',
      AppLang.ptPT || AppLang.ptBR => 'Seq de Mão',
      AppLang.es => 'Seq de Mano',
      AppLang.en => 'Seq from Hand',
    };
    return '$label ×$n';
  }

  String _fullMilestone(int n) {
    final label = switch (_lang) {
      AppLang.fr => 'Full de Main',
      AppLang.de => 'Full aus der Hand',
      AppLang.it => 'Full di Mano',
      AppLang.ptPT || AppLang.ptBR => 'Full de Mão',
      AppLang.es => 'Full de Mano',
      AppLang.en => 'Full from Hand',
    };
    return '$label ×$n';
  }

  String achievementDesc(AchievementId id) => switch (id) {
        AchievementId.firstWin => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Ganhar 1 jogo.',
            AppLang.es => 'Ganar 1 partida.',
            AppLang.fr => 'Gagner 1 partie.',
            AppLang.de => '1 Spiel gewinnen.',
            AppLang.it => 'Vincere 1 partita.',
            AppLang.en => 'Win 1 game.',
          },
        AchievementId.hatTrick => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Ganhar 3 jogos seguidos.',
            AppLang.es => 'Ganar 3 partidas seguidas.',
            AppLang.fr => "Gagner 3 parties d'affilée.",
            AppLang.de => '3 Spiele hintereinander gewinnen.',
            AppLang.it => 'Vincere 3 partite di fila.',
            AppLang.en => 'Win 3 games in a row.',
          },
        AchievementId.invictus => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR =>
              'Vencer sem o adversário alguma vez estar na frente.',
            AppLang.es =>
              'Ganar sin que el rival haya liderado en ningún momento.',
            AppLang.fr =>
              "Gagner sans que l'adversaire n'ait jamais été en tête.",
            AppLang.de =>
              'Ein Spiel gewinnen, ohne dass der Gegner je geführt hat.',
            AppLang.it =>
              "Vincere senza che l'avversario sia mai stato in vantaggio.",
            AppLang.en =>
              'Win without the opponent ever taking the lead.',
          },
        AchievementId.clutchScorer => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR =>
              'Vencer estando a perder por 50+ pontos antes do último turno.',
            AppLang.es =>
              'Ganar después de estar 50+ puntos abajo antes del último turno.',
            AppLang.fr =>
              'Gagner après avoir été à 50+ points de retard avant le dernier tour.',
            AppLang.de =>
              'Gewinnen, obwohl man vor dem letzten Zug 50+ Punkte zurücklag.',
            AppLang.it =>
              'Vincere dopo essere stati sotto di 50+ punti prima dell\'ultimo turno.',
            AppLang.en =>
              'Win after being down by 50+ points before the last turn.',
          },
        AchievementId.strategist => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR =>
              'Completar um jogo sem marcar 0 em nenhuma célula de figura.',
            AppLang.es =>
              'Completar una partida sin marcar 0 en ninguna celda de figura.',
            AppLang.fr =>
              'Terminer une partie sans marquer 0 dans aucune case de figure.',
            AppLang.de =>
              'Ein Spiel beenden, ohne 0 in einer Figurenzelle einzutragen.',
            AppLang.it =>
              'Completare una partita senza segnare 0 in nessuna cella figura.',
            AppLang.en =>
              'Complete a game without scoring 0 in any figure cell.',
          },
        AchievementId.survivor => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR =>
              'Vencer quando o adversário estava na frente no último turno.',
            AppLang.es =>
              'Ganar cuando el rival iba por delante en el último turno.',
            AppLang.fr =>
              "Gagner alors que l'adversaire menait au dernier tour.",
            AppLang.de =>
              'Gewinnen, obwohl der Gegner im letzten Zug vorne lag.',
            AppLang.it =>
              "Vincere quando l'avversario era in vantaggio all'ultimo turno.",
            AppLang.en =>
              'Win a game where the opponent was leading going into the last turn.',
          },
        AchievementId.chameleon => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR =>
              'Ganhar pelo menos um jogo contra cada perfil de IA (Balanced, Aggressive, Cautious, Dreamer).',
            AppLang.es =>
              'Ganar al menos una partida contra cada perfil de IA.',
            AppLang.fr =>
              "Gagner au moins une partie contre chaque profil d'IA.",
            AppLang.de =>
              'Mindestens ein Spiel gegen jedes KI-Profil gewinnen.',
            AppLang.it =>
              'Vincere almeno una partita contro ogni profilo IA.',
            AppLang.en =>
              'Win at least one game against each AI profile (Balanced, Aggressive, Cautious, Dreamer).',
          },
        AchievementId.royalPoker => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Marcar Royal Poker (200 pts).',
            AppLang.es => 'Marcar Royal Poker (200 pts).',
            AppLang.fr => 'Réaliser un Royal Poker (200 pts).',
            AppLang.de => 'Einen Royal Poker erzielen (200 Pkt).',
            AppLang.it => 'Segnare un Royal Poker (200 pt).',
            AppLang.en => 'Score a Royal Poker (200 pts).',
          },
        AchievementId.pokerFace => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Marcar 3 pokers no mesmo jogo.',
            AppLang.es => 'Marcar 3 pókers en una partida.',
            AppLang.fr => 'Marquer 3 pokers dans la même partie.',
            AppLang.de => '3 Pokers in einem Spiel erzielen.',
            AppLang.it => 'Segnare 3 poker nella stessa partita.',
            AppLang.en => 'Score 3 pokers in one game.',
          },
        AchievementId.piladaFromHand => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR =>
              'Fazer 5 noves de mão num lançamento.',
            AppLang.es => 'Sacar 5 nueves de mano en un lanzamiento.',
            AppLang.fr => 'Faire 5 neuf de main en un lancer.',
            AppLang.de => '5 Neuner aus der Hand würfeln.',
            AppLang.it => 'Ottenere 5 noni di mano in un lancio.',
            AppLang.en => 'Roll 5 nines from hand.',
          },
        AchievementId.perfectStraight => switch (_lang) {
            AppLang.ptPT ||
            AppLang.ptBR =>
              'Fazer sequência máxima de mão num lançamento.',
            AppLang.es => 'Sacar la escalera máxima de mano.',
            AppLang.fr => 'Réaliser la séquence maximale de main.',
            AppLang.de => 'Die maximale Sequenz aus der Hand würfeln.',
            AppLang.it => 'Fare la sequenza massima di mano.',
            AppLang.en => 'Roll a max straight from hand.',
          },
        AchievementId.marathoner => switch (_lang) {
            AppLang.ptPT ||
            AppLang.ptBR =>
              'Completar 5 colunas da mesma linha num jogo.',
            AppLang.es =>
              'Completar las 5 columnas de la misma fila en una partida.',
            AppLang.fr =>
              'Compléter les 5 colonnes de la même ligne en une partie.',
            AppLang.de =>
              'Alle 5 Spalten derselben Linie in einem Spiel füllen.',
            AppLang.it =>
              'Completare le 5 colonne della stessa riga in una partita.',
            AppLang.en =>
              'Complete all 5 columns of the same line in one game.',
          },
        AchievementId.wall => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR =>
              'Fechar uma linha sem outro jogador abrir.',
            AppLang.es =>
              'Cerrar una fila sin que otro jugador la haya abierto.',
            AppLang.fr =>
              "Fermer une ligne sans qu'aucun autre joueur ne l'ait ouverte.",
            AppLang.de =>
              'Eine Linie schließen, ohne dass ein anderer Spieler sie geöffnet hat.',
            AppLang.it =>
              "Chiudere una riga senza che altri giocatori l'abbiano aperta.",
            AppLang.en =>
              'Close a line without any other player opening it.',
          },
        AchievementId.closer => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Fechar 3 linhas no mesmo jogo.',
            AppLang.es => 'Cerrar 3 filas en la misma partida.',
            AppLang.fr => 'Fermer 3 lignes dans la même partie.',
            AppLang.de => '3 Linien im selben Spiel schließen.',
            AppLang.it => 'Chiudere 3 righe nella stessa partita.',
            AppLang.en => 'Close 3 lines in the same game.',
          },
        AchievementId.accumulator => switch (_lang) {
            AppLang.ptPT =>
              'Registar 20+ pontos numa única célula de figura.',
            AppLang.ptBR =>
              'Registrar 20+ pontos em uma única célula de figura.',
            AppLang.es =>
              'Registrar 20+ puntos en una sola celda de figura.',
            AppLang.fr =>
              'Enregistrer 20+ points dans une seule case de figure.',
            AppLang.de =>
              '20+ Punkte in einer einzigen Figurenzelle eintragen.',
            AppLang.it =>
              'Registrare 20+ punti in una singola cella di figura.',
            AppLang.en =>
              'Register 20+ points in a single figure cell.',
          },
        AchievementId.aiSlayer => switch (_lang) {
            AppLang.ptPT => 'Ganhar contra 3 IA.',
            AppLang.ptBR => 'Vencer contra 3 IAs.',
            AppLang.es => 'Ganar contra 3 rivales IA.',
            AppLang.fr => 'Battre 3 adversaires IA.',
            AppLang.de => 'Gegen 3 KI-Gegner gewinnen.',
            AppLang.it => 'Battere 3 avversari IA.',
            AppLang.en => 'Beat 3 AI opponents.',
          },
        AchievementId.closeCall => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Vencer por 10 pontos ou menos.',
            AppLang.es => 'Ganar por 10 puntos o menos.',
            AppLang.fr => "Gagner avec 10 points ou moins d'écart.",
            AppLang.de => 'Mit 10 Punkten oder weniger gewinnen.',
            AppLang.it => 'Vincere con 10 punti o meno di vantaggio.',
            AppLang.en => 'Win by 10 points or fewer.',
          },
        AchievementId.dominator => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Vencer por 150+ pontos.',
            AppLang.es => 'Ganar por 150+ puntos.',
            AppLang.fr => "Gagner avec 150+ points d'écart.",
            AppLang.de => 'Mit 150+ Punkten gewinnen.',
            AppLang.it => 'Vincere con 150+ punti di vantaggio.',
            AppLang.en => 'Win by 150+ points.',
          },
        AchievementId.collector => switch (_lang) {
            AppLang.ptPT || AppLang.ptBR => 'Desbloquear 10 conquistas.',
            AppLang.es => 'Desbloquear 10 logros.',
            AppLang.fr => 'Débloquer 10 succès.',
            AppLang.de => '10 Erfolge freischalten.',
            AppLang.it => 'Sbloccare 10 risultati.',
            AppLang.en => 'Unlock 10 achievements.',
          },
        AchievementId.legend => switch (_lang) {
            AppLang.ptPT ||
            AppLang.ptBR =>
              'Desbloquear todas as conquistas implementadas.',
            AppLang.es => 'Desbloquear todos los logros implementados.',
            AppLang.fr => 'Débloquer tous les succès implémentés.',
            AppLang.de => 'Alle implementierten Erfolge freischalten.',
            AppLang.it => 'Sbloccare tutti i risultati implementati.',
            AppLang.en => 'Unlock all implemented achievements.',
          },
        AchievementId.poker10 => _pokerMilestoneDesc(10),
        AchievementId.poker30 => _pokerMilestoneDesc(30),
        AchievementId.poker50 => _pokerMilestoneDesc(50),
        AchievementId.poker100 => _pokerMilestoneDesc(100),
        AchievementId.poker200 => _pokerMilestoneDesc(200),
        AchievementId.poker500 => _pokerMilestoneDesc(500),
        AchievementId.seqFromHand100 => _seqMilestoneDesc(100),
        AchievementId.seqFromHand200 => _seqMilestoneDesc(200),
        AchievementId.seqFromHand500 => _seqMilestoneDesc(500),
        AchievementId.seqFromHand1000 => _seqMilestoneDesc(1000),
        AchievementId.seqFromHand3000 => _seqMilestoneDesc(3000),
        AchievementId.seqFromHand10000 => _seqMilestoneDesc(10000),
        AchievementId.fullFromHand100 => _fullMilestoneDesc(100),
        AchievementId.fullFromHand200 => _fullMilestoneDesc(200),
        AchievementId.fullFromHand500 => _fullMilestoneDesc(500),
        AchievementId.fullFromHand1000 => _fullMilestoneDesc(1000),
        AchievementId.fullFromHand3000 => _fullMilestoneDesc(3000),
        AchievementId.fullFromHand10000 => _fullMilestoneDesc(10000),
        AchievementId.allFacesFiveOfKind => switch (_lang) {
            AppLang.ptPT ||
            AppLang.ptBR =>
              'Fazer 5 iguais com as 6 faces (A, K, Q, J, 10, 9).',
            AppLang.es =>
              'Sacar 5 iguales con las 6 caras (A, K, Q, J, 10, 9).',
            AppLang.fr =>
              'Faire 5 identiques avec les 6 faces (A, K, Q, J, 10, 9).',
            AppLang.de =>
              '5 Gleiche mit allen 6 Seiten würfeln (A, K, Q, J, 10, 9).',
            AppLang.it =>
              'Fare 5 uguali con le 6 facce (A, K, Q, J, 10, 9).',
            AppLang.en =>
              'Roll five of a kind with all 6 faces (A, K, Q, J, 10, 9).',
          },
      };

  String _pokerMilestoneDesc(int n) => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Obter $n pokers no total.',
        AppLang.es => 'Obtener $n pókers en total.',
        AppLang.fr => 'Obtenir $n pokers au total.',
        AppLang.de => '$n Pokers insgesamt erzielen.',
        AppLang.it => 'Ottenere $n poker in totale.',
        AppLang.en => 'Score $n total pokers.',
      };

  String _seqMilestoneDesc(int n) => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR =>
          'Obter $n sequências de mão no total.',
        AppLang.es => 'Obtener $n escaleras de mano en total.',
        AppLang.fr => 'Obtenir $n séquences de main au total.',
        AppLang.de => '$n Sequenzen aus der Hand insgesamt erzielen.',
        AppLang.it => 'Ottenere $n sequenze di mano in totale.',
        AppLang.en => 'Score $n total sequences from hand.',
      };

  String _fullMilestoneDesc(int n) => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR =>
          'Obter $n full house de mão no total.',
        AppLang.es => 'Obtener $n full house de mano en total.',
        AppLang.fr => 'Obtenir $n full houses de main au total.',
        AppLang.de => '$n Full Houses aus der Hand insgesamt erzielen.',
        AppLang.it => 'Ottenere $n full house di mano in totale.',
        AppLang.en => 'Score $n total full houses from hand.',
      };

  String get aboutTitle => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Sobre',
        AppLang.es => 'Acerca de',
        AppLang.fr => 'À propos',
        AppLang.de => 'Über',
        AppLang.it => 'Informazioni',
        AppLang.en => 'About',
      };

  String get feedbackLabel => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Enviar feedback',
        AppLang.es => 'Enviar comentarios',
        AppLang.fr => 'Envoyer un avis',
        AppLang.de => 'Feedback senden',
        AppLang.it => 'Invia feedback',
        AppLang.en => 'Send Feedback',
      };

  String get rulesSourceLabel => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Fonte das regras originais',
        AppLang.es => 'Fuente de las reglas originales',
        AppLang.fr => 'Source des règles originales',
        AppLang.de => 'Quelle der Originalregeln',
        AppLang.it => 'Fonte delle regole originali',
        AppLang.en => 'Original rules source',
      };

  String get aboutVersionLabel => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR => 'Versão',
        AppLang.es => 'Versión',
        AppLang.fr => 'Version',
        AppLang.de => 'Version',
        AppLang.it => 'Versione',
        AppLang.en => 'Version',
      };

  String get aboutAppDescription => switch (_lang) {
        AppLang.ptPT || AppLang.ptBR =>
          'Implementação digital do clássico Poker de Dados português.',
        AppLang.es => 'Implementación digital del clásico Póker de Dados.',
        AppLang.fr => 'Implémentation numérique du classique Poker de Dés.',
        AppLang.de => 'Digitale Umsetzung des klassischen Würfelpokers.',
        AppLang.it => 'Implementazione digitale del classico Poker di Dadi.',
        AppLang.en => 'Digital implementation of the classic Dice Poker game.',
      };
}
