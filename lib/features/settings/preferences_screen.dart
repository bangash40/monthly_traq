import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/edit_budget_dialog.dart';
import 'package:monthly_traq/widgets/edit_currency_dialog.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionsRepository>();
    final currency = NumberFormat.decimalPattern();
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          Material(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Monthly budget'),
                  subtitle: Text(
                    '${repo.currencySymbol} ${currency.format(repo.monthlyBudget)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showEditBudgetDialog(context, repo),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Currency symbol'),
                  subtitle: Text(repo.currencySymbol),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showEditCurrencyDialog(context, repo),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
