import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:monthly_traq/app/app_info.dart';
import 'package:monthly_traq/app/app_settings.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/app/theme_controller.dart';
import 'package:monthly_traq/dev/sample_data.dart';
import 'package:monthly_traq/features/money/money_screen.dart';
import 'package:monthly_traq/features/money/goals_screen.dart';
import 'package:monthly_traq/features/money/investments_screen.dart';
import 'package:monthly_traq/features/money/net_worth_screen.dart';
import 'package:monthly_traq/features/money/repayments_screen.dart';
import 'package:monthly_traq/features/settings/about_screen.dart';
import 'package:monthly_traq/features/settings/appearance_screen.dart';
import 'package:monthly_traq/features/settings/categories_screen.dart';
import 'package:monthly_traq/features/settings/currency_picker_screen.dart';
import 'package:monthly_traq/features/settings/delete_account.dart';
import 'package:monthly_traq/features/settings/edit_profile_screen.dart';
import 'package:monthly_traq/features/settings/home_layout_screen.dart';
import 'package:monthly_traq/features/settings/language_picker.dart';
import 'package:monthly_traq/l10n/l10n.dart';
import 'package:monthly_traq/features/settings/privacy_policy_screen.dart';
import 'package:monthly_traq/services/auth_service.dart';
import 'package:monthly_traq/services/budget_cycle.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/services/goals_repository.dart';
import 'package:monthly_traq/services/investments_repository.dart';
import 'package:monthly_traq/services/net_worth.dart';
import 'package:monthly_traq/services/repayments_repository.dart';
import 'package:monthly_traq/services/wallets_repository.dart';
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
    final l10n = context.l10n;
    if (!await _launch(AppInfo.supportEmailUri())) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.noEmailApp(AppInfo.supportEmail))),
      );
    }
  }

  /// Opens the Play Store listing, or the web page if there's no store.
  Future<void> _rateApp(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    if (await _launch(AppInfo.playStoreAppUri)) return;
    if (await _launch(AppInfo.playStoreWebUri)) return;
    messenger.showSnackBar(SnackBar(content: Text(l10n.playStoreFailed)));
  }

  Future<void> _showBackupInfo(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.automaticBackup),
        content: Text(context.l10n.automaticBackupBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.gotIt),
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
        .showSnackBar(SnackBar(content: Text(context.l10n.cacheCleared)));
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final repo = context.read<TransactionsRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final count = repo.transactions.length;
    final l10n = context.l10n;
    if (count == 0) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.noTransactionsToDelete)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAllDataTitle),
        content: Text(l10n.deleteAllDataBody(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: dialogContext.colors.spending,
            ),
            child: Text(l10n.deleteAll),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final deleted = await repo.deleteAllTransactions();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.deletedTransactions(deleted))),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.couldNotDelete(errorMessage(l10n, e)))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionsRepository>();
    final themeController = context.watch<ThemeController>();
    final settings = context.watch<AppSettings>();
    final wallets = context.watch<WalletsRepository>();
    final repayments = context.watch<RepaymentsRepository>();
    final goals = context.watch<GoalsRepository>();
    final investments = context.watch<InvestmentsRepository>();
    final netWorth = netWorthOf(
      watchNetWorthParts(context),
      watchNetWorthOff(context),
    );
    final money = context.money;
    final c = context.colors;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          Text(context.l10n.tabProfile, style: AppText.screenTitle),
          const SizedBox(height: 16),
          _ProfileCard(onTap: () => _push(context, const EditProfileScreen())),
          const SizedBox(height: 28),
          SettingsGroup(
            title: context.l10n.budgetSection,
            rows: [
              SettingsRow(
                icon: Icons.account_balance_wallet_outlined,
                label: context.l10n.monthlyBudget,
                value: repo.monthlyBudget > 0
                    ? money.format(repo.monthlyBudget)
                    : context.l10n.notSet,
                onTap: () => showBudgetSheet(context),
              ),
              SettingsRow(
                icon: Icons.event_repeat,
                label: context.l10n.monthStartsOn,
                value: ordinal(repo.monthStartDay),
                onTap: () => showMonthStartDayPicker(context),
              ),
            ],
          ),
          SettingsGroup(
            title: context.l10n.moneySection,
            rows: [
              SettingsRow(
                icon: Icons.account_balance_outlined,
                label: context.l10n.netWorth,
                value: money.format(
                  netWorth,
                  sign: netWorth < 0 ? MoneySign.expense : MoneySign.none,
                ),
                onTap: () => _push(context, const NetWorthScreen()),
              ),
              SettingsRow(
                icon: Icons.wallet_outlined,
                label: context.l10n.wallets,
                value: wallets.wallets.isEmpty
                    ? context.l10n.add
                    : context.l10n.walletCount(wallets.wallets.length),
                onTap: () => _push(context, const WalletsScreen()),
              ),
              SettingsRow(
                icon: Icons.event_repeat,
                label: context.l10n.repayments,
                value: repayments.repayments.isEmpty
                    ? context.l10n.add
                    : context.l10n.repaymentCount(repayments.repayments.length),
                onTap: () => _push(context, const RepaymentsScreen()),
              ),
              SettingsRow(
                icon: Icons.savings_outlined,
                label: context.l10n.savingsGoals,
                value: goals.goals.isEmpty
                    ? context.l10n.add
                    : context.l10n.goalCount(goals.goals.length),
                onTap: () => _push(context, const GoalsScreen()),
              ),
              SettingsRow(
                icon: Icons.trending_up,
                label: context.l10n.investments,
                value: investments.hasAccounts
                    ? money.format(investments.totals.value)
                    : context.l10n.add,
                onTap: () => _push(context, const InvestmentsScreen()),
              ),
            ],
          ),
          SettingsGroup(
            title: context.l10n.appearance,
            rows: [
              SettingsRow(
                icon: Icons.palette_outlined,
                label: context.l10n.theme,
                value:
                    '${themeController.theme.name} · ${themeController.modeLabel(context.l10n)}',
                onTap: () => _push(context, const AppearanceScreen()),
              ),
              SettingsRow(
                icon: Icons.format_size,
                label: context.l10n.textSize,
                value: themeController.fontSizeLabel(context.l10n),
                onTap: () => _push(context, const AppearanceScreen()),
              ),
              SettingsRow(
                icon: Icons.dashboard_customize_outlined,
                label: context.l10n.homeScreenLayout,
                value: settings.isDefaultHome
                    ? context.l10n.layoutDefault
                    : context.l10n.layoutCustom,
                onTap: () => _push(context, const HomeLayoutScreen()),
              ),
              if (_showUnfinished)
                SettingsRow.soon(icon: Icons.apps, label: context.l10n.appIcon),
            ],
          ),
          SettingsGroup(
            title: context.l10n.generalSection,
            rows: [
              SettingsRow(
                icon: Icons.payments_outlined,
                label: context.l10n.currency,
                value: repo.currencyCode != null
                    ? '${repo.currencyCode} · ${repo.currencySymbol}'
                    : repo.currencySymbol,
                onTap: () => _push(context, const CurrencyPickerScreen()),
              ),
              SettingsRow(
                icon: Icons.category_outlined,
                label: context.l10n.categories,
                value: '${repo.categories.length}',
                onTap: () => _push(context, const CategoriesScreen()),
              ),
              SettingsRow(
                icon: Icons.vibration,
                label: context.l10n.hapticFeedback,
                kind: SettingsRowKind.toggle,
                toggleValue: settings.hapticFeedback,
                onToggle: settings.setHapticFeedback,
              ),
              // Shown in released builds once there's a second language.
              if (_showUnfinished)
                SettingsRow(
                  icon: Icons.language,
                  label: context.l10n.languageTitle,
                  value: languageLabel(context, settings.languageCode),
                  onTap: () => showLanguagePicker(context),
                ),
            ],
          ),
          SettingsGroup(
            title: context.l10n.numbersSection,
            rows: [
              SettingsRow(
                icon: Icons.numbers,
                label: context.l10n.thousandsSeparator,
                kind: SettingsRowKind.toggle,
                toggleValue: settings.thousandsSeparator,
                onToggle: settings.setThousandsSeparator,
              ),
              if (_showUnfinished)
                SettingsRow.soon(
                  icon: Icons.calculate_outlined,
                  label: context.l10n.calculator,
                ),
            ],
          ),
          // These switches are remembered but don't do anything yet.
          if (_showUnfinished)
            SettingsGroup(
              title: context.l10n.notificationsSection,
              rows: [
                SettingsRow(
                  icon: Icons.notifications_outlined,
                  label: context.l10n.quickAddNotification,
                  kind: SettingsRowKind.toggle,
                  toggleValue: settings.quickAddNotification,
                  onToggle: settings.setQuickAddNotification,
                ),
                SettingsRow(
                  icon: Icons.volume_up_outlined,
                  label: context.l10n.soundEffects,
                  kind: SettingsRowKind.toggle,
                  toggleValue: settings.soundEffects,
                  onToggle: settings.setSoundEffects,
                ),
              ],
            ),
          if (_showUnfinished)
            SettingsGroup(
              title: context.l10n.advancedSection,
              rows: [
                SettingsRow.soon(
                  icon: Icons.auto_awesome_outlined,
                  label: context.l10n.aiSettings,
                ),
              ],
            ),
          SettingsGroup(
            title: context.l10n.moreSection,
            rows: [
              SettingsRow(
                icon: Icons.privacy_tip_outlined,
                label: context.l10n.privacyPolicy,
                onTap: () => _push(context, const PrivacyPolicyScreen()),
              ),
              SettingsRow(
                icon: Icons.mail_outline,
                label: context.l10n.contactSupport,
                onTap: () => _contactSupport(context),
              ),
              SettingsRow(
                icon: Icons.star_outline,
                label: context.l10n.rateApp(AppInfo.name),
                onTap: () => _rateApp(context),
              ),
              SettingsRow(
                icon: Icons.info_outline,
                label: context.l10n.about,
                onTap: () => _push(context, const AboutScreen()),
              ),
            ],
          ),
          SettingsGroup(
            title: context.l10n.dataSection,
            rows: [
              SettingsRow(
                icon: Icons.cloud_done_outlined,
                label: context.l10n.backup,
                value: context.l10n.backupAutomatic,
                onTap: () => _showBackupInfo(context),
              ),
              SettingsRow(
                icon: Icons.cleaning_services_outlined,
                label: context.l10n.clearCache,
                onTap: () => _clearCache(context),
              ),
              SettingsRow(
                icon: Icons.delete_forever_outlined,
                label: context.l10n.deleteAllData,
                kind: SettingsRowKind.destructive,
                onTap: () => _confirmDeleteAll(context),
              ),
              SettingsRow(
                icon: Icons.person_remove_outlined,
                label: context.l10n.deleteAccount,
                kind: SettingsRowKind.destructive,
                onTap: () => deleteAccountFlow(context),
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
                  context.l10n.logOut,
                  style: AppText.rowTitle.copyWith(
                    fontSize: 16,
                    color: c.spending,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
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
                      name == null || name.isEmpty
                          ? context.l10n.addYourName
                          : name,
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
