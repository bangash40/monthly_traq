import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/cycle_stats.dart';
import 'package:monthly_traq/widgets/ui.dart';

/// What a transaction is called in lists: its title, or its category's
/// name when it was saved without one.
String transactionTitle(TransactionModel t, CategoryModel? category) {
  final title = t.title.trim();
  if (title.isNotEmpty) return title;
  return category?.name ?? 'Uncategorized';
}

/// "Today", "Yesterday", "Tue, Sep 22" (with the year outside this year).
String dayLabel(DateTime day, {DateTime? now}) {
  final today = DateUtils.dateOnly(now ?? DateTime.now());
  final date = DateUtils.dateOnly(day);
  if (date == today) return 'Today';
  if (date == DateUtils.addDaysToDate(today, -1)) return 'Yesterday';
  return DateFormat(date.year == today.year ? 'EEE, MMM d' : 'EEE, MMM d, y')
      .format(date);
}

/// "Today" or "Sep 22" — the short date in a row subtitle.
String shortDate(DateTime day, {DateTime? now}) {
  final label = dayLabel(day, now: now);
  if (label == 'Today' || label == 'Yesterday') return label;
  final today = now ?? DateTime.now();
  return DateFormat(day.year == today.year ? 'MMM d' : 'MMM d, y').format(day);
}

/// One day's transactions, in the order given, with the day's net total.
class DayBucket {
  final DateTime day;
  final List<TransactionModel> transactions;

  const DayBucket(this.day, this.transactions);

  double get net => transactions.fold(
    0.0,
    (sum, t) => sum + (t.type == TransactionType.income ? t.amount : -t.amount),
  );
}

/// Splits transactions (already newest first) into consecutive days.
List<DayBucket> groupByDay(List<TransactionModel> transactions) {
  final buckets = <DayBucket>[];
  for (final t in transactions) {
    final day = DateUtils.dateOnly(t.date);
    if (buckets.isEmpty || buckets.last.day != day) {
      buckets.add(DayBucket(day, []));
    }
    buckets.last.transactions.add(t);
  }
  return buckets;
}

/// A transaction in a list: category icon, title, a secondary line, and
/// the amount — green with "+" for income, "−" for spending.
class TransactionRow extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryModel? category;

  /// Defaults to the category name.
  final String? subtitle;
  final VoidCallback? onTap;

  const TransactionRow({
    super.key,
    required this.transaction,
    required this.category,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isIncome = transaction.type == TransactionType.income;
    final resolved = category ?? uncategorized(transaction.type);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconTile(icon: resolved.icon, color: resolved.color, size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transactionTitle(transaction, category),
                    style: AppText.rowTitle.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle ?? resolved.name,
                    style: AppText.label.copyWith(color: c.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              context.money.format(
                transaction.amount,
                sign: isIncome ? MoneySign.income : MoneySign.expense,
              ),
              style: AppText.amount.copyWith(
                fontSize: 16,
                color: isIncome ? c.income : c.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Today ................ −Rs. 4,300" above a day's card.
class DayHeader extends StatelessWidget {
  final DayBucket bucket;

  const DayHeader(this.bucket, {super.key});

  @override
  Widget build(BuildContext context) {
    final style = AppText.rowTitle.copyWith(
      fontSize: 14,
      color: context.colors.muted,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Row(
        children: [
          Expanded(child: Text(dayLabel(bucket.day), style: style)),
          Text(
            context.money.format(bucket.net, sign: MoneySign.auto),
            style: AppText.tabular(style),
          ),
        ],
      ),
    );
  }
}
