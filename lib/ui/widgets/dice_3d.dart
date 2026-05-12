import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../engine/models.dart';

// ---------------------------------------------------------------------------
// Colours
// ---------------------------------------------------------------------------
const _kingRed = Color(0xFFC62828);
const _queenGreen = Color(0xFF2E7D32);
const _jackBlue = Color(0xFF1565C0);
const _aceBlack = Color(0xFF1A1A2E);
const _clubBlack = Color(0xFF1A1A2E);
const _diamondRed = Color(0xFFB71C1C);

// Table
const _tableGreen = Color(0xFF1B5E20);
const _tableFelt = Color(0xFF2E7D32);
const _tableEdge = Color(0xFF4E342E);

// Dice
const double _dieSize = 56.0;

// ---------------------------------------------------------------------------
// Pip positions (normalised 0–1)
// ---------------------------------------------------------------------------
const _ninePositions = [
  Offset(0.25, 0.10), Offset(0.75, 0.10),
  Offset(0.25, 0.32), Offset(0.75, 0.32),
  Offset(0.50, 0.50),
  Offset(0.25, 0.68), Offset(0.75, 0.68),
  Offset(0.25, 0.90), Offset(0.75, 0.90),
];

const _tenPositions = [
  Offset(0.25, 0.08), Offset(0.75, 0.08),
  Offset(0.50, 0.22),
  Offset(0.25, 0.36), Offset(0.75, 0.36),
  Offset(0.25, 0.58), Offset(0.75, 0.58),
  Offset(0.50, 0.72),
  Offset(0.25, 0.86), Offset(0.75, 0.86),
];

// ---------------------------------------------------------------------------
// Dice3DRow — scatter + settle on green felt table
// ---------------------------------------------------------------------------

class Dice3DRow extends StatefulWidget {
  final List<Die> dice;
  final Set<int> selected;
  final bool rolling;
  final bool canSelect;
  final ValueChanged<int> onToggle;
  final VoidCallback? onLanded;

  const Dice3DRow({
    super.key,
    required this.dice,
    required this.selected,
    required this.rolling,
    required this.canSelect,
    required this.onToggle,
    this.onLanded,
  });

  @override
  State<Dice3DRow> createState() => _Dice3DRowState();
}

