import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/money/investment_sheets.dart';
import 'package:monthly_traq/models/investment_models.dart';
import 'package:monthly_traq/models/repayment_models.dart';
import 'package:monthly_traq/services/investment_math.dart';
import 'package:monthly_traq/services/investments_repository.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/services/wallets_repository.dart';
import 'package:monthly_traq/widgets/ui.dart';
import 'package:monthly_traq/l10n/l10n.dart';

void _open(BuildContext context, Widget screen) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));

/// "Updated today", "Updated 3 days ago", "Updated 2 months ago".
String updatedAgo(AppLocalizations l10n, DateTime? date) {
  if (date == null) return l10n.valueNotUpdatedYet;
  final now = DateTime.now();
  final days = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(date.year, date.month, date.day)).inDays;
  return switch (days) {
    <= 0 => l10n.updatedToday,
    1 => l10n.updatedYesterday,
    < 30 => l10n.updatedDaysAgo(days),
    _ => l10n.updatedMonthsAgo(days ~/ 30),
  };
}

/// "+Rs. 45,000 (+22.5%)" — the gain with its sign and percentage.
String gainText(MoneyFormatter money, double gain, double? percent) {
  final amount = money.format(gain, sign: MoneySign.auto);
  if (percent == null) return amount;
  final p = percent.abs() < 10
      ? percent.toStringAsFixed(1)
      : percent.toStringAsFixed(0);
  return '$amount (${percent > 0 ? '+' : ''}$p%)';
}

/// The gain as a pill: green when up, red when down.
class GainBadge extends StatelessWidget {
  final double gain;
  final double? percent;

  const GainBadge({super.key, required this.gain, required this.percent});

  @override
  Widget build(BuildContext context) {
    final p = percent;
    final label = p == null
        ? context.money.format(gain, sign: MoneySign.auto)
        : '${p > 0 ? '+' : ''}${p.abs() < 10 ? p.toStringAsFixed(1) : p.toStringAsFixed(0)}%';
    return TagBadge(
      label,
      tone: gain > 0.5
          ? BadgeTone.income
          : gain < -0.5
          ? BadgeTone.spending
          : BadgeTone.neutral,
      icon: gain > 0.5
          ? Icons.arrow_upward
          : gain < -0.5
          ? Icons.arrow_downward
          : null,
    );
  }
}

/// Profile → Investments: every account's value, what was put in, and the
/// gain.
class InvestmentsScreen extends StatelessWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final repo = context.watch<InvestmentsRepository>();
    final totals = repo.totals;

    return SubPageScaffold(
      title: context.l10n.investments,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          if (!repo.hasAccounts)
            EmptyState(
              icon: Icons.trending_up,
              title: context.l10n.trackInvestments,
              message: context.l10n.trackInvestmentsHelp,
              actionLabel: context.l10n.addAnAccount,
              onAction: () => showInvestAccountEditor(context),
            )
          else ...[
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.worthNow,
                          style: AppText.body.copyWith(color: c.muted),
                        ),
                      ),
                      GainBadge(gain: totals.gain, percent: totals.gainPercent),
                    ],
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      money.format(totals.value),
                      style: AppText.amountLarge.copyWith(fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _Stat(
                          label: context.l10n.putIn,
                          value: money.format(totals.putIn),
                        ),
                      ),
                      Expanded(
                        child: _Stat(
                          label: context.l10n.gain,
                          value: money.format(
                            totals.gain,
                            sign: MoneySign.auto,
                          ),
                          color: totals.gain > 0.5
                              ? c.income
                              : totals.gain < -0.5
                              ? c.spending
                              : null,
                        ),
                      ),
                    ],
                  ),
                  if (totals.dividends > 0) ...[
                    const SizedBox(height: 10),
                    Text(
                      context.l10n.includesDividends(
                        money.format(totals.dividends),
                      ),
                      style: AppText.label.copyWith(color: c.muted),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(
              context.l10n.accounts,
              actionLabel: context.l10n.add,
              onAction: () => showInvestAccountEditor(context),
            ),
            const SizedBox(height: 8),
            GroupCard(
              children: [
                for (final a in repo.accounts)
                  _AccountRow(progress: repo.progressOf(a)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.copyValueHelp,
              style: AppText.label.copyWith(color: c.muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _Stat({required this.label, required this.value, this.color});

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
          child: Text(value, style: AppText.statValue.copyWith(color: color)),
        ),
      ],
    );
  }
}

class _AccountRow extends StatelessWidget {
  final InvestProgress progress;

  const _AccountRow({required this.progress});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final p = progress;
    return InkWell(
      onTap: () => _open(context, InvestAccountScreen(accountId: p.account.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconTile(
              icon: Icons.candlestick_chart_outlined,
              color: p.account.color,
              size: 46,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.account.name,
                    style: AppText.rowTitle.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    updatedAgo(context.l10n, p.valuedAt),
                    style: AppText.label.copyWith(color: c.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  money.format(p.value),
                  style: AppText.amount.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                GainBadge(gain: p.gain, percent: p.gainPercent),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: c.faint),
          ],
        ),
      ),
    );
  }
}

