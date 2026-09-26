import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/currencies.dart';
import 'package:monthly_traq/app/palette.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/dev/sample_data.dart';
import 'package:monthly_traq/features/settings/category_settings_screen.dart';
import 'package:monthly_traq/features/settings/currency_picker_screen.dart';
import 'package:monthly_traq/features/settings/my_profile_screen.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/edit_budget_dialog.dart';
import 'package:monthly_traq/widgets/month_start_day_picker.dart';

/// Settings grouped by what they affect. Rows without an onTap (or with an
/// unsaved toggle) are placeholders for features not built yet. Look-and-feel
/// settings (theme, mode, font size) live on the Appearance screen instead.
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _notificationShortcut = true;
  bool _soundEffect = true;
  bool _thousandsSeparator = true;

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
              const _SettingsRow(
                icon: Icons.lock_outline,
                label: 'Password',
                showVipBadge: true,
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
              const _SettingsRow(
                icon: Icons.menu_book_outlined,
                label: 'My Cash Books',
              ),
              const _SettingsRow(
                icon: Icons.account_balance_outlined,
                label: 'Accounts',
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
              const _SettingsRow(
                icon: Icons.dashboard_customize_outlined,
                label: 'Home page settings',
              ),
              const _SettingsRow(
                icon: Icons.language_outlined,
                label: 'Language',
              ),
              const _SettingsRow(icon: Icons.apps_outlined, label: 'Icon'),
            ],
          ),
          _SettingsSection(
            title: 'Numbers & tools',
            rows: [
              _SettingsRow(
                icon: Icons.numbers,
                label: 'Thousands separator',
                toggleValue: _thousandsSeparator,
                onToggleChanged: (value) =>
                    setState(() => _thousandsSeparator = value),
              ),
              const _SettingsRow(
                icon: Icons.format_list_numbered_outlined,
                label: 'Number display format',
              ),
              const _SettingsRow(
                icon: Icons.calculate_outlined,
                label: 'Calculator',
              ),
              const _SettingsRow(
                icon: Icons.calendar_month_outlined,
                label: 'Calendar',
              ),
            ],
          ),
          _SettingsSection(
            title: 'Notifications & sound',
            rows: [
              _SettingsRow(
                icon: Icons.notifications_active_outlined,
                label: 'Notification Shortcut',
                toggleValue: _notificationShortcut,
                onToggleChanged: (value) =>
                    setState(() => _notificationShortcut = value),
              ),
              _SettingsRow(
                icon: Icons.music_note_outlined,
                label: 'Sound Effect',
                toggleValue: _soundEffect,
                onToggleChanged: (value) =>
                    setState(() => _soundEffect = value),
              ),
            ],
          ),
          const _SettingsSection(
            title: 'Data',
            rows: [
              _SettingsRow(
                icon: Icons.upload_file_outlined,
                label: 'Export Data',
              ),
              _SettingsRow(
                icon: Icons.file_upload_outlined,
                label: 'Import Transactions',
                showVipBadge: true,
              ),
              _SettingsRow(
                icon: Icons.cloud_outlined,
                label: 'Automatically backed up data',
              ),
              _SettingsRow(
                icon: Icons.cleaning_services_outlined,
                label: 'Clear cache',
              ),
              _SettingsRow(
                icon: Icons.delete_outline,
                label: 'Delete all data',
              ),
            ],
          ),
          const _SettingsSection(
            title: 'Advanced',
            rows: [
              _SettingsRow(
                icon: Icons.auto_awesome_outlined,
                label: 'AI Settings',
              ),
              _SettingsRow(
                icon: Icons.api_outlined,
                label: 'API (Developer Tools)',
                showVipBadge: true,
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
  final bool showVipBadge;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.trailingText,
    this.trailingSubtitle,
    this.showVipBadge = false,
    this.toggleValue,
    this.onToggleChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    if (toggleValue != null) {
      return SwitchListTile(
        secondary: Icon(icon),
        title: Text(label),
        value: toggleValue!,
        onChanged: onToggleChanged,
      );
    }

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
          if (showVipBadge) ...[const _VipBadge(), const SizedBox(width: 4)],
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap ?? () {},
    );
  }
}

class _VipBadge extends StatelessWidget {
  const _VipBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppPalette.warning.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'VIP',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
          // The plain warning amber is too faint as text on light themes.
          color: AppPalette.warningText(Theme.of(context).brightness),
        ),
      ),
    );
  }
}
