import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:monthly_traq/app/app_info.dart';
import 'package:monthly_traq/app/app_settings.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/app/theme_controller.dart';
import 'package:monthly_traq/dev/sample_data.dart';
import 'package:monthly_traq/features/settings/appearance_screen.dart';
import 'package:monthly_traq/features/settings/categories_screen.dart';
import 'package:monthly_traq/features/settings/currency_picker_screen.dart';
import 'package:monthly_traq/features/settings/delete_account.dart';
import 'package:monthly_traq/features/settings/edit_profile_screen.dart';
import 'package:monthly_traq/features/settings/privacy_policy_screen.dart';
import 'package:monthly_traq/services/auth_service.dart';
import 'package:monthly_traq/services/budget_cycle.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/budget_sheet.dart';
import 'package:monthly_traq/widgets/month_start_day_picker.dart';
import 'package:monthly_traq/widgets/settings_rows.dart';
import 'package:monthly_traq/widgets/ui.dart';

/// The Profile tab: your account, and every setting grouped by what it
/// affects. Rows marked "Soon" are features that aren't built yet.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Rows for features that aren't built yet ("Soon", PRO, and switches
  /// that don't do anything) only show in debug builds, so the released
  /// app has nothing that looks unfinished.
  static const _showUnfinished = kDebugMode;

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Future<bool> _launch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  Future<void> _contactSupport(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!await _launch(AppInfo.supportEmailUri())) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No email app found. Write to ${AppInfo.supportEmail}'),
        ),
      );
    }
  }

  /// Opens the Play Store listing, or the web page if there's no store.
  Future<void> _rateApp(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    if (await _launch(AppInfo.playStoreAppUri)) return;
    if (await _launch(AppInfo.playStoreWebUri)) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Couldn\'t open the Play Store')),
    );
  }

  Future<void> _showLicenses(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    if (!context.mounted) return;
    showLicensePage(
      context: context,
      applicationName: AppInfo.name,
      applicationVersion: info.version,
      applicationIcon: const Padding(
        padding: EdgeInsets.all(12),
        child: AppLogoTile(),
      ),
    );
  }

  void _showPro(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is part of MonthlyTraq Pro, coming soon.'),
      ),
    );
  }

  Future<void> _showBackupInfo(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Automatic backup'),
        content: const Text(
          'Everything you log is saved to your MonthlyTraq account as you '
          'go, so it\'s there on any device you sign in on. Changes made '
          'offline upload once you\'re back online.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _clearCache(BuildContext context) {
    final cache = PaintingBinding.instance.imageCache;
    cache.clear();
    cache.clearLiveImages();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Cache cleared')));
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final repo = context.read<TransactionsRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final count = repo.transactions.length;
    if (count == 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('There are no transactions to delete')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete all data?'),
        content: Text(
          'This permanently deletes all $count transactions on your account. '
          'Your categories and settings are kept. This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: dialogContext.colors.spending,
            ),
            child: const Text('Delete all'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final deleted = await repo.deleteAllTransactions();
      messenger.showSnackBar(
        SnackBar(content: Text('Deleted $deleted transactions')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not delete: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionsRepository>();
    final themeController = context.watch<ThemeController>();
    final settings = context.watch<AppSettings>();
    final money = context.money;
    final c = context.colors;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          const Text('Profile', style: AppText.screenTitle),
          const SizedBox(height: 16),
          _ProfileCard(onTap: () => _push(context, const EditProfileScreen())),
          const SizedBox(height: 28),
          SettingsGroup(
            title: 'Budget',
            rows: [
              SettingsRow(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Monthly budget',
                value: repo.monthlyBudget > 0
                    ? money.format(repo.monthlyBudget)
                    : 'Not set',
                onTap: () => showBudgetSheet(context),
              ),
              SettingsRow(
                icon: Icons.event_repeat,
                label: 'Month starts on',
                value: ordinal(repo.monthStartDay),
                onTap: () => showMonthStartDayPicker(context),
              ),
              if (_showUnfinished) ...const [
                SettingsRow.soon(
                  icon: Icons.menu_book_outlined,
                  label: 'Cash books',
                ),
                SettingsRow.soon(
                  icon: Icons.account_balance_outlined,
                  label: 'Accounts',
                ),
              ],
            ],
          ),
          SettingsGroup(
            title: 'Appearance',
            rows: [
              SettingsRow(
                icon: Icons.palette_outlined,
                label: 'Theme',
                value:
                    '${themeController.theme.name} · ${themeController.modeLabel}',
                onTap: () => _push(context, const AppearanceScreen()),
              ),
              SettingsRow(
                icon: Icons.format_size,
                label: 'Text size',
                value: themeController.fontSizeLabel,
                onTap: () => _push(context, const AppearanceScreen()),
              ),
              if (_showUnfinished) ...const [
                SettingsRow.soon(
                  icon: Icons.home_outlined,
                  label: 'Home screen layout',
                ),
                SettingsRow.soon(icon: Icons.apps, label: 'App icon'),
              ],
            ],
          ),
          SettingsGroup(
            title: 'General',
            rows: [
              SettingsRow(
                icon: Icons.payments_outlined,
                label: 'Currency',
                value: repo.currencyCode != null
                    ? '${repo.currencyCode} · ${repo.currencySymbol}'
                    : repo.currencySymbol,
                onTap: () => _push(context, const CurrencyPickerScreen()),
              ),
              SettingsRow(
                icon: Icons.category_outlined,
                label: 'Categories',
                value: '${repo.categories.length}',
                onTap: () => _push(context, const CategoriesScreen()),
              ),
              if (_showUnfinished)
                const SettingsRow.soon(icon: Icons.language, label: 'Language'),
            ],
          ),
          SettingsGroup(
            title: 'Numbers & tools',
            rows: [
              SettingsRow(
                icon: Icons.numbers,
                label: 'Thousands separator',
                kind: SettingsRowKind.toggle,
                toggleValue: settings.thousandsSeparator,
                onToggle: settings.setThousandsSeparator,
              ),
              if (_showUnfinished) ...const [
                SettingsRow.soon(
                  icon: Icons.format_list_numbered,
                  label: 'Number format',
                ),
                SettingsRow.soon(
                  icon: Icons.calculate_outlined,
                  label: 'Calculator',
                ),
                SettingsRow.soon(
                  icon: Icons.calendar_month_outlined,
                  label: 'Calendar',
                ),
              ],
            ],
          ),
          // These switches are remembered but don't do anything yet.
          if (_showUnfinished)
            SettingsGroup(
              title: 'Notifications & sound',
              rows: [
                SettingsRow(
                  icon: Icons.notifications_outlined,
                  label: 'Quick-add notification',
                  kind: SettingsRowKind.toggle,
                  toggleValue: settings.quickAddNotification,
                  onToggle: settings.setQuickAddNotification,
                ),
                SettingsRow(
                  icon: Icons.volume_up_outlined,
                  label: 'Sound effects',
                  kind: SettingsRowKind.toggle,
                  toggleValue: settings.soundEffects,
                  onToggle: settings.setSoundEffects,
                ),
              ],
            ),
          SettingsGroup(
            title: 'Data',
            rows: [
              if (_showUnfinished) ...[
                const SettingsRow.soon(
                  icon: Icons.download_outlined,
                  label: 'Export data',
                ),
                SettingsRow(
                  icon: Icons.upload_outlined,
                  label: 'Import transactions',
                  kind: SettingsRowKind.pro,
                  onTap: () => _showPro(context, 'Importing transactions'),
                ),
              ],
              SettingsRow(
                icon: Icons.cloud_done_outlined,
                label: 'Backup',
                value: 'Automatic',
                onTap: () => _showBackupInfo(context),
              ),
              SettingsRow(
                icon: Icons.cleaning_services_outlined,
                label: 'Clear cache',
                onTap: () => _clearCache(context),
              ),
              SettingsRow(
                icon: Icons.delete_forever_outlined,
                label: 'Delete all data',
                kind: SettingsRowKind.destructive,
                onTap: () => _confirmDeleteAll(context),
              ),
              SettingsRow(
                icon: Icons.person_remove_outlined,
                label: 'Delete account',
                kind: SettingsRowKind.destructive,
                onTap: () => deleteAccountFlow(context),
              ),
            ],
          ),
          if (_showUnfinished)
            SettingsGroup(
              title: 'Advanced',
              rows: [
                const SettingsRow.soon(
                  icon: Icons.auto_awesome_outlined,
                  label: 'AI settings',
                ),
                SettingsRow(
                  icon: Icons.api,
                  label: 'API access',
                  kind: SettingsRowKind.pro,
                  onTap: () => _showPro(context, 'API access'),
                ),
                SettingsRow(
                  icon: Icons.lock_outline,
                  label: 'Password',
                  kind: SettingsRowKind.pro,
                  onTap: () => _showPro(context, 'App password'),
                ),
              ],
            ),
          SettingsGroup(
            title: 'About',
            rows: [
              SettingsRow(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy policy',
                onTap: () => _push(context, const PrivacyPolicyScreen()),
              ),
              SettingsRow(
                icon: Icons.mail_outline,
                label: 'Contact support',
                onTap: () => _contactSupport(context),
              ),
              SettingsRow(
                icon: Icons.star_outline,
                label: 'Rate ${AppInfo.name}',
                onTap: () => _rateApp(context),
              ),
              SettingsRow(
                icon: Icons.description_outlined,
                label: 'Open-source licenses',
                onTap: () => _showLicenses(context),
              ),
            ],
          ),
          if (kDebugMode)
            SettingsGroup(
              title: 'Developer (debug builds only)',
              rows: [
                SettingsRow(
                  icon: Icons.dataset_outlined,
                  label: 'Load sample data',
                  onTap: () => _runSampleAction(
                    context,
                    () => loadSampleData(repo.categories),
                    (count) => 'Added $count sample transactions',
                  ),
                ),
                SettingsRow(
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
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 16),
            onTap: () => AuthService().signOut(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: c.spending, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Log out',
                  style: AppText.rowTitle.copyWith(
                    fontSize: 16,
                    color: c.spending,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _VersionLabel(),
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

class _ProfileCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ProfileCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final photo = context.select<TransactionsRepository, String?>(
      (r) => r.photoBase64,
    );

    return StreamBuilder<User?>(
      // userChanges() so a name edit shows up here right away.
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final name = user?.displayName?.trim();
        final email = user?.email ?? '';

        return AppCard(
          onTap: onTap,
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          child: Row(
            children: [
              ProfileAvatar(
                photoBase64: photo,
                initials: initialsFor(name, email),
                size: 60,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name == null || name.isEmpty ? 'Add your name' : name,
                      style: AppText.section.copyWith(fontSize: 19),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        style: AppText.body.copyWith(color: c.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: c.faint),
            ],
          ),
        );
      },
    );
  }
}

/// "MonthlyTraq 1.2.0", read from the installed build itself so it always
/// matches what's on the device.
class _VersionLabel extends StatelessWidget {
  const _VersionLabel();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        return Text(
          info == null ? '' : 'MonthlyTraq ${info.version}',
          textAlign: TextAlign.center,
          style: AppText.caption.copyWith(color: context.colors.muted),
        );
      },
    );
  }
}
