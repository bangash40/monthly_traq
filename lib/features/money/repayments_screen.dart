import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/money/repayment_sheets.dart';
import 'package:monthly_traq/models/repayment_models.dart';
import 'package:monthly_traq/services/repayment_schedule.dart';
import 'package:monthly_traq/services/repayments_repository.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/services/wallets_repository.dart';
import 'package:monthly_traq/widgets/motion.dart';
import 'package:monthly_traq/widgets/ui.dart';

void _open(BuildContext context, Widget screen) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));

String _schedule(RepaymentModel r, MoneyFormatter money) {
  final each = r.installment == null ? '' : money.format(r.installment!);
  return switch (r.frequency) {
    RepaymentFrequency.daily => '$each daily',
    RepaymentFrequency.monthly => '$each monthly',
    RepaymentFrequency.everyMonths => '$each every ${r.everyMonths} months',
    RepaymentFrequency.yearly => '$each yearly',
    RepaymentFrequency.none => 'No deadline',
  };
}

/// Active repayments, most urgent first: the ones with a due date by date,
/// then the ones without.
List<RepaymentModel> activeByDue(RepaymentsRepository repo) {
  final active = [
    for (final r in repo.repayments)
      if (!repo.progressOf(r).isPaidOff) r,
  ];
  return active..sort((a, b) {
    final ad = a.hasSchedule ? a.nextDue : null;
    final bd = b.hasSchedule ? b.nextDue : null;
    if (ad != null && bd != null) return ad.compareTo(bd);
    if (ad != null) return -1;
    if (bd != null) return 1;
    return 0;
  });
}

/// "Due in 3 days" as a pill: red when overdue, amber within 3 days.
class DueBadge extends StatelessWidget {
  final RepaymentProgress progress;

  const DueBadge({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    if (progress.isPaidOff) {
      return const TagBadge('Paid off', tone: BadgeTone.income);
    }
    final days = progress.daysUntilDue(DateTime.now());
    if (days == null) return const TagBadge('No deadline');
    return TagBadge(
      dueLabel(days),
      tone: days < 0
          ? BadgeTone.spending
          : days <= 3
          ? BadgeTone.warning
          : BadgeTone.neutral,
    );
  }
}

/// Profile → Repayments: everything the person owes and pays back over
/// time, what's due next, and what's paid off.
class RepaymentsScreen extends StatelessWidget {
  const RepaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final repo = context.watch<RepaymentsRepository>();
    final active = activeByDue(repo);
    final paidOff = [
      for (final r in repo.repayments)
        if (repo.progressOf(r).isPaidOff) r,
    ];
    final now = DateTime.now();
    var owed = 0.0;
    var dueThisMonth = 0.0;
    for (final r in active) {
      final p = repo.progressOf(r);
      owed += p.remaining;
      dueThisMonth += p.dueThisMonth(now);
    }

    return SubPageScaffold(
      title: 'Repayments',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          if (!repo.hasRepayments)
            EmptyState(
              icon: Icons.event_repeat,
              title: 'Track what you owe',
              message:
                  'Add installments, loans and qisht to see what\'s due next, '
                  'how much is left, and when you\'ll be done.',
              actionLabel: 'Add a repayment',
              onAction: () => showRepaymentEditor(context),
            )
          else ...[
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Still owed',
                    style: AppText.body.copyWith(color: c.muted),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      money.format(owed),
                      style: AppText.amountLarge.copyWith(fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _Stat(
                          label: 'Due this month',
                          value: money.format(dueThisMonth),
                        ),
                      ),
                      Expanded(
                        child: _Stat(
                          label: 'Active',
                          value: '${active.length}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(
              'Active',
              actionLabel: 'Add',
              onAction: () => showRepaymentEditor(context),
            ),
            const SizedBox(height: 8),
            if (active.isEmpty)
              Text(
                'Everything is paid off.',
                style: AppText.body.copyWith(color: c.muted),
              )
            else
              GroupCard(
                children: [for (final r in active) RepaymentRow(repayment: r)],
              ),
            if (paidOff.isNotEmpty) ...[
              const SizedBox(height: 24),
              const SectionHeader('Paid off'),
              const SizedBox(height: 8),
              GroupCard(
                children: [for (final r in paidOff) RepaymentRow(repayment: r)],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label.copyWith(color: c.muted)),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: AppText.statValue),
        ),
      ],
    );
  }
}

/// One repayment: name, due status, schedule, progress and what's left.
class RepaymentRow extends StatelessWidget {
  final RepaymentModel repayment;

  const RepaymentRow({super.key, required this.repayment});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final repo = context.watch<RepaymentsRepository>();
    final p = repo.progressOf(repayment);
    final count = p.installmentCount;
    final detail = [
      _schedule(repayment, money),
      if (count != null && count > 0)
        '${p.installmentsPaid} of $count paid'
      else
        '${money.format(p.paid)} of ${money.format(repayment.total)} paid',
    ].join(' · ');

    return InkWell(
      onTap: () => _open(context, RepaymentScreen(repaymentId: repayment.id)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          repayment.name,
                          style: AppText.rowTitle.copyWith(
                            fontSize: 16,
                            color: p.isPaidOff ? c.muted : c.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      DueBadge(progress: p),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: AppText.label.copyWith(color: c.muted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  MeterBar(value: p.fraction, color: c.accent, height: 6),
                  const SizedBox(height: 6),
                  Text(
                    p.isPaidOff
                        ? '${money.format(repayment.total)} paid'
                        : '${money.format(p.remaining)} left',
                    style: AppText.label.copyWith(
                      color: c.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(Icons.chevron_right, color: c.faint),
            ),
          ],
        ),
      ),
    );
  }
}

