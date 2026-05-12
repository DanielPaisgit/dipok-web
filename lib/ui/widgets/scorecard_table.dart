import 'package:flutter/material.dart';

import '../../engine/constants.dart';
import '../../engine/models.dart';
import '../../engine/scoring.dart';
import '../i18n/app_strings.dart';
import '../game_controller.dart';

/// Displays the score card table for all players.
///
/// Shows figure lines (5 columns each) and special lines below.
class ScorecardTable extends StatelessWidget {
  final GameController controller;
  final int viewingPlayerIndex;

  const ScorecardTable({
    super.key,
    required this.controller,
    required this.viewingPlayerIndex,
  });

  String _lineLabel(FigureLine line) => switch (line) {
        FigureLine.aces => 'A  (×6)',
        FigureLine.kings => 'K  (×5)',
        FigureLine.queens => 'Q  (×4)',
        FigureLine.jacks => 'J  (×3)',
        FigureLine.tens => '10 (×2)',
      };

  @override
  Widget build(BuildContext context) {
    final players = controller.players;
    final closedLines = controller.state.closedLines;
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    final card = players[viewingPlayerIndex].scoreCard;
    final totalScore = calculateTotalScore(
      players: players,
      playerIndex: viewingPlayerIndex,
      closedBy: controller.state.closedBy,
    );

    return Column(
      children: [
        _buildTotalsSummary(context, card, players, totalScore),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 36,
                dataRowMinHeight: 32,
                dataRowMaxHeight: 32,
                columnSpacing: 12,
                horizontalMargin: 8,
                columns: [
                  DataColumn(label: Text(strings.line)),
                  for (var col = 0; col < columnsPerLine; col++)
                    DataColumn(
                      label: Text(
                        '≥${columnMinimums[col]}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                ],
                rows: [
                  for (final line in FigureLine.values)
                    _buildFigureRow(context, line, players, closedLines),
                  _buildSpecialHeaderRow(context),
                  _buildSpecialRow(context, strings.seqShort, SpecialLine.sequences, players, (c) => c.sequenceEntries),
                  _buildSpecialRow(context, strings.fullShort, SpecialLine.fullens, players, (c) => c.fullenEntries),
                  _buildSpecialRow(context, strings.pokerShort, SpecialLine.poker, players, (c) => c.pokerEntries),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalsSummary(
    BuildContext context,
    ScoreCard viewedCard,
    List<Player> players,
    int totalScore,
  ) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    int figureLineScore(FigureLine line) {
      final raw = viewedCard.rawTotal(line);
      if (raw == 0) return 0;
      final anyUnopened = players.any((p) => p.scoreCard.filledColumns(line) == 0);
      final isCloser = controller.state.closedBy[line] == viewingPlayerIndex;
      return calculateLineScore(
        rawTotal: raw,
        multiplier: line.multiplier,
        isCloser: isCloser,
        hasUnopenedPlayers: anyUnopened,
      );
    }

    final seqTotal = viewedCard.sequenceEntries.fold(0, (sum, e) => sum + e.score);
    final fullTotal = viewedCard.fullenEntries.fold(0, (sum, e) => sum + e.score);
    final pokerTotal = viewedCard.pokerEntries.fold(0, (sum, e) => sum + e.score);

    String shortLine(FigureLine line) => switch (line) {
          FigureLine.aces => 'A',
          FigureLine.kings => 'K',
          FigureLine.queens => 'Q',
          FigureLine.jacks => 'J',
          FigureLine.tens => '10',
        };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.totals,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final line in FigureLine.values)
                _totalChip(
                  context,
                  '${shortLine(line)} ${figureLineScore(line)}',
                ),
              _totalChip(context, '${strings.seqShort} $seqTotal'),
              _totalChip(context, '${strings.fullShort} $fullTotal'),
              _totalChip(context, '${strings.pokerShort} $pokerTotal'),
              _totalChip(
                context,
                '${strings.overall} $totalScore',
                highlighted: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalChip(BuildContext context, String label, {bool highlighted = false}) {
    final theme = Theme.of(context);
    final bg = highlighted
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surface;
    final fg = highlighted
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: fg,
          fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }

  DataRow _buildFigureRow(
    BuildContext context,
    FigureLine line,
    List<Player> players,
    Set<FigureLine> closedLines,
  ) {
    final theme = Theme.of(context);
    final isClosed = closedLines.contains(line);
    // Show current player's scores (MVP: all players visible but highlight current)
    final viewedCard = players[viewingPlayerIndex].scoreCard;
    final scores = viewedCard.figureScores[line]!;

    return DataRow(
      color: WidgetStateProperty.resolveWith((_) =>
          isClosed ? theme.colorScheme.errorContainer.withValues(alpha: 0.3) : null),
      cells: [
        DataCell(Text(
          _lineLabel(line),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: isClosed ? TextDecoration.lineThrough : null,
          ),
        )),
        for (var col = 0; col < columnsPerLine; col++)
          DataCell(Text(
            scores[col]?.toString() ?? '—',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scores[col] != null
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          )),
      ],
    );
  }

  DataRow _buildSpecialHeaderRow(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    return DataRow(cells: [
      DataCell(Text(strings.special, style: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ))),
      for (var i = 0; i < columnsPerLine; i++) const DataCell(SizedBox.shrink()),
    ]);
  }

  DataRow _buildSpecialRow(
    BuildContext context,
    String label,
    SpecialLine specialLine,
    List<Player> players,
    List<SpecialEntry> Function(ScoreCard) getEntries,
  ) {
    final theme = Theme.of(context);
    final entries = getEntries(players[viewingPlayerIndex].scoreCard);
    final isClosed = controller.state.closedSpecialLines.contains(specialLine);

    return DataRow(
      color: WidgetStateProperty.resolveWith((_) =>
          isClosed ? theme.colorScheme.errorContainer.withValues(alpha: 0.3) : null),
      cells: [
        DataCell(Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            decoration: isClosed ? TextDecoration.lineThrough : null,
          ),
        )),
        for (var col = 0; col < columnsPerLine; col++)
          DataCell(Text(
            col < entries.length ? entries[col].score.toString() : '—',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: col < entries.length
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          )),
      ],
    );
  }
}

/// Compact player tabs to switch whose scorecard is displayed.
class PlayerTabs extends StatelessWidget {
  final GameController controller;
  final int viewingIndex;
  final ValueChanged<int> onChanged;

  const PlayerTabs({
    super.key,
    required this.controller,
    required this.viewingIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < controller.players.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          ChoiceChip(
            label: Text(
              controller.players[i].name,
              style: theme.textTheme.labelSmall,
            ),
            selected: i == viewingIndex,
            onSelected: (_) => onChanged(i),
            avatar: i == controller.currentPlayerIndex
                ? Icon(Icons.play_arrow, size: 14, color: theme.colorScheme.primary)
                : null,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ],
    );
  }
}
