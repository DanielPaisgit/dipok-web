import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../engine/ai_profiles.dart';
import '../engine/constants.dart';
import '../engine/models.dart';
import '../main.dart';
import 'i18n/app_strings.dart';
import 'game_screen.dart';
import 'language_screen.dart';
import 'rules_screen.dart';
import 'about_screen.dart';
import 'services/achievements_service.dart';
import 'services/game_persistence.dart';

/// Setup screen to configure player count, names, and AI profiles before game start.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  static const _prefsPlayerCount = 'setup.playerCount';
  static const _prefsNames = 'setup.playerNames';
  static const _prefsIsAi = 'setup.isAi';
  static const _prefsAiProfiles = 'setup.aiProfiles';

  int _playerCount = maxPlayers;
  bool _hasSavedMatch = false;

  late final List<TextEditingController> _nameControllers;
  final List<bool> _isAi = [false, true, true, true];
  final List<AiProfile> _aiProfiles = [
    AiProfile.balanced,
    AiProfile.balanced,
    AiProfile.aggressive,
    AiProfile.cautious,
  ];

  @override
  void initState() {
    super.initState();
    _nameControllers = [
      TextEditingController(text: 'Player 1'),
      TextEditingController(text: 'Player 2'),
      TextEditingController(text: 'Player 3'),
      TextEditingController(text: 'Player 4'),
    ];
    _restoreSetup();
    _loadSavedMatchFlag();
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _restoreSetup() async {
    final prefs = await SharedPreferences.getInstance();

    final savedCount = prefs.getInt(_prefsPlayerCount);
    final savedNames = prefs.getStringList(_prefsNames);
    final savedIsAi = prefs.getStringList(_prefsIsAi);
    final savedProfiles = prefs.getStringList(_prefsAiProfiles);

    if (!mounted) return;

    setState(() {
      if (savedCount != null &&
          savedCount >= minPlayers &&
          savedCount <= maxPlayers) {
        _playerCount = savedCount;
      }

      if (savedNames != null) {
        for (var i = 0; i < _nameControllers.length && i < savedNames.length; i++) {
          final name = savedNames[i].trim();
          if (name.isNotEmpty) {
            _nameControllers[i].text = name;
          }
        }
      }

      if (savedIsAi != null) {
        for (var i = 0; i < _isAi.length && i < savedIsAi.length; i++) {
          _isAi[i] = savedIsAi[i] == 'true';
        }
      }

      if (savedProfiles != null) {
        for (var i = 0; i < _aiProfiles.length && i < savedProfiles.length; i++) {
          _aiProfiles[i] = AiProfile.values.firstWhere(
            (p) => p.name == savedProfiles[i],
            orElse: () => _aiProfiles[i],
          );
        }
      }
    });
  }

  Future<void> _loadSavedMatchFlag() async {
    final hasSaved = await GamePersistence.hasSavedMatch();
    if (!mounted) return;
    setState(() {
      _hasSavedMatch = hasSaved;
    });
  }

  Future<void> _persistSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsPlayerCount, _playerCount);
    await prefs.setStringList(
      _prefsNames,
      [for (final c in _nameControllers) c.text.trim()],
    );
    await prefs.setStringList(
      _prefsIsAi,
      [for (final isAi in _isAi) isAi.toString()],
    );
    await prefs.setStringList(
      _prefsAiProfiles,
      [for (final profile in _aiProfiles) profile.name],
    );
  }

  Future<void> _startGame() async {
    final names = <String>[];
    final aiMap = <int, AiProfile>{};

    for (var i = 0; i < _playerCount; i++) {
      final raw = _nameControllers[i].text.trim();
      final fallback = _isAi[i] ? 'AI ${i + 1}' : 'Player ${i + 1}';
      final name = raw.isEmpty ? fallback : raw;

      names.add(name);
      if (_isAi[i]) {
        aiMap[i] = _aiProfiles[i];
      }
    }

    await _persistSetup();
    await GamePersistence.clearSavedMatch();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(playerNames: names, aiProfiles: aiMap),
      ),
    );
  }

  Future<void> _continueSavedGame() async {
    final saved = await GamePersistence.loadMatch();
    if (saved == null) {
      if (!mounted) return;
      final strings = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.noSavedGame)),
      );
      setState(() {
        _hasSavedMatch = false;
      });
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(
          playerNames: saved.state.players.map((p) => p.name).toList(),
          aiProfiles: saved.aiProfiles,
          initialState: saved.state,
        ),
      ),
    );
  }

  Future<void> _showAchievementsDialog() async {
    final snapshot = await AchievementsService.getSnapshot();
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);

        String progressText(AchievementDefinition d) {
          return switch (d.id) {
            AchievementId.poker10 ||
            AchievementId.poker30 ||
            AchievementId.poker50 ||
            AchievementId.poker100 ||
            AchievementId.poker200 ||
            AchievementId.poker500 => '(${snapshot.totalPoker})',
            AchievementId.seqFromHand100 ||
            AchievementId.seqFromHand200 ||
            AchievementId.seqFromHand500 ||
            AchievementId.seqFromHand1000 ||
            AchievementId.seqFromHand3000 ||
            AchievementId.seqFromHand10000 => '(${snapshot.totalSeqFromHand})',
            AchievementId.fullFromHand100 ||
            AchievementId.fullFromHand200 ||
            AchievementId.fullFromHand500 ||
            AchievementId.fullFromHand1000 ||
            AchievementId.fullFromHand3000 ||
            AchievementId.fullFromHand10000 => '(${snapshot.totalFullFromHand})',
            AchievementId.allFacesFiveOfKind =>
              '(${snapshot.fiveKindFacesSeen.length}/${DieFace.values.length})',
            _ => '',
          };
        }

        final strings2 = AppStrings.of(ctx);
        return AlertDialog(
          title: Text(strings2.achievements),
          content: SizedBox(
            width: 620,
            height: 480,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings2.achievementsUnlocked(
                    snapshot.unlocked.length,
                    AchievementsService.definitions.length,
                  ),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: AchievementsService.definitions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final d = AchievementsService.definitions[index];
                      final unlocked = snapshot.unlocked.contains(d.id);
                      final desc = strings2.achievementDesc(d.id);
                      final subtitle = d.implemented
                          ? desc
                          : '$desc ${strings2.pendingSuffix}';

                      return ListTile(
                        dense: true,
                        leading: Icon(
                          unlocked ? Icons.emoji_events : Icons.lock_outline,
                          color: unlocked
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                        title: Text(
                          '${strings2.achievementTitle(d.id)} ${progressText(d)}'.trim(),
                          style: TextStyle(
                            fontWeight: unlocked ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(subtitle),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(strings2.close),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.setupTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: strings.aboutTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: strings.rulesTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const RulesScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: strings.language,
            onPressed: () {
              final localeCtrl = LocaleController.maybeOf(context);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LanguageScreen(
                    currentLocale: localeCtrl?.currentLocale,
                    onLocaleSelected: (locale) {
                      localeCtrl?.setLocale(locale);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 960;
            final cardWidth = isWide
                ? (constraints.maxWidth - 16 - 16 - 12) / 2
                : constraints.maxWidth - 32;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildConfigCard(theme),
                const SizedBox(height: 12),
                if (isWide)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (var i = 0; i < _playerCount; i++)
                        SizedBox(
                          width: cardWidth,
                          child: _buildPlayerCard(theme, i),
                        ),
                    ],
                  )
                else
                  for (var i = 0; i < _playerCount; i++) ...[
                    _buildPlayerCard(theme, i),
                    if (i < _playerCount - 1) const SizedBox(height: 12),
                  ],
                const SizedBox(height: 12),
                if (_hasSavedMatch)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton.icon(
                      onPressed: _continueSavedGame,
                      icon: const Icon(Icons.restore),
                      label: Text(strings.continueSavedGame),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton.icon(
                    onPressed: _showAchievementsDialog,
                    icon: const Icon(Icons.emoji_events_outlined),
                    label: Text(strings.achievements),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(strings.startGame),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildConfigCard(ThemeData theme) {
    final strings = AppStrings.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.gameConfiguration,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text('${strings.players}:'),
                DropdownButton<int>(
                  value: _playerCount,
                  items: [
                    for (var i = minPlayers; i <= maxPlayers; i++)
                      DropdownMenuItem<int>(
                        value: i,
                        child: Text('$i'),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _playerCount = value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(ThemeData theme, int i) {
    final strings = AppStrings.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.playerLabel(i),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameControllers[i],
              decoration: InputDecoration(
                labelText: strings.name,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              value: _isAi[i],
              onChanged: (v) => setState(() => _isAi[i] = v),
              contentPadding: EdgeInsets.zero,
              title: Text(strings.aiPlayer),
            ),
            if (_isAi[i])
              DropdownButtonFormField<AiProfile>(
                initialValue: _aiProfiles[i],
                decoration: InputDecoration(
                  labelText: strings.aiProfile,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  for (final profile in AiProfile.values)
                    DropdownMenuItem<AiProfile>(
                      value: profile,
                      child: Text(strings.aiProfileName(profile)),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _aiProfiles[i] = value);
                },
              ),
          ],
        ),
      ),
    );
  }
}
