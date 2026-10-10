import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/currencies.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/ui.dart';
import 'package:monthly_traq/l10n/l10n.dart';

class CurrencyPickerScreen extends StatefulWidget {
  const CurrencyPickerScreen({super.key});

  @override
  State<CurrencyPickerScreen> createState() => _CurrencyPickerScreenState();
}

class _CurrencyPickerScreenState extends State<CurrencyPickerScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _select(CurrencyOption currency) async {
    final repo = context.read<TransactionsRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = context.l10n;
    try {
      await repo.updateCurrency(currency);
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.couldNotSave(errorMessage(l10n, e)))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selectedCode = context.select<TransactionsRepository, String?>(
      (r) => r.currencyCode,
    );
    final query = _query.toLowerCase();
    final results = query.isEmpty
        ? kCurrencyOptions
        : kCurrencyOptions
              .where(
                (o) =>
                    o.name.toLowerCase().contains(query) ||
                    o.code.toLowerCase().contains(query) ||
                    o.country.toLowerCase().contains(query),
              )
              .toList();

    return SubPageScaffold(
      title: context.l10n.currency,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: context.l10n.currencySearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: context.l10n.clearSearch,
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      EmptyState(
                        icon: Icons.search_off,
                        title: context.l10n.noMatchingCurrency,
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      GroupCard(
                        children: [
                          for (final option in results)
                            InkWell(
                              onTap: () => _select(option),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  12,
                                  16,
                                  12,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 54,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: option.code == selectedCode
                                            ? c.primarySoft
                                            : c.surfaceHigh,
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.iconTile,
                                        ),
                                      ),
                                      child: Text(
                                        option.code,
                                        style: AppText.caption.copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: option.code == selectedCode
                                              ? c.accent
                                              : c.ink,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            option.name,
                                            style: AppText.rowTitle,
                                          ),
                                          Text(
                                            option.country,
                                            style: AppText.label.copyWith(
                                              color: c.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      option.symbol,
                                      style: AppText.rowTitle.copyWith(
                                        color: c.muted,
                                      ),
                                    ),
                                    if (option.code == selectedCode) ...[
                                      const SizedBox(width: 10),
                                      Icon(Icons.check_circle, color: c.accent),
                                    ],
                                  ],
                                ),
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
