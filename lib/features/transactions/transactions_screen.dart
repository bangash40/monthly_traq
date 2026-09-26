import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/features/transactions/add_edit_transaction_screen.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/delete_transaction.dart';
import 'package:monthly_traq/widgets/empty_state.dart';
import 'package:monthly_traq/widgets/month_switcher.dart';
import 'package:monthly_traq/widgets/transaction_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

/// One day's heading in the grouped list, with that day's net total.
class _DayHeader {
  final DateTime day;
  final double net;

  const _DayHeader(this.day, this.net);
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String? _categoryFilter;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Swiped-away rows are hidden right away, before Firestore's snapshot
  // drops them — a dismissed Dismissible must leave the tree immediately.
  final Set<String> _pendingDeleteIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(TransactionModel t) {
    if (_searchQuery.isEmpty) return true;
    final query = _searchQuery.toLowerCase();
    return t.title.toLowerCase().contains(query) ||
        (t.note?.toLowerCase().contains(query) ?? false);
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _categoryFilter = null;
    });
  }

  Future<void> _delete(TransactionModel t) async {
    setState(() => _pendingDeleteIds.add(t.id));
    final deleted = await deleteTransactionWithUndo(context, t);
    if (!deleted && mounted) setState(() => _pendingDeleteIds.remove(t.id));
  }

  /// The transactions (already newest first) with a [_DayHeader] before
  /// each day's group.
  List<Object> _groupByDay(List<TransactionModel> transactions) {
    final items = <Object>[];
    DateTime? currentDay;
    var headerIndex = -1;
    var net = 0.0;

    for (final t in transactions) {
      final day = DateUtils.dateOnly(t.date);
      if (day != currentDay) {
        if (headerIndex >= 0) items[headerIndex] = _DayHeader(currentDay!, net);
        currentDay = day;
        net = 0;
        headerIndex = items.length;
        items.add(_DayHeader(day, 0));
      }
      net += t.type == TransactionType.income ? t.amount : -t.amount;
      items.add(t);
    }
    if (headerIndex >= 0) items[headerIndex] = _DayHeader(currentDay!, net);
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionsRepository>();
    // Forget ids whose delete has landed, so an Undo that restores one
    // makes it visible again.
    _pendingDeleteIds.retainWhere(
      (id) => repo.transactions.any((t) => t.id == id),
    );
    final hasFilters = _categoryFilter != null || _searchQuery.isNotEmpty;
    final transactions = repo.selectedCycleTransactions.where((t) {
      if (_pendingDeleteIds.contains(t.id)) return false;
      if (_categoryFilter != null && t.categoryId != _categoryFilter) return false;
      return _matchesSearch(t);
    }).toList();
    final items = _groupByDay(transactions);

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: MonthSwitcher(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: _categoryFilter == null,
                    onSelected: (_) => setState(() => _categoryFilter = null),
                  ),
                ),
                ...repo.categories.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(c.icon, size: 16, color: c.color),
                      label: Text(c.name),
                      selected: _categoryFilter == c.id,
                      onSelected: (_) => setState(() => _categoryFilter = c.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      child: hasFilters
                          ? EmptyState(
                              icon: Icons.search_off,
                              title: 'No matches',
                              message:
                                  'No transactions match your search or filter.',
                              actionLabel: 'Clear filters',
                              onAction: _clearFilters,
                            )
                          : EmptyState(
                              icon: Icons.receipt_long,
                              title: 'No transactions in ${repo.cycleLabel}',
                              message:
                                  'Everything you log shows up here, grouped by day.',
                              actionLabel: 'Add transaction',
                              onAction: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AddEditTransactionScreen(),
                                ),
                              ),
                            ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      if (item is _DayHeader) {
                        return _DayHeaderRow(
                          header: item,
                          symbol: repo.currencySymbol,
                        );
                      }
                      final t = item as TransactionModel;
                      final isLastOfDay =
                          index == items.length - 1 ||
                          items[index + 1] is _DayHeader;
                      return Column(
                        children: [
                          Dismissible(
                            key: ValueKey(t.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              color: Colors.red.shade400,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _delete(t),
                            child: TransactionTile(
                              transaction: t,
                              category: repo.categoryById(t.categoryId),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddEditTransactionScreen(existing: t),
                                ),
                              ),
                            ),
                          ),
                          if (!isLastOfDay) const Divider(height: 1),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DayHeaderRow extends StatelessWidget {
  final _DayHeader header;
  final String symbol;

  const _DayHeaderRow({required this.header, required this.symbol});

  String _label() {
    final today = DateUtils.dateOnly(DateTime.now());
    if (DateUtils.isSameDay(header.day, today)) return 'Today';
    if (DateUtils.isSameDay(header.day, DateUtils.addDaysToDate(today, -1))) {
      return 'Yesterday';
    }
    final pattern = header.day.year == today.year
        ? 'EEE, MMM d'
        : 'EEE, MMM d, y';
    return DateFormat(pattern).format(header.day);
  }

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final amount = NumberFormat.decimalPattern().format(header.net.abs());
    final sign = header.net < 0 ? '−' : '+';
    final style = AppText.labelStrong.copyWith(color: onSurfaceVariant);

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(_label(), style: style)),
          Text('$sign$symbol $amount', style: style),
        ],
      ),
    );
  }
}
