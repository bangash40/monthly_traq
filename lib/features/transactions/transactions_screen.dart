import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/transactions/add_edit_transaction_screen.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/delete_transaction.dart';
import 'package:monthly_traq/widgets/month_switcher.dart';
import 'package:monthly_traq/widgets/transaction_rows.dart';
import 'package:monthly_traq/widgets/ui.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String? _categoryFilter;
  final _searchController = TextEditingController();
  String _query = '';

  // Swiped-away rows are hidden right away, before Firestore's snapshot
  // drops them — a dismissed Dismissible must leave the tree immediately.
  final Set<String> _pendingDeleteIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(TransactionModel t, CategoryModel? category) {
    if (_query.isEmpty) return true;
    final query = _query.toLowerCase();
    return t.title.toLowerCase().contains(query) ||
        (t.note?.toLowerCase().contains(query) ?? false) ||
        (category?.name.toLowerCase().contains(query) ?? false);
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _categoryFilter = null;
    });
  }

  Future<void> _delete(TransactionModel t) async {
    setState(() => _pendingDeleteIds.add(t.id));
    final deleted = await deleteTransactionWithUndo(context, t);
    if (!deleted && mounted) setState(() => _pendingDeleteIds.remove(t.id));
  }

  void _open(TransactionModel? t) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTransactionScreen(existing: t),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionsRepository>();
    final c = context.colors;
    // Forget ids whose delete has landed, so an Undo that restores one
    // makes it visible again.
    _pendingDeleteIds.retainWhere(
      (id) => repo.transactions.any((t) => t.id == id),
    );

    final inCycle = repo.selectedCycleTransactions
        .where((t) => !_pendingDeleteIds.contains(t.id))
        .toList();
    final visible = inCycle.where((t) {
      if (_categoryFilter != null && t.categoryId != _categoryFilter) {
        return false;
      }
      return _matchesSearch(t, repo.categoryById(t.categoryId));
    }).toList();

    // Only categories this month actually uses, in the user's order.
    final usedIds = {for (final t in inCycle) t.categoryId};
    final chips = repo.categories
        .where((cat) => usedIds.contains(cat.id) || cat.id == _categoryFilter)
        .toList();

    final hasFilters = _categoryFilter != null || _query.isNotEmpty;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          const Text('Transactions', style: AppText.screenTitle),
          const SizedBox(height: 16),
          const MonthSwitcher(),
          const SizedBox(height: 12),
          _CycleSummary(transactions: inCycle),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search transactions',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 8),
                child: Icon(Icons.search, size: 26),
              ),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
                borderSide: BorderSide(color: c.hairline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
                borderSide: BorderSide(color: c.hairline),
              ),
            ),
            onChanged: (value) => setState(() => _query = value.trim()),
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                children: [
                  _FilterPill(
                    label: 'All',
                    selected: _categoryFilter == null,
                    onTap: () => setState(() => _categoryFilter = null),
                  ),
                  for (final category in chips) ...[
                    const SizedBox(width: 8),
                    _FilterPill(
                      label: category.name,
                      icon: category.icon,
                      iconColor: category.color,
                      selected: _categoryFilter == category.id,
                      onTap: () => setState(
                        () => _categoryFilter = _categoryFilter == category.id
                            ? null
                            : category.id,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (visible.isEmpty) ...[
            const SizedBox(height: 20),
            hasFilters
                ? EmptyState(
                    icon: Icons.search_off,
                    title: 'No matches',
                    message:
                        'Nothing this month matches your search or filter.',
                    actionLabel: 'Clear filters',
                    onAction: _clearFilters,
                  )
                : EmptyState(
                    icon: Icons.receipt_long,
                    title: 'Nothing logged in ${repo.selectedCycle.shortTitle}',
                    message:
                        'Log what you spend and earn and it shows up here, '
                        'grouped by day.',
                    actionLabel: 'Add transaction',
                    onAction: () => _open(null),
                  ),
          ] else
            for (final bucket in groupByDay(visible)) ...[
              DayHeader(bucket),
              GroupCard(
                children: [
                  for (final t in bucket.transactions)
                    Dismissible(
                      key: ValueKey(t.id),
                      direction: DismissDirection.endToStart,
                      background: const _DeleteBackground(),
                      onDismissed: (_) => _delete(t),
                      child: TransactionRow(
                        transaction: t,
                        category: repo.categoryById(t.categoryId),
                        onTap: () => _open(t),
                      ),
                    ),
                ],
              ),
            ],
        ],
      ),
    );
  }
}

/// In / Out / Net for the selected month.
class _CycleSummary extends StatelessWidget {
  final List<TransactionModel> transactions;

  const _CycleSummary({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    var income = 0.0;
    var spent = 0.0;
    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        spent += t.amount;
      }
    }

    Widget tile(String label, String value, Color color) => Expanded(
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        radius: AppRadius.button,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.label.copyWith(color: c.muted)),
            const SizedBox(height: 2),
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
    );

    return Row(
      children: [
        tile(
          'In',
          money.format(income, sign: MoneySign.income, withSymbol: false),
          c.income,
        ),
        const SizedBox(width: 10),
        tile(
          'Out',
          money.format(spent, sign: MoneySign.expense, withSymbol: false),
          c.ink,
        ),
        const SizedBox(width: 10),
        tile(
          'Net',
          money.format(income - spent, sign: MoneySign.auto, withSymbol: false),
          c.ink,
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    this.icon,
    this.iconColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final foreground = selected ? c.surface : c.ink;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? c.ink : c.surface,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? c.ink : c.hairline),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 18,
                    color: selected ? foreground : iconColor,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: AppText.rowTitle.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.spendingFill,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.delete_outline, color: Colors.white),
          const SizedBox(height: 2),
          Text(
            'Delete',
            style: AppText.caption.copyWith(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
