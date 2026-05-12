import 'package:flutter/material.dart';

import '../engine/ai_profiles.dart';
import '../engine/game_engine.dart';
import '../engine/models.dart';
import '../engine/scoring.dart';
import 'i18n/app_strings.dart';
import 'game_controller.dart';
import 'services/dice_sound.dart';
import 'services/achievements_service.dart';
import 'services/game_persistence.dart';
import 'widgets/action_panel.dart';
import 'widgets/dice_3d.dart';
import 'widgets/scorecard_table.dart';

/// Main game screen — assembles dice, scorecard, and action panel.
class GameScreen extends StatefulWidget {
  final List<String> playerNames;
  final Map<int, AiProfile> aiProfiles;
  final GameState? initialState;

  const GameScreen({
    super.key,
    this.playerNames = const [
      'Player 1',
      'Player 2 (AI)',
      'Player 3 (AI)',
      'Player 4 (AI)',
    ],
    this.aiProfiles = const {
      1: AiProfile.balanced,
      2: AiProfile.aggressive,
      3: AiProfile.cautious,
    },
    this.initialState,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController _controller;
  int _viewingPlayerIndex = 0;
  int _lastKnownPlayerIndex = 0;
  bool _gameOverDialogShown = false;
  bool _achievementsProcessed = false;
  String? _lastRollSignature;
  final List<RollObservation> _rollObservations = [];
  final List<List<int>> _scoreSnapshots = [];
  final _soundService = DiceSoundService();

  @override
  void initState() {
    super.initState();
    _controller = GameController(
      playerNames: widget.playerNames,
      initialState: widget.initialState,
      aiProfiles: widget.aiProfiles,
    );
    _controller.addListener(_onStateChanged);
    _recordRollObservation();
  }

  void _onStateChanged() {
    setState(() {
      // Only auto-follow when the active player actually changes
      if (_controller.currentPlayerIndex != _lastKnownPlayerIndex) {
        _recordScoreSnapshot();
        _viewingPlayerIndex = _controller.currentPlayerIndex;
        _lastKnownPlayerIndex = _controller.currentPlayerIndex;
      }
      // Trigger sound on roll
      if (_controller.isRolling) {
        _soundService.playRollSound();
      }
    });

    if (_controller.gameOver) {
      GamePersistence.clearSavedMatch();

      if (!_achievementsProcessed) {
        _achievementsProcessed = true;
        AchievementsService.processCompletedMatch(
          state: _controller.state,
          aiProfiles: _controller.aiProfiles,
          rollObservations: List.unmodifiable(_rollObservations),
          scoreSnapshots: List.unmodifiable(_scoreSnapshots),
        );
      }
    } else {
      _recordRollObservation();
      GamePersistence.saveMatch(
        state: _controller.state,
        aiProfiles: _controller.aiProfiles,
      );

      if (_achievementsProcessed) {
        _achievementsProcessed = false;
        _rollObservations.clear();
        _scoreSnapshots.clear();
        _lastRollSignature = null;
      }
    }

    // Show game-over dialog once
    if (_controller.gameOver && !_gameOverDialogShown) {
      _gameOverDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameOverDialog();
      });
    }
  }

  void _recordScoreSnapshot() {
    final state = _controller.state;
    final snap = [
      for (var i = 0; i < state.players.length; i++)
        calculateTotalScore(
          players: state.players,
          playerIndex: i,
          closedBy: state.closedBy,
        ),
    ];
    _scoreSnapshots.add(snap);
  }

  void _recordRollObservation() {
    final state = _controller.state;
    final faces = [for (final d in state.dice) d.face];
    final held = [for (final d in state.dice) d.held ? '1' : '0'].join();
    final signature =
        '${state.currentPlayerIndex}|${state.currentRollIndex}|${faces.map((f) => f.name).join(',')}|$held';

    if (_lastRollSignature == signature) return;
    _lastRollSignature = signature;

    _rollObservations.add(
      RollObservation(faces: faces, fromHand: state.isFromHand),
    );
  }

