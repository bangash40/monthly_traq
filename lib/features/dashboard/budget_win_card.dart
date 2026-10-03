import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/app_settings.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/services/budget_win.dart';
import 'package:monthly_traq/widgets/motion.dart';
import 'package:monthly_traq/widgets/ui.dart';

/// "September — under budget!" at the top of Home for the first days of a
/// new cycle, with a burst of confetti the first time it's seen in a
/// session. Closing it keeps it closed.
class BudgetWinCard extends StatefulWidget {
  final BudgetWin win;

  const BudgetWinCard({super.key, required this.win});

  @override
  State<BudgetWinCard> createState() => _BudgetWinCardState();
}

class _BudgetWinCardState extends State<BudgetWinCard>
    with SingleTickerProviderStateMixin {
  /// The confetti plays once per app session, not every time Home rebuilds.
  static bool _confettiPlayed = false;

  late final _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_confettiPlayed && !Motion.reduced(context)) {
      _confettiPlayed = true;
      _confetti.forward();
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final win = widget.win;
    final cycle = win.cycle;
    final name = cycle.startDay == 1
        ? DateFormat('MMMM').format(cycle.start)
        : 'Last cycle';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppCard(
          padding: const EdgeInsets.fromLTRB(18, 16, 6, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTile(
                icon: Icons.emoji_events_rounded,
                color: c.warning,
                background: c.tint(c.warningFill),
                size: 46,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      '$name — under budget!',
                      style: AppText.section.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You kept ${money.format(win.leftOver)} of your '
                      '${money.format(win.budget)} budget. Nice work.',
                      style: AppText.body.copyWith(color: c.muted),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Dismiss',
                icon: Icon(Icons.close, color: c.muted, size: 20),
                onPressed: () =>
                    context.read<AppSettings>().dismissBudgetWin(win.id),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: -24,
          height: 200,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _confetti,
              builder: (context, _) => _confetti.isAnimating
                  ? CustomPaint(
                      painter: _ConfettiPainter(
                        progress: _confetti.value,
                        colors: [c.primary, c.warning, c.income, c.spending],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}

/// A one-shot burst of small paper pieces drifting down and fading out.
class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  _ConfettiPainter({required this.progress, required this.colors});

  static final _pieces = _makePieces();

  static List<_Piece> _makePieces() {
    final random = math.Random(7);
    return [
      for (var i = 0; i < 42; i++)
        _Piece(
          x: random.nextDouble(),
          delay: random.nextDouble() * 0.25,
          drift: (random.nextDouble() - 0.5) * 0.3,
          sway: random.nextDouble() * math.pi * 2,
          spin: (random.nextDouble() - 0.5) * 10,
          size: 5 + random.nextDouble() * 4,
          color: i % 4,
        ),
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final piece in _pieces) {
      final t = ((progress - piece.delay) / (1 - piece.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final x =
          piece.x * size.width +
          piece.drift * size.width * t +
          math.sin(piece.sway + t * 6) * 8;
      final y = -10 + t * t * (size.height + 20) + t * 30;
      final fade = t < 0.7 ? 1.0 : 1 - (t - 0.7) / 0.3;
      paint.color = colors[piece.color].withValues(alpha: fade);
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(piece.spin * t);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size,
            height: piece.size * 0.55,
          ),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

class _Piece {
  final double x;
  final double delay;
  final double drift;
  final double sway;
  final double spin;
  final double size;
  final int color;

  const _Piece({
    required this.x,
    required this.delay,
    required this.drift,
    required this.sway,
    required this.spin,
    required this.size,
    required this.color,
  });
}
