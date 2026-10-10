import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/l10n/l10n.dart';

/// A sheet with days 1–31 for which day the budget cycle resets — useful
/// when income (like a salary) doesn't land on the 1st.
Future<void> showMonthStartDayPicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => const _MonthStartDaySheet(),
  );
}

class _MonthStartDaySheet extends StatelessWidget {
  const _MonthStartDaySheet();

  Future<void> _select(BuildContext context, int day) async {
    final repo = context.read<TransactionsRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    Navigator.pop(context);
    try {
      await repo.updateMonthStartDay(day);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.couldNotSave(errorMessage(l10n, e)))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selected = context.select<TransactionsRepository, int>(
      (r) => r.monthStartDay,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.monthStartsOn,
            style: AppText.section.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.monthStartsOnHelp,
            style: AppText.body.copyWith(color: c.muted),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (var day = 1; day <= 31; day++)
                Material(
                  color: day == selected ? c.primary : c.surfaceHigh,
                  borderRadius: BorderRadius.circular(AppRadius.iconTile),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.iconTile),
                    onTap: () => _select(context, day),
                    child: Center(
                      child: Text(
                        '$day',
                        style: AppText.tabular(
                          AppText.rowTitle.copyWith(
                            fontWeight: FontWeight.w800,
                            color: day == selected ? c.onPrimary : c.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            context.l10n.monthStartsOnShortMonths,
            style: AppText.caption.copyWith(color: c.muted),
          ),
        ],
      ),
    );
  }
}
