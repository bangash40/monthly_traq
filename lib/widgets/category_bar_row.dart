import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/services/transactions_repository.dart';

/// One row of the spending-by-category breakdown. Bar width is proportional
/// to [amount] / [maxAmount]; the bar always uses the category's own fixed
/// color, never a color assigned by rank.
class CategoryBarRow extends StatelessWidget {
  final CategoryModel category;
  final double amount;
  final double maxAmount;
  final double sharePercent;

  const CategoryBarRow({
    super.key,
    required this.category,
    required this.amount,
    required this.maxAmount,
    required this.sharePercent,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxAmount <= 0 ? 0.0 : (amount / maxAmount).clamp(0.0, 1.0);
    final symbol = context.watch<TransactionsRepository>().currencySymbol;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, size: 16, color: category.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '$symbol ${NumberFormat.decimalPattern().format(amount)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 6),
              Text(
                '${sharePercent.round()}%',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Stack(
                children: [
                  Container(color: category.color.withValues(alpha: 0.15)),
                  FractionallySizedBox(
                    widthFactor: ratio,
                    alignment: Alignment.centerLeft,
                    child: Container(color: category.color),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
