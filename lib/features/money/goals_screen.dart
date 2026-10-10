import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/money/goal_sheets.dart';
import 'package:monthly_traq/models/goal_models.dart';
import 'package:monthly_traq/models/repayment_models.dart';
import 'package:monthly_traq/services/goal_progress.dart';
import 'package:monthly_traq/services/goals_repository.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/services/wallets_repository.dart';
import 'package:monthly_traq/widgets/motion.dart';
import 'package:monthly_traq/widgets/ui.dart';

void _open(BuildContext context, Widget screen) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));

/// Goals still being saved for, in the order they were added.
List<GoalModel> activeGoals(GoalsRepository repo) => [
  for (final g in repo.goals)
    if (!g.isDone) g,
];

/// "On track" / "Behind" / "Reached" as a pill.
class GoalBadge extends StatelessWidget {
  final GoalProgress progress;

  const GoalBadge({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    if (progress.goal.isDone) {
      return const TagBadge('Done', tone: BadgeTone.income);
    }
    final status = progress.status(DateTime.now());
    return TagBadge(
      status.label,
      tone: switch (status) {
        GoalStatus.reached || GoalStatus.onTrack => BadgeTone.income,
        GoalStatus.behind => BadgeTone.warning,
        GoalStatus.overdue => BadgeTone.spending,
        GoalStatus.noDate => BadgeTone.neutral,
      },
    );
  }
}

/// "Save Rs. 15,000 a month to reach it by Mar 2027", or "Rs. 90,000 to
/// go" without a date.
String goalPace(GoalProgress p, MoneyFormatter money) {
  final g = p.goal;
  if (g.isDone) {
    return 'Done ${DateFormat('d MMM y').format(g.doneAt!)}';
  }
  if (p.isReached) return 'Reached — mark it done when you buy it';
  final perMonth = p.perMonth(DateTime.now());
  final date = g.targetDate;
  if (perMonth != null && date != null) {
    return 'Save ${money.format(perMonth.ceilToDouble())} a month to reach it '
        'by ${DateFormat('MMM y').format(date)}';
  }
  return '${money.format(p.remaining)} to go';
}

/// Profile → Savings goals: everything being saved for, and what's done.
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final repo = context.watch<GoalsRepository>();
    final active = activeGoals(repo);
    final done = [
      for (final g in repo.goals)
        if (g.isDone) g,
    ];
    var saved = 0.0;
    var toGo = 0.0;
    for (final g in active) {
      final p = repo.progressOf(g);
      saved += p.saved;
      toGo += p.remaining;
    }