/// One account: value, gain, the actions, how the value moved, and its
/// history.
class InvestAccountScreen extends StatelessWidget {
  final String accountId;

  const InvestAccountScreen({super.key, required this.accountId});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final repo = context.watch<InvestmentsRepository>();
    final a = repo.accountById(accountId);
    if (a == null) {
      // Deleted (here or elsewhere): close this screen.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.maybePop(context);
      });
      return const Scaffold();
    }
    final p = repo.progressOf(a);
    final history = repo.entriesFor(a.id)
      ..sort((x, y) => y.date.compareTo(x.date));

    Widget action(IconData icon, String label, VoidCallback onTap) => Expanded(
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: c.primary, size: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: AppText.label.copyWith(
                    color: c.ink,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return SubPageScaffold(
      title: a.name,
      trailing: IconButton(
        tooltip: context.l10n.editAccount,
        onPressed: () => showInvestAccountEditor(context, existing: a),
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
                    Expanded(
                      child: Text(
                        context.l10n.worthNow,
                        style: AppText.body.copyWith(color: c.muted),
                      ),
                    ),
                    GainBadge(gain: p.gain, percent: p.gainPercent),
                  ],
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    money.format(p.value),
                    style: AppText.amountLarge.copyWith(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  updatedAgo(context.l10n, p.valuedAt),
                  style: AppText.label.copyWith(color: c.muted),
                ),
                if (p.valueHistory.length >= 2) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 72,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _ValueLinePainter(
                        values: [for (final e in p.valueHistory) e.amount],
                        line: a.color,
                        surface: c.surface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        DateFormat('d MMM y').format(p.valueHistory.first.date),
                        style: AppText.caption.copyWith(color: c.muted),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('d MMM y').format(p.valueHistory.last.date),
                        style: AppText.caption.copyWith(color: c.muted),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        label: context.l10n.putIn,
                        value: money.format(p.putIn),
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        label: context.l10n.gain,
                        value: gainText(money, p.gain, p.gainPercent),
                        color: p.gain > 0.5
                            ? c.income
                            : p.gain < -0.5
                            ? c.spending
                            : null,
                      ),
                    ),
                  ],
                ),
                if (p.dividends > 0) ...[
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.includesDividends(money.format(p.dividends)),
                    style: AppText.label.copyWith(color: c.muted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              action(
                Icons.edit_note,
                context.l10n.update,
                () => showUpdateValueSheet(context, a),
              ),
              action(
                Icons.add,
                context.l10n.putIn,
                () => showInvestMoneySheet(context, a, InvestEntryKind.deposit),
              ),
              action(
                Icons.remove,
                context.l10n.takeOut,
                () =>
                    showInvestMoneySheet(context, a, InvestEntryKind.withdraw),
              ),
              action(
                Icons.payments_outlined,
                context.l10n.dividend,
                () =>
                    showInvestMoneySheet(context, a, InvestEntryKind.dividend),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionHeader(context.l10n.history),
          const SizedBox(height: 8),
          GroupCard(children: [for (final e in history) _EntryRow(entry: e)]),
        ],
      ),
    );
  }
}

