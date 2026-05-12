import 'package:flutter/material.dart';

import '../../engine/game_engine.dart';
import '../../engine/models.dart';
import '../i18n/app_strings.dart';
import '../game_controller.dart';

/// Panel of action buttons driven by [getValidActions].
class ActionPanel extends StatelessWidget {
  final GameController controller;
  final AppStrings strings;
  final VoidCallback? onScored;

  const ActionPanel({
    super.key,
    required this.controller,
    required this.strings,
    this.onScored,
  });

  @override
  Widget build(BuildContext context) {
    final va = controller.validActions;
    final theme = Theme.of(context);

    if (controller.gameOver) {
      return Center(
        child: FilledButton.icon(
          onPressed: controller.restart,
          icon: const Icon(Icons.replay),
          label: Text(strings.newGame),
        ),
      );
    }

    return SingleChildScrollView(
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [
          // --- Roll / Hold / Pass ---
          if (va.canHold && controller.selectedDice.isNotEmpty)
            _actionChip(
              context,
              label: strings.holdAndRoll,
              icon: Icons.casino,
              color: theme.colorScheme.primary,
              onTap: controller.rollWithHeld,
            ),
          if (va.canPass)
            _actionChip(
              context,
              label: controller.currentRollIndex >= 2
                  ? strings.endTurn
                  : strings.pass,
              icon: Icons.skip_next,
              color: theme.colorScheme.secondary,
              onTap: controller.pass,
            ),

          // --- Figure scoring ---
          for (final a in va.figureScoring)
            _actionChip(
              context,
              label: strings.figurePoints(_lineShort(a.line), a.points),
              icon: Icons.check_circle_outline,
              color: theme.colorScheme.tertiary,
              onTap: () { controller.scoreFigure(a.line, a.points); onScored?.call(); },
            ),

          // --- Specials in figure ---
          for (final a in va.specialInFigure)
            _actionChip(
              context,
              label: strings.specialToFigure(_lineShort(a.line), a.points),
              icon: Icons.star_outline,
              color: theme.colorScheme.error,
              onTap: () { controller.scoreSpecialInFigure(a.line, a.points); onScored?.call(); },
            ),

          // --- Sequences ---
          for (final a in va.sequences)
            _actionChip(
              context,
              label: strings.sequencePoints(a.points),
              icon: Icons.linear_scale,
              color: Colors.deepPurple,
              onTap: () { controller.scoreSequence(a.points, fromHand: a.fromHand); onScored?.call(); },
            ),

          // --- Fullens ---
          for (final a in va.fullens)
            _actionChip(
              context,
              label: strings.fullPoints(a.points),
              icon: Icons.view_in_ar,
              color: Colors.teal,
              onTap: () { controller.scoreFullen(a.points, fromHand: a.fromHand); onScored?.call(); },
            ),

          // --- Pokers ---
          for (final a in va.pokers)
            _actionChip(
              context,
              label: strings.pokerPoints(a.points),
              icon: Icons.whatshot,
              color: Colors.orange,
              onTap: () { controller.scorePoker(a.points); onScored?.call(); },
            ),

          // --- Accumulation ---
          if (va.canContinueAccumulation)
            _actionChip(
              context,
              label: strings.continueAccum,
              icon: Icons.replay,
              color: Colors.indigo,
              onTap: controller.continueAccumulation,
            ),
          if (va.canFinalize)
            _actionChip(
              context,
              label: strings.finalizeAccum,
              icon: Icons.done_all,
              color: Colors.green,
              onTap: controller.finalizeAccumulation,
            ),
        ],
      ),
    );
  }

  String _lineShort(FigureLine line) => switch (line) {
        FigureLine.aces => 'A',
        FigureLine.kings => 'K',
        FigureLine.queens => 'Q',
        FigureLine.jacks => 'J',
        FigureLine.tens => '10',
      };

  Widget _actionChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(fontSize: 12, color: color)),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      onPressed: onTap,
    );
  }
}
