import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/transaction_model.dart';

void main() {
  const loan = CategoryModel(
    id: 'loan',
    name: 'Loan repayment',
    icon: Icons.handshake,
    color: Color(0xFF2A78D6),
    excludeFromBudget: true,
  );
  const food = CategoryModel(
    id: 'food',
    name: 'Food',
    icon: Icons.restaurant,
    color: Color(0xFFEB6834),
  );
  const salary = CategoryModel(
    id: 'salary',
    name: 'Salary',
    icon: Icons.work,
    color: Color(0xFF2A78D6),
    type: TransactionType.income,
  );

  test('expense categories count toward the budget by default', () {
    expect(food.excludeFromBudget, isFalse);
    expect(food.countsTowardBudget, isTrue);
  });

  test('a not-in-budget category does not count', () {
    expect(loan.countsTowardBudget, isFalse);
  });

  test('income never counts toward the budget', () {
    expect(salary.countsTowardBudget, isFalse);
  });

  test('the setting is saved with the category', () {
    expect(loan.toMap()['excludeFromBudget'], isTrue);
    expect(food.toMap()['excludeFromBudget'], isFalse);
  });
}
