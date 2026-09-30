import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/app_settings.dart';
import 'package:monthly_traq/app/home_layout.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/analytics/category_detail_screen.dart';
import 'package:monthly_traq/features/settings/edit_profile_screen.dart';
import 'package:monthly_traq/features/transactions/add_edit_transaction_screen.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/cycle_stats.dart';
import 'package:monthly_traq/services/daily_allowance.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/budget_sheet.dart';
import 'package:monthly_traq/widgets/transaction_rows.dart';
import 'package:monthly_traq/widgets/ui.dart';

/// Home: this cycle at a glance. Always shows the current cycle, whatever
/// month the Transactions and Analytics tabs are looking at.
class DashboardScreen extends StatelessWidget {
  final VoidCallback? onSeeAllTransactions;
  final VoidCallback? onSeeAllSpending;

  const DashboardScreen({
    super.key,
    this.onSeeAllTransactions,
    this.onSeeAllSpending,
  });

  static String greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _openTransaction(BuildContext context, TransactionModel t) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTransactionScreen(existing: t),
      ),
    );
  }

  /// The widget for one Home card, or null when it has nothing to show
  /// (no spending yet, or no budget for the daily allowance).
  Widget? _section(BuildContext context, HomeCard card) {
    final repo = context.watch<TransactionsRepository>();
    switch (card) {
      case HomeCard.balance:
        return const _BalanceCard();
      case HomeCard.budget:
        return const _BudgetCard();
      case HomeCard.dailyAllowance:
        final allowance = repo.dailyAllowance;
        return allowance == null
            ? null
            : _DailyAllowanceCard(allowance: allowance);
      case HomeCard.topSpending:
        final top = repo.topSpending;
        if (top.isEmpty) return null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              'Top spending',
              actionLabel: 'See all',
              onAction: onSeeAllSpending,
            ),
            const SizedBox(height: 10),
            _TopSpending(totals: top),
          ],
        );
      case HomeCard.recent:
        final recent = repo.transactions.take(5).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              'Recent',
              actionLabel: recent.isEmpty ? null : 'See all',
              onAction: onSeeAllTransactions,
            ),
            const SizedBox(height: 10),
            if (recent.isEmpty)
              EmptyState(
                icon: Icons.receipt_long,
                title: 'No transactions yet',
                message:
                    'Log what you spend and earn and it shows up here, '
                    'grouped by day.',
                actionLabel: 'Add your first transaction',
                onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditTransactionScreen(),
                  ),
                ),
              )
            else
              GroupCard(
                children: [
                  for (final t in recent)
                    TransactionRow(
                      transaction: t,
                      category: repo.categoryById(t.categoryId),
                      subtitle:
                          '${repo.categoryById(t.categoryId)?.name ?? 'Uncategorized'}'
                          ' · ${shortDate(t.date)}',
                      onTap: () => _openTransaction(context, t),
                    ),
                ],
              ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final money = context.money;

    final children = <Widget>[const _Greeting()];
    for (final card in settings.homeLayout.visible) {
      final section = _section(context, card);
      if (section == null) continue;
      final hasHeader = card == HomeCard.topSpending || card == HomeCard.recent;
      children
        ..add(
          SizedBox(height: children.length == 1 ? 20 : (hasHeader ? 24 : 16)),
        )
        ..add(section);
    }

    // Privacy mode swaps in a formatter that hides every amount, for Home
    // only — screens opened from here still show the real numbers.
    return Provider<MoneyFormatter>.value(
      value: settings.amountsHidden ? money.hidden : money,
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: children,
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

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
        final name = user?.displayName?.trim() ?? '';
        final firstName = name.isNotEmpty
            ? name.split(RegExp(r'\s+')).first
            : (user?.email ?? '').split('@').first;

        return Row(
          children: [
            Semantics(
              button: true,
              label: 'Edit profile',
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                ),
                child: ProfileAvatar(
                  photoBase64: photo,
                  initials: initialsFor(user?.displayName, user?.email),
                  size: 52,
                  filled: false,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DashboardScreen.greeting(DateTime.now()),
                    style: AppText.body.copyWith(color: c.muted),
                  ),
                  Text(
                    firstName,
                    style: AppText.section.copyWith(fontSize: 22),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final repo = context.watch<TransactionsRepository>();
    final money = context.money;
    final onPrimary = c.onPrimary;
    final settings = context.watch<AppSettings>();
    final hidden = settings.amountsHidden;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(AppRadius.sheet),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total balance',
                  style: AppText.body.copyWith(
                    color: onPrimary.withValues(alpha: 0.78),
                  ),
                ),
              ),
              if (settings.showPrivacyButton) ...[
                IconButton(
                  tooltip: hidden ? 'Show amounts' : 'Hide amounts',
                  onPressed: () => settings.setHideAmounts(!hidden),
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    hidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: onPrimary.withValues(alpha: 0.78),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: onPrimary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  repo.currentCycle.shortTitle,
                  style: AppText.caption.copyWith(
                    fontSize: 13,
                    color: onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              money.format(
                repo.balance,
                sign: repo.balance < 0 ? MoneySign.expense : MoneySign.none,
              ),
              style: AppText.balance.copyWith(fontSize: 42, color: onPrimary),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _Flow(
                  icon: Icons.south_west,
                  label: 'Income',
                  value: money.format(repo.monthlyIncome),
                  color: onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Flow(
                  icon: Icons.north_east,
                  label: 'Spent',
                  value: money.format(repo.monthlyExpense),
                  color: onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Flow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _Flow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppText.label.copyWith(
                  color: color.withValues(alpha: 0.78),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: AppText.statValue.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final repo = context.watch<TransactionsRepository>();
    final money = context.money;
    final budget = repo.monthlyBudget;
    final ratio = repo.budgetUsedRatio;
    final daysLeft = repo.daysLeftInCycle;

    final (fill, statusColor, status) = ratio >= 1
        ? (c.spendingFill, c.spending, 'Over budget')
        : ratio >= 0.7
        ? (c.warningFill, c.warning, '${(ratio * 100).round()}% used')
        : (c.accent, c.muted, '${(ratio * 100).round()}% used');

    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Monthly budget', style: AppText.section),
              ),
              TextButton(
                onPressed: () => showBudgetSheet(context),
                child: Text(budget > 0 ? 'Edit' : 'Set budget'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: budget <= 0
                ? Text(
                    'Set a budget to see how much is left this month.',
                    style: AppText.body.copyWith(color: c.muted),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: ratio >= 1
                                  ? '${money.format(-repo.budgetRemaining)} over'
                                  : money.format(repo.budgetRemaining),
                              style: AppText.amountLarge.copyWith(
                                color: ratio >= 1 ? c.spending : c.ink,
                              ),
                            ),
                            TextSpan(
                              text: ratio >= 1
                                  ? '  your ${money.format(budget)} budget'
                                  : '  left of ${money.format(budget)}',
                              style: AppText.label.copyWith(
                                fontSize: 15,
                                color: c.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Semantics(
                        label: 'Budget used',
                        value: '${(ratio * 100).round()} percent',
                        child: MeterBar(value: ratio, color: fill),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            status,
                            style: AppText.caption.copyWith(
                              fontSize: 13,
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            daysLeft <= 1
                                ? 'Last day of this cycle'
                                : '$daysLeft days left in cycle',
                            style: AppText.caption.copyWith(
                              fontSize: 13,
                              color: c.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _TopSpending extends StatelessWidget {
  final List<CategoryTotal> totals;

  const _TopSpending({required this.totals});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: i >= totals.length
                ? const SizedBox.shrink()
                : AppCard(
                    padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                    onTap: () {
                      context.read<TransactionsRepository>().showCurrentCycle();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryDetailScreen(
                            category: totals[i].category,
                            type: TransactionType.expense,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconTile(
                          icon: totals[i].category.icon,
                          color: totals[i].category.color,
                          size: 40,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          totals[i].category.name,
                          style: AppText.label.copyWith(color: c.muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            money.format(totals[i].amount),
                            style: AppText.statValue,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ],
    );
  }
}

/// "Rs. 1,000 left to spend today", with how much was spent today against
/// the day's allowance.
class _DailyAllowanceCard extends StatelessWidget {
  final DailyAllowance allowance;

  const _DailyAllowanceCard({required this.allowance});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final a = allowance;
    final ratio = a.perDay <= 0 ? 1.0 : (a.spentToday / a.perDay);

    final (headline, headlineColor, tail) = a.budgetUsedUp
        ? ('No budget left', c.spending, '')
        : a.isOverToday
        ? (
            '${money.format(-a.leftToday)} over',
            c.spending,
            '  today\'s ${money.format(a.perDay)}',
          )
        : (money.format(a.leftToday), c.ink, '  left to spend today');

    final footnote = a.budgetUsedUp
        ? 'You\'ve used this cycle\'s budget. Anything more goes over it.'
        : a.isOverToday
        ? 'Tomorrow\'s allowance will be a little lower to stay on budget.'
        : null;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Daily allowance', style: AppText.section),
              ),
              Text(
                a.daysLeft <= 1 ? 'Last day' : '${a.daysLeft} days left',
                style: AppText.caption.copyWith(fontSize: 13, color: c.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: headline,
                  style: AppText.amountLarge.copyWith(color: headlineColor),
                ),
                TextSpan(
                  text: tail,
                  style: AppText.label.copyWith(fontSize: 15, color: c.muted),
                ),
              ],
            ),
          ),
          if (!a.budgetUsedUp) ...[
            const SizedBox(height: 14),
            Semantics(
              label: 'Today\'s allowance used',
              value: '${(ratio * 100).round()} percent',
              child: MeterBar(
                value: ratio.clamp(0, 1),
                color: ratio >= 1
                    ? c.spendingFill
                    : ratio >= 0.7
                    ? c.warningFill
                    : c.accent,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Spent ${money.format(a.spentToday)} today',
                  style: AppText.caption.copyWith(fontSize: 13, color: c.muted),
                ),
                const Spacer(),
                Text(
                  '${money.format(a.perDay)} a day',
                  style: AppText.caption.copyWith(fontSize: 13, color: c.muted),
                ),
              ],
            ),
          ],
          if (footnote != null) ...[
            const SizedBox(height: 10),
            Text(
              footnote,
              style: AppText.caption.copyWith(fontSize: 13, color: c.muted),
            ),
          ],
        ],
      ),
    );
  }
}
