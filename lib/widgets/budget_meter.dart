import 'package:flutter/material.dart';
import 'package:monthly_traq/app/palette.dart';

/// A single ratio against a limit — a linear meter whose fill escalates
/// from the brand hue to warning to critical as spending approaches and
/// then exceeds the monthly budget.
class BudgetMeter extends StatelessWidget {
  final double ratio;
  final String spentLabel;
  final String budgetLabel;

  const BudgetMeter({
    super.key,
    required this.ratio,
    required this.spentLabel,
    required this.budgetLabel,
  });

  Color get _fillColor {
    if (ratio >= 1) return AppPalette.critical;
    if (ratio >= 0.7) return AppPalette.warning;
    return AppPalette.sequentialFill;
  }

  @override
  Widget build(BuildContext context) {
    final clamped = ratio.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly budget',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              Text(
                ratio >= 1 ? 'Over budget' : '${(clamped * 100).round()}% used',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _fillColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Stack(
                children: [
                  Container(color: AppPalette.sequentialTrack),
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    widthFactor: clamped,
                    alignment: Alignment.centerLeft,
                    child: Container(color: _fillColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                spentLabel,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                budgetLabel,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