/// The value updates as a line, newest on the right.
class _ValueLinePainter extends CustomPainter {
  final List<double> values;
  final Color line;
  final Color surface;

  _ValueLinePainter({
    required this.values,
    required this.line,
    required this.surface,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    var lo = values.reduce((a, b) => a < b ? a : b);
    var hi = values.reduce((a, b) => a > b ? a : b);
    if (hi - lo < 1) {
      hi += 1;
      lo -= 1;
    }
    const pad = 6.0;
    final h = size.height - pad * 2;
    Offset at(int i) => Offset(
      pad + (size.width - pad * 2) * i / (values.length - 1),
      pad + h - (values[i] - lo) / (hi - lo) * h,
    );

    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(at(i).dx, at(i).dy);
    }
    final area = Path.from(path)
      ..lineTo(at(values.length - 1).dx, size.height)
      ..lineTo(at(0).dx, size.height)
      ..close();
    canvas.drawPath(area, Paint()..color = line.withValues(alpha: 0.12));
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    final last = at(values.length - 1);
    canvas.drawCircle(last, 5, Paint()..color = surface);
    canvas.drawCircle(last, 3.5, Paint()..color = line);
  }

  @override
  bool shouldRepaint(_ValueLinePainter old) =>
      old.values != values || old.line != line || old.surface != surface;
}

class _EntryRow extends StatelessWidget {
  final InvestEntry entry;

  const _EntryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final txRepo = context.watch<TransactionsRepository>();
    final wallets = context.watch<WalletsRepository>();
    final e = entry;
    final where = switch (e.source) {
      PaymentSource.budget => () {
        final tx = txRepo.transactions
            .where((t) => t.id == e.transactionId)
            .firstOrNull;
        final category = txRepo.categoryById(tx?.categoryId);
        final base = e.kind == InvestEntryKind.deposit
            ? context.l10n.monthlyMoney
            : context.l10n.income;
        return category == null ? base : '$base · ${category.name}';
      }(),
      PaymentSource.wallet => () {
        final w = wallets.entries
            .where((x) => x.id == e.walletEntryId)
            .firstOrNull;
        final name =
            wallets.walletById(w?.walletId)?.name ?? context.l10n.aWallet;
        return e.kind == InvestEntryKind.deposit
            ? context.l10n.fromWalletNamed(name)
            : context.l10n.intoWalletNamed(name);
      }(),
      PaymentSource.none => null,
    };
    final (IconData icon, String title) = switch (e.kind) {
      InvestEntryKind.value => (Icons.edit_note, context.l10n.valueUpdated),
      InvestEntryKind.deposit => (Icons.add, context.l10n.putIn),
      InvestEntryKind.withdraw => (Icons.remove, context.l10n.tookOut),
      InvestEntryKind.dividend => (
        Icons.payments_outlined,
        context.l10n.dividend,
      ),
    };
    final date = DateFormat(
      e.date.year == DateTime.now().year ? 'd MMM' : 'd MMM y',
    ).format(e.date);

    return InkWell(
      onTap: () => confirmDeleteInvestEntry(context, e),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconTile(icon: icon, color: c.muted, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.rowTitle.copyWith(fontSize: 16)),
                  const SizedBox(height: 1),
                  Text(
                    where == null ? date : '$date · $where',
                    style: AppText.label.copyWith(color: c.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              switch (e.kind) {
                InvestEntryKind.value => money.format(e.amount),
                InvestEntryKind.withdraw => money.format(
                  e.amount,
                  sign: MoneySign.expense,
                ),
                _ => money.format(e.amount, sign: MoneySign.income),
              },
              style: AppText.amount.copyWith(
                fontSize: 16,
                color: e.kind == InvestEntryKind.dividend ? c.income : c.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
