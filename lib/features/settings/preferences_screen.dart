import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/currencies.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/dev/sample_data.dart';
import 'package:monthly_traq/features/settings/category_settings_screen.dart';
import 'package:monthly_traq/features/settings/currency_picker_screen.dart';
import 'package:monthly_traq/features/settings/my_profile_screen.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/edit_budget_dialog.dart';
import 'package:monthly_traq/widgets/month_start_day_picker.dart';

/// Only settings that actually work are listed, grouped by what they
/// affect. Look-and-feel settings (theme, mode, font size) live on the
/// Appearance screen instead.
class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionsRepository>();
    final currency = NumberFormat.decimalPattern();
    final selectedCurrency = kCurrencyOptions
        .cast<CurrencyOption?>()
        .firstWhere((c) => c?.code == repo.currencyCode, orElse: () => null);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          _SettingsSection(
            title: 'Account',
            rows: [
              _SettingsRow(
                icon: Icons.person_outline,
                label: 'My Profile',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyProfileScreen(),
                  ),
                ),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Budget',
            rows: [
              _SettingsRow(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Monthly budget',
                trailingText:
                    '${repo.currencySymbol} ${currency.format(repo.monthlyBudget)}',
                onTap: () => showEditBudgetDialog(context, repo),
              ),
              _SettingsRow(
                icon: Icons.schedule_outlined,
                label: 'Monthly start date',
                trailingText: '${repo.monthStartDay}',
                onTap: () => showMonthStartDayPicker(context, repo),
              ),
            ],
          ),
          _SettingsSection(
            title: 'General',
            rows: [
              _SettingsRow(
                icon: Icons.attach_money,
                label: 'Default currency',
                trailingText: selectedCurrency != null
                    ? '${selectedCurrency.code} ( ${selectedCurrency.symbol} )'
                    : repo.currencySymbol,
                trailingSubtitle: selectedCurrency?.country,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CurrencyPickerScreen(),
                  ),
                ),
              ),
              _SettingsRow(
                icon: Icons.grid_view_outlined,
                label: 'Category settings',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategorySettingsScreen(),
                  ),
                ),
              ),
            ],
          ),
          if (kDebugMode)
            _SettingsSection(
              title: 'Developer (debug builds only)',
              rows: [
                _SettingsRow(
                  icon: Icons.dataset_outlined,
                  label: 'Load sample data',
                  onTap: () => _runSampleAction(
                    context,
                    () => loadSampleData(repo.categories),
                    (count) => 'Added $count sample transactions',
                  ),
                ),
                _SettingsRow(
                  icon: Icons.delete_sweep_outlined,
                  label: 'Remove sample data',
                  onTap: () => _runSampleAction(
                    context,
                    removeSampleData,
                    (count) => 'Removed $count sample transactions',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

Future<void> _runSampleAction(
  BuildContext context,
  Future<int> Function() action,
  String Function(int count) message,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final count = await action();
    messenger.showSnackBar(SnackBar(content: Text(message(count))));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
  }
}

/// A titled card of rows, separated by dividers.
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> rows;

  const _SettingsSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: AppText.labelStrong.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Material(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (index, row) in rows.indexed) ...[
                  if (index > 0) const Divider(height: 1),
                  row,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final String? trailingSubtitle;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.trailingText,
    this.trailingSubtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            trailingSubtitle != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        trailingText!,
                        style: AppText.caption.copyWith(
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        trailingSubtitle!,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: onSurfaceVariant,
                          fontSize: 10,
                          height: 1.1,
                        ),
                      ),
                    ],
                  )
                : Text(
                    trailingText!,
                    style: AppText.label.copyWith(color: onSurfaceVariant),
                  ),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}
