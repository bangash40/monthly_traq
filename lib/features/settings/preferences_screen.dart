import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/currencies.dart';
import 'package:monthly_traq/app/palette.dart';
import 'package:monthly_traq/features/settings/category_settings_screen.dart';
import 'package:monthly_traq/features/settings/currency_picker_screen.dart';
import 'package:monthly_traq/features/settings/font_size_screen.dart';
import 'package:monthly_traq/features/settings/my_profile_screen.dart';
import 'package:monthly_traq/features/settings/themes_screen.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/edit_budget_dialog.dart';
import 'package:monthly_traq/widgets/month_start_day_picker.dart';

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
    final cardColor = Theme.of(context).cardColor;
    final selectedCurrency = kCurrencyOptions
        .cast<CurrencyOption?>()
        .firstWhere((c) => c?.code == repo.currencyCode, orElse: () => null);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          Material(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
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
                const Divider(height: 1),
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
                const Divider(height: 1),
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
                const Divider(height: 1),
                _SettingsRow(
                  icon: Icons.schedule_outlined,
                  label: 'Monthly Start Date',
                  trailingText: '${repo.monthStartDay}',
                  onTap: () => showMonthStartDayPicker(context, repo),
                ),
                const Divider(height: 1),
                _SettingsRow(
                  icon: Icons.palette_outlined,
                  label: 'Themes',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ThemesScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                _SettingsRow(
                  icon: Icons.format_size,
                  label: 'Font Size',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FontSizeScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                const _SettingsRow(
                  icon: Icons.dashboard_customize_outlined,
                  label: 'Home page settings',
                ),
                const Divider(height: 1),
                const _SettingsRow(
                  icon: Icons.menu_book_outlined,
                  label: 'My Cash Books',
                ),
                const Divider(height: 1),
                const _SettingsRow(
                  icon: Icons.account_balance_outlined,
                  label: 'Accounts',
                ),
                const Divider(height: 1),
                _SettingsRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Budget',
                  trailingText:
                      '${repo.currencySymbol} ${currency.format(repo.monthlyBudget)}',
                  onTap: () => showEditBudgetDialog(context, repo),
                ),
                const Divider(height: 1),
                const _SettingsRow(
                  icon: Icons.upload_file_outlined,
                  label: 'Export Data',
                ),
                const Divider(height: 1),
                const _SettingsRow(
                  icon: Icons.file_upload_outlined,
                  label: 'Import Transactions',
                  showVipBadge: true,
                ),
                const Divider(height: 1),
                const _SettingsRow(
                  icon: Icons.lock_outline,
                  label: 'Password',
                  showVipBadge: true,
                ),
                const Divider(height: 1),
                _SettingsRow(
                  icon: Icons.notifications_active_outlined,
                  label: 'Notification Shortcut',
                  toggleValue: _notificationShortcut,
                  onToggleChanged: (value) =>
                      setState(() => _notificationShortcut = value),
                ),
                const Divider(height: 1),
                _SettingsRow(
                  icon: Icons.music_note_outlined,
                  label: 'Sound Effect',
                  toggleValue: _soundEffect,
                  onToggleChanged: (value) =>
                      setState(() => _soundEffect = value),
                ),
                const Divider(height: 1),
                _SettingsRow(
                  icon: Icons.numbers,
                  label: 'Thousands separator',
                  toggleValue: _thousandsSeparator,
                  onToggleChanged: (value) =>
                      setState(() => _thousandsSeparator = value),
                ),
                const Divider(height: 1),
                const _SettingsRow(
                  icon: Icons.format_list_numbered_outlined,
                  label: 'Number display format',
                ),
                const Divider(height: 1),
                const _SettingsRow(
                  icon: Icons.calculate_outlined,
                  label: 'Calculator',
                ),
                const Divider(height: 1),
                const _SettingsRow(
                  icon: Icons.calendar_month_outlined,
                  label: 'Calendar',
                ),
                const Divider(height: 1),
                const _SettingsRow(icon: Icons.apps_outlined, label: 'Icon'),
                const Divider(height: 1),
                const _SettingsRow(
                  icon: Icons.auto_awesome_outlined,
                  label: 'AI Settings',
                ),
                const Divider(height: 1),
                const _SettingsRow(
                  icon: Icons.delete_outline,
                  label: 'Delete all data',
                ),
                const Divider(height: 1),
                const _SettingsRow(
                  icon: Icons.cloud_outlined,
                  label: 'Automatically backed up data',
                ),
                const Divider(height: 1),
                const _SettingsRow(
                  icon: Icons.language_outlined,
                  label: 'Language',
                ),
                const Divider(height: 1),
                const _SettingsRow(
                  icon: Icons.api_outlined,
                  label: 'API (Developer Tools)',
                  showVipBadge: true,
                ),
                const Divider(height: 1),
                const _SettingsRow(
                  icon: Icons.cleaning_services_outlined,
                  label: 'Clear cache',
                ),
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

    return SizedBox(
      height: 56,
      child: ListTile(
        dense: true,
        leading: Icon(icon),
        title: Text(label),
        trailing: toggleValue != null
            ? Switch(value: toggleValue!, onChanged: onToggleChanged ?? (_) {})
            : Row(
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
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
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
                            style: TextStyle(
                              color: onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                    const SizedBox(width: 8),
                  ],
                  if (showVipBadge) ...[
                    const _VipBadge(),
                    const SizedBox(width: 4),
                  ],
                  const Icon(Icons.chevron_right),
                ],
              ),
        onTap: toggleValue != null ? null : (onTap ?? () {}),
      ),
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
      child: const Text(
        'VIP',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppPalette.warning,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
