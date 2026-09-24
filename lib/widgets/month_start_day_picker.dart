import 'package:flutter/material.dart';
import 'package:monthly_traq/services/transactions_repository.dart';

/// Shows a bottom sheet listing days 1-31 so the user can pick which day of
/// the calendar month their budget cycle resets on — useful when income
/// (e.g. salary) doesn't reliably land on the 1st.
Future<void> showMonthStartDayPicker(
  BuildContext context,
  TransactionsRepository repo,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Monthly Start Date',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      '${repo.monthStartDay}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: 31,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isSelected = day == repo.monthStartDay;
                    return ListTile(
                      title: Text(
                        '$day',
                        textAlign: TextAlign.center,
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        try {
                          await repo.updateMonthStartDay(day);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not save: $e')),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