/// One repayment: what's left, the schedule, Pay, and every payment.
class RepaymentScreen extends StatelessWidget {
  final String repaymentId;

  const RepaymentScreen({super.key, required this.repaymentId});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final repo = context.watch<RepaymentsRepository>();
    final r = repo.repaymentById(repaymentId);
    if (r == null) {
      // Deleted (here or elsewhere): close this screen.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.maybePop(context);
      });
      return const Scaffold();
    }
    final p = repo.progressOf(r);
    final payments = repo.paymentsFor(r.id).reversed.toList();
    final finish = p.finishDate;
    final left = p.installmentsLeft;

    Widget info(String label, Widget value) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppText.body.copyWith(color: c.muted)),
          ),
          value,
        ],
      ),
    );
    Text infoText(String text) => Text(text, style: AppText.rowTitle);

    return SubPageScaffold(
      title: r.name,
      trailing: IconButton(
        tooltip: 'Edit repayment',
        onPressed: () => showRepaymentEditor(context, existing: r),
        icon: Icon(Icons.edit_outlined, color: c.ink),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.isPaidOff ? 'Paid off' : 'Left to pay',
                  style: AppText.body.copyWith(color: c.muted),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    money.format(p.isPaidOff ? r.total : p.remaining),
                    style: AppText.amountLarge.copyWith(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 14),
                MeterBar(value: p.fraction, color: c.accent),
                const SizedBox(height: 10),
                Text(
                  '${money.format(p.paid)} of ${money.format(r.total)} paid'
                  '${r.lender == null ? '' : ' · to ${r.lender}'}',
                  style: AppText.label.copyWith(color: c.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GroupCard(
            children: [
              info(
                'Next due',
                r.hasSchedule && !p.isPaidOff
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          infoText(DateFormat('d MMM y').format(r.nextDue!)),
                          const SizedBox(width: 8),
                          DueBadge(progress: p),
                        ],
                      )
                    : DueBadge(progress: p),
              ),
              info('Payments', infoText(_schedule(r, money))),
              if (left != null && !p.isPaidOff)
                info('Payments left', infoText('$left')),
              if (finish != null)
                info('Done by', infoText(DateFormat('MMM y').format(finish))),
            ],
          ),
          if (!p.isPaidOff) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => showPaySheet(context, r),
              icon: const Icon(Icons.check),
              label: const Text('Pay'),
            ),
          ],
          const SizedBox(height: 24),
          const SectionHeader('Payments'),
          const SizedBox(height: 8),
          if (payments.isEmpty && r.paidBefore <= 0)
            Text(
              'Payments you make show up here.',
              style: AppText.body.copyWith(color: c.muted),
            )
          else
            GroupCard(
              children: [
                for (final payment in payments) _PaymentRow(payment: payment),
                if (r.paidBefore > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        IconTile(icon: Icons.history, color: c.muted, size: 44),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Paid before tracking',
                            style: AppText.rowTitle.copyWith(fontSize: 16),
                          ),
                        ),
                        Text(
                          money.format(r.paidBefore),
                          style: AppText.amount.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final RepaymentPayment payment;

  const _PaymentRow({required this.payment});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final txRepo = context.watch<TransactionsRepository>();
    final wallets = context.watch<WalletsRepository>();
    final p = payment;
    final from = switch (p.source) {
      PaymentSource.budget => () {
        final tx = txRepo.transactions
            .where((t) => t.id == p.transactionId)
            .firstOrNull;
        final category = txRepo.categoryById(tx?.categoryId);
        return category == null
            ? 'Monthly money'
            : 'Monthly money · ${category.name}';
      }(),
      PaymentSource.wallet => () {
        final entry = wallets.entries
            .where((e) => e.id == p.walletEntryId)
            .firstOrNull;
        return 'From ${wallets.walletById(entry?.walletId)?.name ?? 'a wallet'}';
      }(),
      PaymentSource.none => 'Recorded only',
    };

    return InkWell(
      onTap: () => confirmDeletePayment(context, p),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconTile(
              icon: switch (p.source) {
                PaymentSource.budget => Icons.receipt_long_outlined,
                PaymentSource.wallet => Icons.account_balance_wallet_outlined,
                PaymentSource.none => Icons.check,
              },
              color: c.muted,
              size: 44,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat(
                      p.date.year == DateTime.now().year ? 'd MMM' : 'd MMM y',
                    ).format(p.date),
                    style: AppText.rowTitle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    from,
                    style: AppText.label.copyWith(color: c.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              money.format(p.amount),
              style: AppText.amount.copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// Repayments on Home: what's still owed and the next few due. Tap for the
/// Repayments screen.
class RepaymentsHomeCard extends StatelessWidget {
  const RepaymentsHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final repo = context.watch<RepaymentsRepository>();
    final active = activeByDue(repo);
    final owed = active.fold(
      0.0,
      (sum, r) => sum + repo.progressOf(r).remaining,
    );

    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
      onTap: () => _open(context, const RepaymentsScreen()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Repayments', style: AppText.section)),
              Text(
                '${money.format(owed)} owed',
                style: AppText.caption.copyWith(fontSize: 13, color: c.muted),
              ),
              Icon(Icons.chevron_right, color: c.faint),
            ],
          ),
          const SizedBox(height: 6),
          if (active.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Everything is paid off.',
                style: AppText.body.copyWith(color: c.muted),
              ),
            )
          else
            for (final r in active.take(3))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.name,
                            style: AppText.rowTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          DueBadge(progress: repo.progressOf(r)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    CountUp(
                      value: r.installment ?? repo.progressOf(r).remaining,
                      builder: (context, shown) => Text(
                        money.format(shown),
                        style: AppText.amount.copyWith(fontSize: 16),
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