    return SubPageScaffold(
      title: 'Savings goals',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          if (!repo.hasGoals)
            EmptyState(
              icon: Icons.savings_outlined,
              title: 'Save up for something',
              message:
                  'Add a goal — a new mobile, a bike, a trip — and see how '
                  'close you are and how much to save each month.',
              actionLabel: 'Add a goal',
              onAction: () => showGoalEditor(context),
            )
          else ...[
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved for goals',
                    style: AppText.body.copyWith(color: c.muted),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      money.format(saved),
                      style: AppText.amountLarge.copyWith(fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _Stat(
                          label: 'Still to save',
                          value: money.format(toGo),
                        ),
                      ),
                      Expanded(
                        child: _Stat(label: 'Goals', value: '${active.length}'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(
              'Saving for',
              actionLabel: 'Add',
              onAction: () => showGoalEditor(context),
            ),
            const SizedBox(height: 8),
            if (active.isEmpty)
              Text(
                'All your goals are done.',
                style: AppText.body.copyWith(color: c.muted),
              )
            else
              GroupCard(children: [for (final g in active) GoalRow(goal: g)]),
            if (done.isNotEmpty) ...[
              const SizedBox(height: 24),
              const SectionHeader('Done'),
              const SizedBox(height: 8),
              GroupCard(children: [for (final g in done) GoalRow(goal: g)]),
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

/// One goal: icon, name, status, progress, and the pace to reach it.
class GoalRow extends StatelessWidget {
  final GoalModel goal;

  const GoalRow({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final p = context.watch<GoalsRepository>().progressOf(goal);
    final percent = (p.fraction * 100).floor();

    return InkWell(
      onTap: () => _open(context, GoalScreen(goalId: goal.id)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconTile(icon: goal.icon, color: goal.color, size: 46),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          goal.name,
                          style: AppText.rowTitle.copyWith(
                            fontSize: 16,
                            color: goal.isDone ? c.muted : c.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GoalBadge(progress: p),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${money.format(p.saved)} of ${money.format(goal.target)}'
                    ' · $percent%',
                    style: AppText.label.copyWith(
                      color: c.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  MeterBar(value: p.fraction, color: goal.color, height: 6),
                  const SizedBox(height: 6),
                  Text(
                    goalPace(p, money),
                    style: AppText.label.copyWith(color: c.muted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Icon(Icons.chevron_right, color: c.faint),
            ),
          ],
        ),
      ),
    );
  }
}

/// One goal: what's saved, the pace, Add / Take out, and its history.
class GoalScreen extends StatelessWidget {
  final String goalId;

  const GoalScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final repo = context.watch<GoalsRepository>();
    final g = repo.goalById(goalId);
    if (g == null) {
      // Deleted (here or elsewhere): close this screen.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.maybePop(context);
      });
      return const Scaffold();
    }
    final p = repo.progressOf(g);
    final history = repo.entriesFor(g.id).reversed.toList();
    final now = DateTime.now();
    final perMonth = p.perMonth(now);

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
      title: g.name,
      trailing: IconButton(
        tooltip: 'Edit goal',
        onPressed: () => showGoalEditor(context, existing: g),
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
                Row(
                  children: [
                    IconTile(icon: g.icon, color: g.color, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Saved',
                        style: AppText.body.copyWith(color: c.muted),
                      ),
                    ),
                    GoalBadge(progress: p),
                  ],
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    money.format(p.saved),
                    style: AppText.amountLarge.copyWith(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 14),
                MeterBar(value: p.fraction, color: g.color),
                const SizedBox(height: 10),
                Text(
                  'of ${money.format(g.target)} · '
                  '${(p.fraction * 100).floor()}%',
                  style: AppText.label.copyWith(color: c.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GroupCard(
            children: [
              info('To go', infoText(money.format(p.remaining))),
              if (g.targetDate != null)
                info(
                  'Reach it by',
                  infoText(DateFormat('d MMM y').format(g.targetDate!)),
                ),
              if (perMonth != null)
                info(
                  'Save each month',
                  infoText(money.format(perMonth.ceilToDouble())),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (g.isDone)
            OutlinedButton.icon(
              onPressed: () => repo.setDone(g, false),
              icon: const Icon(Icons.undo),
              label: const Text('Not done yet'),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: p.saved > 0
                        ? () => showGoalMoneySheet(
                            context,
                            g,
                            GoalEntryKind.takeOut,
                          )
                        : null,
                    icon: const Icon(Icons.remove),
                    label: const Text('Take out'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        showGoalMoneySheet(context, g, GoalEntryKind.add),
                    icon: const Icon(Icons.add),
                    label: const Text('Add money'),
                  ),
                ),
              ],
            ),
            if (p.isReached) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => repo.setDone(g, true),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark as done'),
              ),
            ],
          ],
          const SizedBox(height: 24),
          const SectionHeader('History'),
          const SizedBox(height: 8),
          if (history.isEmpty && g.savedBefore <= 0)
            Text(
              'Money you add or take out shows up here.',
              style: AppText.body.copyWith(color: c.muted),
            )
          else
            GroupCard(
              children: [
                for (final e in history) _EntryRow(entry: e),
                if (g.savedBefore > 0)
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
                            'Saved before tracking',
                            style: AppText.rowTitle.copyWith(fontSize: 16),
                          ),
                        ),
                        Text(
                          money.format(g.savedBefore),
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

class _EntryRow extends StatelessWidget {
  final GoalEntry entry;

  const _EntryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final txRepo = context.watch<TransactionsRepository>();
    final wallets = context.watch<WalletsRepository>();
    final e = entry;
    final adding = e.kind == GoalEntryKind.add;
    final where = switch (e.source) {
      PaymentSource.budget => () {
        final tx = txRepo.transactions
            .where((t) => t.id == e.transactionId)
            .firstOrNull;
        final category = txRepo.categoryById(tx?.categoryId);
        return category == null
            ? 'Monthly money'
            : 'Monthly money · ${category.name}';
      }(),
      PaymentSource.wallet => () {
        final entry = wallets.entries
            .where((w) => w.id == e.walletEntryId)
            .firstOrNull;
        final name = wallets.walletById(entry?.walletId)?.name ?? 'a wallet';
        return adding ? 'From $name' : 'Into $name';
      }(),
      PaymentSource.none => 'Recorded only',
    };

    return InkWell(
      onTap: () => confirmDeleteGoalEntry(context, e),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconTile(
              icon: adding ? Icons.add : Icons.remove,
              color: c.muted,
              size: 44,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${adding ? 'Added' : 'Took out'} · '
                    '${DateFormat(e.date.year == DateTime.now().year ? 'd MMM' : 'd MMM y').format(e.date)}',
                    style: AppText.rowTitle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    where,
                    style: AppText.label.copyWith(color: c.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              money.format(
                e.amount,
                sign: adding ? MoneySign.income : MoneySign.expense,
              ),
              style: AppText.amount.copyWith(
                fontSize: 16,
                color: adding ? c.income : c.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Savings goals on Home: the first few goals with their progress. Tap for
/// the Savings goals screen.
class GoalsHomeCard extends StatelessWidget {
  const GoalsHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final repo = context.watch<GoalsRepository>();
    final active = activeGoals(repo);
    final saved = active.fold(0.0, (sum, g) => sum + repo.progressOf(g).saved);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
      onTap: () => _open(context, const GoalsScreen()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Savings goals', style: AppText.section),
              ),
              Text(
                '${money.format(saved)} saved',
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
                'All your goals are done.',
                style: AppText.body.copyWith(color: c.muted),
              ),
            )
          else
            for (final g in active.take(3))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(g.icon, color: g.color, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            g.name,
                            style: AppText.rowTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        CountUp(
                          value: repo.progressOf(g).fraction * 100,
                          builder: (context, shown) => Text(
                            '${shown.floor()}%',
                            style: AppText.amount.copyWith(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    MeterBar(
                      value: repo.progressOf(g).fraction,
                      color: g.color,
                      height: 6,
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
