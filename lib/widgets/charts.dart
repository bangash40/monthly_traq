import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/models/monthly_total.dart';
import 'package:monthly_traq/services/cycle_stats.dart';
import 'package:monthly_traq/widgets/motion.dart';

/// The smallest "round" number (1, 2 or 5 × 10ⁿ) at or above [value], so
/// chart axes stop at 60k or 120k rather than 113,450.
double niceCeiling(double value) {
  if (value <= 0) return 1;
  final magnitude = math
      .pow(10, (math.log(value) / math.ln10).floor())
      .toDouble();
  for (final step in [1, 2, 2.5, 5, 10]) {
    if (step * magnitude >= value) return step * magnitude;
  }
  return 10 * magnitude;
}

/// Share per category as a ring, each segment in the category's own color,
/// with small gaps between segments and [center] in the middle. The ring
/// sweeps round clockwise when it appears or its numbers change.
class CategoryDonut extends StatelessWidget {
  final List<CategoryTotal> totals;
  final Widget center;
  final double size;

  const CategoryDonut({
    super.key,
    required this.totals,
    required this.center,
    this.size = 210,
  });

  @override
  Widget build(BuildContext context) {
    final values = [for (final t in totals) t.amount];
    return SizedBox.square(
      dimension: size,
      child: GrowIn(
        trigger: Object.hashAll(values),
        builder: (context, progress) => CustomPaint(
          painter: _DonutPainter(
            values: values,
            colors: [for (final t in totals) t.category.color],
            gapColor: context.colors.surface,
            progress: progress,
          ),
          child: Center(
            child: Padding(padding: const EdgeInsets.all(34), child: center),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final Color gapColor;

  /// How much of the ring is drawn, 0 to 1, clockwise from 12 o'clock.
  final double progress;

  _DonutPainter({
    required this.values,
    required this.colors,
    required this.gapColor,
    this.progress = 1,
  });

  static const _stroke = 26.0;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (sum, v) => sum + v);
    if (total <= 0) return;

    final radius = (size.shortestSide - _stroke) / 2;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: radius,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke;

    final drawnTo = -math.pi / 2 + progress * 2 * math.pi;
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 2 * math.pi;
      final shown = math.min(sweep, drawnTo - start);
      if (shown > 0) {
        canvas.drawArc(rect, start, shown, false, paint..color = colors[i]);
      }
      start += sweep;
    }

    // Gaps in the card color keep neighbouring segments distinct.
    if (values.length > 1) {
      final gap = Paint()
        ..color = gapColor
        ..strokeWidth = 3;
      final center = rect.center;
      final inner = radius - _stroke / 2 - 1;
      final outer = radius + _stroke / 2 + 1;
      var angle = -math.pi / 2;
      for (final v in values) {
        if (angle > drawnTo) break;
        final direction = Offset(math.cos(angle), math.sin(angle));
        canvas.drawLine(
          center + direction * inner,
          center + direction * outer,
          gap,
        );
        angle += v / total * 2 * math.pi;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.values != values ||
      old.colors != colors ||
      old.gapColor != gapColor ||
      old.progress != progress;
}

/// Income vs spending for recent months: grouped bars on a light grid with
/// round-number axis labels. The last month is the selected one and its
/// label is bold.
class MonthlyTrendChart extends StatelessWidget {
  final List<MonthlyTotal> months;

  const MonthlyTrendChart({super.key, required this.months});

  static const _chartHeight = 150.0;
  static const _axisWidth = 40.0;
  static const _plotTop = 8.0;
  static const _plotBottom = 8.0;
  static const _plotHeight = _chartHeight - _plotTop - _plotBottom;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final peak = months.fold(
      0.0,
      (m, t) => math.max(m, math.max(t.income, t.expense)),
    );
    final top = niceCeiling(peak);
    final axisStyle = AppText.tabular(AppText.tiny.copyWith(color: c.muted));

    return Semantics(
      label: 'Income and spending, last ${months.length} months',
      child: Column(
        children: [
          SizedBox(
            height: _chartHeight,
            child: Stack(
              children: [
                // Bars span y = _plotTop..(_chartHeight - _plotBottom); each
                // gridline sits at its value's height, centered on the
                // 14px-tall axis label beside it.
                for (final fraction in [1.0, 0.5, 0.0])
                  Positioned(
                    left: 0,
                    right: 0,
                    top:
                        _chartHeight - _plotBottom - fraction * _plotHeight - 7,
                    child: Row(
                      children: [
                        SizedBox(
                          width: _axisWidth,
                          child: Text(
                            MoneyFormatter.compact(top * fraction),
                            style: axisStyle,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: fraction == 0
                                ? c.hairline
                                : c.hairline.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                Positioned.fill(
                  left: _axisWidth,
                  bottom: _plotBottom,
                  top: _plotTop,
                  child: GrowIn(
                    trigger: Object.hashAll([
                      for (final m in months) ...[m.income, m.expense],
                    ]),
                    builder: (context, grow) => Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final m in months)
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _Bar(
                                  fraction: m.income / top * grow,
                                  color: c.incomeFill,
                                ),
                                const SizedBox(width: 5),
                                _Bar(
                                  fraction: m.expense / top * grow,
                                  color: c.spendingFill,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: _axisWidth),
            child: Row(
              children: [
                for (final (i, m) in months.indexed)
                  Expanded(
                    child: Text(
                      DateFormat('MMM').format(m.month),
                      textAlign: TextAlign.center,
                      style: AppText.caption.copyWith(
                        fontSize: 13,
                        color: i == months.length - 1 ? c.ink : c.muted,
                        fontWeight: i == months.length - 1
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double fraction;
  final Color color;

  const _Bar({required this.fraction, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight * fraction.clamp(0.0, 1.0);
        return Container(
          width: 12,
          height: fraction > 0 ? math.max(height, 3) : 0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.bar),
            ),
          ),
        );
      },
    );
  }
}

/// One bar per day of a cycle in [color]: the biggest day at full
/// strength, other days softer, and quiet days as small dots.
class DailyBars extends StatelessWidget {
  final List<DayTotal> days;
  final Color color;

  const DailyBars({super.key, required this.days, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final peak = days.fold(0.0, (m, d) => math.max(m, d.amount));

    return SizedBox(
      height: 120,
      child: GrowIn(
        trigger: Object.hashAll([for (final d in days) d.amount]),
        builder: (context, grow) => Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final day in days)
              Expanded(
                child: Tooltip(
                  message:
                      '${DateFormat('MMM d').format(day.day)}: '
                      '${context.money.format(day.amount)}',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: day.amount <= 0
                        ? Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: c.surfaceHigh,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          )
                        : FractionallySizedBox(
                            heightFactor:
                                math.max(day.amount / peak, 0.06) * grow,
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              decoration: BoxDecoration(
                                color: day.amount == peak
                                    ? color
                                    : color.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.bar,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
