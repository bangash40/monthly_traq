import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/models/category_model.dart';

/// Share of spending per category as a ring, each segment in the
/// category's own fixed color, with the total in the middle. Drawn with a
/// CustomPainter — no chart package.
class CategoryDonut extends StatelessWidget {
  final List<MapEntry<CategoryModel, double>> entries;
  final String centerValue;
  final String centerLabel;

  const CategoryDonut({
    super.key,
    required this.entries,
    required this.centerValue,
    required this.centerLabel,
  });

  static const _size = 180.0;

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return SizedBox(
      width: _size,
      height: _size,
      child: CustomPaint(
        painter: _DonutPainter(
          values: [for (final e in entries) e.value],
          colors: [for (final e in entries) e.key.color],
          gapColor: Theme.of(context).cardColor,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(child: Text(centerValue, style: AppText.statValue)),
                Text(
                  centerLabel,
                  style: AppText.caption.copyWith(color: onSurfaceVariant),
                ),
              ],
            ),
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

  _DonutPainter({
    required this.values,
    required this.colors,
    required this.gapColor,
  });

  static const _strokeWidth = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (sum, v) => sum + v);
    if (total <= 0) return;

    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (size.shortestSide - _strokeWidth) / 2,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 2 * math.pi;
      canvas.drawArc(rect, start, sweep, false, paint..color = colors[i]);
      start += sweep;
    }

    // Thin separators in the card color, so neighbouring segments stay
    // distinct even when two categories share a hue.
    if (values.length > 1) {
      final separator = Paint()
        ..color = gapColor
        ..strokeWidth = 2;
      final center = rect.center;
      final inner = rect.width / 2 - _strokeWidth / 2 - 1;
      final outer = rect.width / 2 + _strokeWidth / 2 + 1;
      var angle = -math.pi / 2;
      for (final v in values) {
        final direction = Offset(math.cos(angle), math.sin(angle));
        canvas.drawLine(
          center + direction * inner,
          center + direction * outer,
          separator,
        );
        angle += v / total * 2 * math.pi;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.colors != colors ||
      oldDelegate.gapColor != gapColor;
}
