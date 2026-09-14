import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monthly_traq/app/palette.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryModel? category;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final iconColor = isIncome ? AppPalette.good : (category?.color ?? Colors.grey);
    final icon = isIncome
        ? Icons.arrow_downward_rounded
        : (category?.icon ?? Icons.category);

    final amountText =
        '${isIncome ? '+' : '-'}Rs. ${NumberFormat.decimalPattern().format(transaction.amount)}';

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: iconColor.withValues(alpha: 0.12),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        transaction.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        isIncome ? 'Income' : (category?.name ?? 'Uncategorized'),
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            amountText,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isIncome ? AppPalette.successText : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('MMM d').format(transaction.date),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
