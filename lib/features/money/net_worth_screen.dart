import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/app_settings.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/money/goals_screen.dart';
import 'package:monthly_traq/features/money/investments_screen.dart';
import 'package:monthly_traq/features/money/money_screen.dart';
import 'package:monthly_traq/features/money/repayments_screen.dart';
import 'package:monthly_traq/services/goals_repository.dart';
import 'package:monthly_traq/services/investments_repository.dart';
import 'package:monthly_traq/services/net_worth.dart';
import 'package:monthly_traq/services/repayments_repository.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/services/wallets_repository.dart';
import 'package:monthly_traq/widgets/motion.dart';
import 'package:monthly_traq/widgets/ui.dart';

/// What each Net worth part adds up to right now. Call from `build`.
Map<NetWorthPart, double> watchNetWorthParts(BuildContext context) {
  final wallets = context.watch<WalletsRepository>();
  final goals = context.watch<GoalsRepository>();
  final investments = context.watch<InvestmentsRepository>();
  final repayments = context.watch<RepaymentsRepository>();
  final transactions = context.watch<TransactionsRepository>();
  var owed = 0.0;
  for (final r in repayments.repayments) {
    owed += repayments.progressOf(r).remaining;
  }
  return {
    NetWorthPart.wallets: wallets.ledger.own,
    NetWorthPart.goals: goalMoneyCounted(goals.goals, goals.entries),
    NetWorthPart.investments: investments.totals.value,
    NetWorthPart.balance: transactions.balance,
    NetWorthPart.repayments: owed,
  };
}

/// The parts the person has left out of Net worth.
Set<NetWorthPart> watchNetWorthOff(BuildContext context) {
  final off = context.select<AppSettings, Set<String>>((s) => s.netWorthOff);
  return {
    for (final p in NetWorthPart.values)
      if (off.contains(p.name)) p,
  };
}

/// Profile → Net worth: everything owned minus everything owed, with each
/// part shown and switchable.
class NetWorthScreen extends StatelessWidget {
  const NetWorthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final parts = watchNetWorthParts(context);
    final off = watchNetWorthOff(context);
    final total = netWorthOf(parts, off);

    Widget? screenFor(NetWorthPart part) => switch (part) {
      NetWorthPart.wallets => const WalletsScreen(),
      NetWorthPart.goals => const GoalsScreen(),
      NetWorthPart.investments => const InvestmentsScreen(),
      NetWorthPart.repayments => const RepaymentsScreen(),
      NetWorthPart.balance => null,
    };

    return SubPageScaffold(
      title: 'Net worth',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What you own, minus what you owe',
                  style: AppText.body.copyWith(color: c.muted),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    money.format(
                      total,
                      sign: total < 0 ? MoneySign.expense : MoneySign.none,
                    ),
                    style: AppText.amountLarge.copyWith(fontSize: 32),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader('Made up of'),
          const SizedBox(height: 8),
          GroupCard(
            children: [
              for (final part in NetWorthPart.values)
                _PartRow(
                  part: part,
                  amount: parts[part] ?? 0,
                  counted: !off.contains(part),
                  onOpen: switch (screenFor(part)) {
                    final screen? => () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => screen),
                    ),
                    null => null,
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Switch a part off to leave it out. Total balance starts off: '
            'if your income lands in your wallets, it would count the same '
            'money twice. Others\' money in your wallets is never counted — '
            'it isn\'t yours.',
            style: AppText.label.copyWith(color: c.muted),
          ),
        ],
      ),
    );
  }
}

class _PartRow extends StatelessWidget {
  final NetWorthPart part;
  final double amount;
  final bool counted;
  final VoidCallback? onOpen;

  const _PartRow({
    required this.part,
    required this.amount,
    required this.counted,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final shown = part.isOwed ? -amount : amount;
    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    part.label,
                    style: AppText.rowTitle.copyWith(
                      fontSize: 16,
                      color: counted ? c.ink : c.muted,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    part.detail,
                    style: AppText.label.copyWith(color: c.muted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    money.format(
                      shown,
                      sign: shown < 0 ? MoneySign.expense : MoneySign.none,
                    ),
                    style: AppText.amount.copyWith(
                      fontSize: 16,
                      color: counted ? c.ink : c.muted,
                      decoration: counted ? null : TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: counted,
              onChanged: (value) =>
                  context.read<AppSettings>().setNetWorthPart(part.name, value),
            ),
          ],
        ),
      ),
    );
  }
}

/// Net worth on Home. Tap for the breakdown.
class NetWorthHomeCard extends StatelessWidget {
  const NetWorthHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final total = netWorthOf(
      watchNetWorthParts(context),
      watchNetWorthOff(context),
    );
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NetWorthScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Net worth', style: AppText.section)),
              Icon(Icons.chevron_right, color: c.faint),
            ],
          ),
          const SizedBox(height: 8),
          CountUp(
            value: total,
            builder: (context, shown) => Text(
              money.format(
                shown,
                sign: shown < 0 ? MoneySign.expense : MoneySign.none,
              ),
              style: AppText.amountLarge,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'What you own, minus what you owe',
            style: AppText.caption.copyWith(fontSize: 13, color: c.muted),
          ),
        ],
      ),
    );
  }
}
