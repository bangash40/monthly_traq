import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monthly_traq/app/palette.dart';
import 'package:monthly_traq/models/monthly_total.dart';

/// Income vs expense, grouped by month — a compact bar-pair chart with no
/// external chart package. Both series share one scale (the max value
/// across all months shown) so bar heights are directly comparable.
class MonthlyTrendChart extends StatelessWidget {
  final List<MonthlyTotal> months;

  const MonthlyTrendChart({super.key, required this.months});

  static const _maxBarHeight = 100.0;
  static const _barWidth = 12.0;

  @override
  Widget build(BuildContext context) {
    final maxValue = months
        .expand((m) => [m.income, m.expense])
        .fold(0.0, (max, v) => v > max ? v : max);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly trend',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const _Legend(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: months.map((m) {
              return _MonthColumn(
                total: m,
                maxValue: maxValue,
                maxBarHeight: _maxBarHeight,
                barWidth: _barWidth,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _LegendDot(color: AppPalette.good, label: 'Income'),
        SizedBox(width: 16),
        _LegendDot(color: AppPalette.critical, label: 'Expense'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }
}

class _MonthColumn extends StatelessWidget {
  final MonthlyTotal total;
  final double maxValue;
  final double maxBarHeight;
  final double barWidth;

  const _MonthColumn({
    required this.total,
    required this.maxValue,
    required this.maxBarHeight,
    required this.barWidth,
  });

  double _heightFor(double value) {
    if (maxValue <= 0) return 0;
    return (value / maxValue) * maxBarHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _Bar(
              height: _heightFor(total.income),
              width: barWidth,
              color: AppPalette.good,
            ),
            const SizedBox(width: 3),
            _Bar(
              height: _heightFor(total.expense),
              width: barWidth,
              color: AppPalette.critical,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          DateFormat('MMM').format(total.month),
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final double width;
  final Color color;

  const _Bar({required this.height, required this.width, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}
