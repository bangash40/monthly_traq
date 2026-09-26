import 'package:flutter/material.dart';
import 'package:monthly_traq/app/palette.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';

/// A single ratio against a limit — a linear meter whose fill escalates
/// from the brand hue to warning to critical as spending approaches and
/// then exceeds the monthly budget. The unfilled track is a paler step of
/// that same brand hue, so the meter reads as one ramp rather than an
/// unrelated fixed color dropped into whichever theme is active.
class BudgetMeter extends StatelessWidget {
  final double ratio;
  final String spentLabel;
  final String budgetLabel;
  final VoidCallback? onEdit;

  const BudgetMeter({
    super.key,
    required this.ratio,
    required this.spentLabel,
    required this.budgetLabel,
    this.onEdit,
  });

  Color _fillColor(BuildContext context) {
    if (ratio >= 1) return AppPalette.critical;
    if (ratio >= 0.7) return AppPalette.warning;
    return themeAccent(context);
  }

  /// Same meaning as [_fillColor], but readable as text — the warning
  /// yellow is a fill color only.
  Color _labelColor(BuildContext context) {
    if (ratio >= 1 || ratio < 0.7) return _fillColor(context);
    return AppPalette.warningText(Theme.of(context).brightness);
  }

  @override
  Widget build(BuildContext context) {
    final clamped = ratio.clamp(0.0, 1.0);
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final fillColor = _fillColor(context);
    final trackColor = themeAccent(context).withValues(alpha: 0.18);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Monthly budget',
                    style: TextStyle(fontSize: 13, color: onSurfaceVariant),
                  ),
                  if (onEdit != null) ...[
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                ratio >= 1 ? 'Over budget' : '${(clamped * 100).round()}% used',
                style: AppText.labelStrong.copyWith(
                  color: _labelColor(context),
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
                  Container(color: trackColor),
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    widthFactor: clamped,
                    alignment: Alignment.centerLeft,
                    child: Container(color: fillColor),
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
                style: TextStyle(fontSize: 13, color: onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
