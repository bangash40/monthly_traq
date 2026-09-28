import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/app_settings.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/services/budget_cycle.dart';
import 'package:monthly_traq/services/calculator.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/month_start_day_picker.dart';
import 'package:monthly_traq/widgets/ui.dart';

/// The Monthly budget sheet: the amount, and which day the cycle resets.
Future<void> showBudgetSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const _BudgetSheet(),
  );
}

class _BudgetSheet extends StatefulWidget {
  const _BudgetSheet();

  @override
  State<_BudgetSheet> createState() => _BudgetSheetState();
}

class _BudgetSheetState extends State<_BudgetSheet> {
  late final _grouping = context.read<AppSettings>().thousandsSeparator;
  late final _controller = TextEditingController(
    text: GroupedNumberFormatter.formatText(
      Calculator.plain(context.read<TransactionsRepository>().monthlyBudget),
      grouping: _grouping,
    ),
  );
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = double.tryParse(_controller.text.replaceAll(',', ''));
    if (value == null || value < 0) {
      setState(() => _error = 'Enter an amount, or 0 for no budget');
      return;
    }
    setState(() {
      _error = null;
      _isSaving = true;
    });
    try {
      await context.read<TransactionsRepository>().updateMonthlyBudget(value);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save budget: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final repo = context.watch<TransactionsRepository>();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Monthly budget', style: AppText.section.copyWith(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            'How much you plan to spend each cycle. The meter on Home fills '
            'as you go.',
            style: AppText.body.copyWith(color: c.muted),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [GroupedNumberFormatter(grouping: _grouping)],
            style: AppText.amountLarge.copyWith(fontSize: 28),
            decoration: InputDecoration(
              errorText: _error,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 18, right: 10),
                child: Text(
                  repo.currencySymbol,
                  style: AppText.section.copyWith(fontSize: 22, color: c.muted),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            decoration: BoxDecoration(
              color: c.surfaceHigh,
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: Row(
              children: [
                Icon(Icons.event_repeat, color: c.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resets on the ${ordinal(repo.monthStartDay)}',
                        style: AppText.rowTitle.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Match it to your payday',
                        style: AppText.label.copyWith(color: c.muted),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    onTap: () => showMonthStartDayPicker(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Text(
                        'Change',
                        style: AppText.rowTitle.copyWith(
                          color: c.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: ButtonLabel('Save', loading: _isSaving),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Keeps a money field to digits and one decimal point (2 places), and
/// groups the whole part as you type: "60000" shows as "60,000".
class GroupedNumberFormatter extends TextInputFormatter {
  final bool grouping;

  GroupedNumberFormatter({this.grouping = true});

  static String formatText(String raw, {bool grouping = true}) {
    var cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    final dot = cleaned.indexOf('.');
    if (dot != -1) {
      final decimals = cleaned.substring(dot + 1).replaceAll('.', '');
      cleaned =
          '${cleaned.substring(0, dot)}.${decimals.length > 2 ? decimals.substring(0, 2) : decimals}';
    }
    if (cleaned.isEmpty) return '';

    final parts = cleaned.split('.');
    final whole = parts[0].isEmpty ? '0' : parts[0];
    final wholeNumber = int.tryParse(whole);
    final grouped = wholeNumber == null
        ? whole
        : NumberFormat(grouping ? '#,##0' : '0', 'en_US').format(wholeNumber);
    return parts.length > 1 ? '$grouped.${parts[1]}' : grouped;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = formatText(newValue.text, grouping: grouping);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