  void _showGameOverDialog() {
    final state = _controller.state;
    final strings = AppStrings.of(context);
    final scores = <int>[];
    for (var i = 0; i < state.players.length; i++) {
      scores.add(calculateTotalScore(
        players: state.players,
        playerIndex: i,
        closedBy: state.closedBy,
      ));
    }
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final winnerIdx = scores.indexOf(maxScore);
    final winner = state.players[winnerIdx];

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(
                strings.winnerTitle(winner.name),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              const SizedBox(height: 8),
              Text(strings.finalScores,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < state.players.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      if (i == winnerIdx)
                        const Text('👑 ', style: TextStyle(fontSize: 16)),
                      if (i != winnerIdx)
                        const SizedBox(width: 24),
                      Expanded(
                        child: Text(
                          state.players[i].name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: i == winnerIdx
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      Text(
                        strings.pointsSuffix(scores[i]),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: i == winnerIdx
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: i == winnerIdx
                              ? theme.colorScheme.primary
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            FilledButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                _gameOverDialogShown = false;
                _controller.restart();
              },
              icon: const Icon(Icons.replay),
              label: Text(strings.newGame),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    final player = _controller.currentPlayer;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        centerTitle: true,
        actions: [
          if (_controller.accumulationMode)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: Text(
                  '${strings.accumulationChip}: ${_controller.state.accumulationRunningTotal}pts',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: theme.colorScheme.tertiaryContainer,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1100;

            return Column(
              children: [
                _buildPlayerBanner(theme, player),
                Expanded(
                  child: isWide
                      ? _buildWideLayout(theme)
                      : _buildCompactLayout(theme, strings),
                ),
                if (_controller.gameOver) _buildGameOverBanner(theme, strings),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayerBanner(ThemeData theme, Player player) {
    final strings = AppStrings.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      color: _controller.isCurrentPlayerAi
          ? theme.colorScheme.tertiaryContainer
          : theme.colorScheme.primaryContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_controller.isCurrentPlayerAi)
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Text('🤖', style: TextStyle(fontSize: 16)),
            ),
          Flexible(
            child: Text(
              _controller.aiPlaying
                  ? strings.playerThinking(player.name)
                  : strings.playerTurn(player.name),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: _controller.isCurrentPlayerAi
                    ? theme.colorScheme.onTertiaryContainer
                    : theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLayout(ThemeData theme, AppStrings strings) {
    return Column(
      children: [
        _buildDiceAndActions(theme, strings),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: PlayerTabs(
            controller: _controller,
            viewingIndex: _viewingPlayerIndex,
            onChanged: (i) => setState(() => _viewingPlayerIndex = i),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ScorecardTable(
              controller: _controller,
              viewingPlayerIndex: _viewingPlayerIndex,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _buildDiceAndActions(theme, AppStrings.of(context)),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: PlayerTabs(
                  controller: _controller,
                  viewingIndex: _viewingPlayerIndex,
                  onChanged: (i) => setState(() => _viewingPlayerIndex = i),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ScorecardTable(
                    controller: _controller,
                    viewingPlayerIndex: _viewingPlayerIndex,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiceAndActions(ThemeData theme, AppStrings strings) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
          child: Column(
            children: [
              Dice3DRow(
                dice: _controller.dice,
                selected: _controller.selectedDice,
                rolling: _controller.isRolling,
                canSelect: _controller.validActions.canHold &&
                    !_controller.gameOver &&
                    !_controller.aiPlaying,
                onToggle: _controller.toggleDie,
                onLanded: () => _soundService.playLandSound(),
              ),
              const SizedBox(height: 6),
              Text(
                strings.rollLabel(
                  _controller.currentRollIndex,
                  fromHand: _controller.isFromHand,
                ),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: ActionPanel(
            controller: _controller,
            strings: strings,
            onScored: () => _soundService.playScoreSound(),
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverBanner(ThemeData theme, AppStrings strings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: theme.colorScheme.primaryContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏆 ', style: TextStyle(fontSize: 18)),
          Text(
            strings.gameOver,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          TextButton.icon(
            onPressed: () {
              _gameOverDialogShown = false;
              _controller.restart();
            },
            icon: const Icon(Icons.replay, size: 18),
            label: Text(strings.newGame),
          ),
        ],
      ),
    );
  }
}