class _Dice3DRowState extends State<Dice3DRow> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  // Per-die animation values
  late List<Animation<Offset>> _posAnims;
  late List<Animation<double>> _spinAnims; // flat spin (top-down rotation)
  late List<Animation<double>> _scaleAnims; // scale bounce on landing
  late List<double> _landingTilts; // small final tilt angle

  final _rng = math.Random();

  // Small Y variations so dice don't sit in a perfect line
  static const _yOffsets = [0.0, -4.0, 2.0, -2.0, 4.0];

  /// Compute non-overlapping positions: held dice on the left, rolling in
  /// the centre. Returns one Offset per die (indexed 0..4).
  List<Offset> _computePositions() {
    final heldIdx = <int>[];
    final rollIdx = <int>[];
    for (var i = 0; i < 5; i++) {
      if (widget.dice[i].held) {
        heldIdx.add(i);
      } else {
        rollIdx.add(i);
      }
    }

    const spacing = 66.0; // 56px die + 10px gap — no overlap
    const groupGap = 20.0; // extra gap between held and rolling groups
    final ordered = [...heldIdx, ...rollIdx];
    final hasGap = heldIdx.isNotEmpty && rollIdx.isNotEmpty;
    final totalWidth =
        (ordered.length - 1) * spacing + (hasGap ? groupGap : 0);
    final startX = -totalWidth / 2;

    final positions = List<Offset>.filled(5, Offset.zero);
    for (var j = 0; j < ordered.length; j++) {
      final extra = (hasGap && j >= heldIdx.length) ? groupGap : 0.0;
      final x = startX + j * spacing + extra;
      final idx = ordered[j];
      positions[idx] = Offset(x, _yOffsets[idx]);
    }
    return positions;
  }

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(5, (_) => AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    ));
    _spinAnims = _dummyAnims(0.0);
    _scaleAnims = _dummyAnims(1.0);
    _landingTilts = List.filled(5, 0.0);

    final positions = _computePositions();
    _posAnims = List.generate(5, (i) =>
      ConstantTween(positions[i]).animate(_controllers[i]),
    );
  }

  List<Animation<double>> _dummyAnims(double val) =>
    List.generate(5, (i) => ConstantTween(val).animate(_controllers[i]));

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(Dice3DRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rolling && !oldWidget.rolling) {
      _startScatterAnimations();
    }
  }

  void _startScatterAnimations() {
    final targets = _computePositions();

    // First pass: slide held dice to their new positions (left side)
    bool anyHeldMoved = false;
    for (var i = 0; i < 5; i++) {
      if (!widget.dice[i].held) continue;

      final currentPos = _posAnims[i].value;
      final targetPos = targets[i];
      if ((currentPos - targetPos).distance > 1) {
        anyHeldMoved = true;
        _posAnims[i] = Tween<Offset>(
          begin: currentPos,
          end: targetPos,
        ).animate(CurvedAnimation(
          parent: _controllers[i],
          curve: Curves.easeInOut,
        ));
        final curSpin = _spinAnims[i].value;
        _spinAnims[i] =
            ConstantTween(curSpin).animate(_controllers[i]);
        _scaleAnims[i] =
            ConstantTween(1.0).animate(_controllers[i]);
        _controllers[i].reset();
        _controllers[i].forward();
      }
    }

    // Second pass: launch rolling dice (with delay if held dice moved)
    final rollDelay = anyHeldMoved ? 350 : 0;
    int lastRollingDie = -1;
    for (var i = 0; i < 5; i++) {
      if (widget.dice[i].held) continue;
      lastRollingDie = i;

      // Small jitter so it doesn't land pixel-perfect every time
      final jx = (_rng.nextDouble() - 0.5) * 14;
      final jy = (_rng.nextDouble() - 0.5) * 12;
      final landing = targets[i] + Offset(jx, jy);

      // Start from center-top (throw origin)
      _posAnims[i] = Tween<Offset>(
        begin: const Offset(0, -50),
        end: landing,
      ).animate(CurvedAnimation(
        parent: _controllers[i],
        curve: Curves.easeOutCubic,
      ));

      // Flat spin: 2–4 full rotations, random direction
      final spins = (2 + _rng.nextInt(3)) * 2 * math.pi;
      _spinAnims[i] = Tween<double>(
        begin: 0.0,
        end: spins * (_rng.nextBool() ? 1 : -1),
      ).animate(CurvedAnimation(
        parent: _controllers[i],
        curve: Curves.easeOutCubic,
      ));

      // Scale: start slightly large (thrown toward viewer), settle to 1.0
      _scaleAnims[i] = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 1.3, end: 0.95)
            .chain(CurveTween(curve: Curves.easeOut)),
          weight: 60,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 0.95, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 20,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
          weight: 20,
        ),
      ]).animate(_controllers[i]);

      // Random final tilt (slight angle, like a die not perfectly flat)
      _landingTilts[i] = (_rng.nextDouble() - 0.5) * 0.12; // ±~3.5°

      // Stagger (plus rollDelay so held dice slide first)
      final delay = rollDelay + i * 35 + _rng.nextInt(25);
      _controllers[i].reset();
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) _controllers[i].forward();
      });
    }

    // Fire onLanded when the last rolling die finishes
    if (lastRollingDie >= 0 && widget.onLanded != null) {
      void listener(AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _controllers[lastRollingDie].removeStatusListener(listener);
          widget.onLanded!();
        }
      }
      _controllers[lastRollingDie].addStatusListener(listener);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.2,
          colors: [_tableFelt, _tableGreen],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _tableEdge, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Felt texture
            CustomPaint(
              size: const Size(double.infinity, 150),
              painter: _FeltPainter(),
            ),
            // Dice
            for (var i = 0; i < widget.dice.length; i++)
              _buildDie(i),
          ],
        ),
      ),
    );
  }

  Widget _buildDie(int i) {
    final isHeld = widget.dice[i].held;
    final isSelected = widget.selected.contains(i);
    final animating = _controllers[i].isAnimating && !isHeld;

    return AnimatedBuilder(
      animation: _controllers[i],
      builder: (context, _) {
        // Always use animation values — they hold the correct end values
        // after completion, avoiding a snap to a different position.
        final pos = _posAnims[i].value;
        final spin = _spinAnims[i].value;
        final scale = _scaleAnims[i].value;
        // Tilt eases in at the end of animation
        final tiltProgress = _controllers[i].isAnimating
            ? Curves.easeIn.transform(_controllers[i].value)
            : 1.0;
        final tilt = _landingTilts[i] * tiltProgress;

        return Transform.translate(
          offset: pos,
          child: Transform.rotate(
            angle: spin + tilt,
            child: Transform.scale(
              scale: scale,
              child: GestureDetector(
                onTap: widget.canSelect ? () => widget.onToggle(i) : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drop shadow on felt
                    Container(
                      width: _dieSize - 6,
                      height: _dieSize - 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: animating ? 0.35 : 0.2,
                            ),
                            blurRadius: animating ? 14 : 6,
                            offset: Offset(
                              animating ? 3 : 1,
                              animating ? 5 : 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // The die face, positioned on top of its shadow
                    Transform.translate(
                      offset: Offset(0, -(_dieSize - 6)),
                      child: _DieFace(
                        face: widget.dice[i].face,
                        selected: isSelected,
                        held: isHeld,
                      ),
                    ),
                    // HOLD badge
                    Transform.translate(
                      offset: Offset(0, -(_dieSize - 8)),
                      child: isSelected
                          ? _buildHoldBadge(Theme.of(context))
                          : const SizedBox(height: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHoldBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 3,
          ),
        ],
      ),
      child: Text(
        'HOLD',
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Felt texture painter
// ---------------------------------------------------------------------------

class _FeltPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;
    const spacing = 8.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Single die face (flat, top-down view)
// ---------------------------------------------------------------------------

class _DieFace extends StatelessWidget {
  final DieFace face;
  final bool selected;
  final bool held;

  const _DieFace({required this.face, required this.selected, required this.held});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      width: _dieSize,
      height: _dieSize,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFCFCFC),
        border: Border.all(
          color: selected ? theme.colorScheme.primary : const Color(0xFFBDBDBD),
          width: selected ? 2.5 : 1.2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Opacity(
        opacity: held ? 0.5 : 1.0,
        child: _buildContent(isDark),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return switch (face) {
      DieFace.ace => Center(
        child: Text('\u2660',
          style: TextStyle(fontSize: 32, color: isDark ? Colors.white70 : _aceBlack)),
      ),
      DieFace.king => _figure(isDark, _kingRed, '\u265A'),
      DieFace.queen => _figure(isDark, _queenGreen, '\u265B'),
      DieFace.jack => _figure(isDark, _jackBlue, '\u265E'),
      DieFace.ten => _pips(isDark, '\u2666', _diamondRed, _tenPositions),
      DieFace.nine => _pips(isDark, '\u2663', _clubBlack, _ninePositions),
    };
  }

  Widget _figure(bool isDark, Color color, String ch) {
    final fg = isDark ? Color.lerp(color, Colors.white, 0.35)! : color;
    return Container(
      color: fg.withValues(alpha: isDark ? 0.10 : 0.06),
      child: Center(child: Text(ch, style: TextStyle(fontSize: 32, color: fg))),
    );
  }

  Widget _pips(bool isDark, String suit, Color suitColor, List<Offset> positions) {
    final color = isDark ? Color.lerp(suitColor, Colors.white, 0.35)! : suitColor;
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      const pipSize = 10.0;
      return Stack(children: [
        for (final pos in positions)
          Positioned(
            left: pos.dx * w - pipSize / 2,
            top: pos.dy * h - pipSize / 2,
            child: SizedBox(
              width: pipSize, height: pipSize,
              child: FittedBox(child: Text(suit, style: TextStyle(color: color))),
            ),
          ),
      ]);
    });
  }
}
