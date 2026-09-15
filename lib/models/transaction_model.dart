import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

const _unset = Object();

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String? categoryId;
  final DateTime date;
  final String? note;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    this.categoryId,
    required this.date,
    this.note,
  });

  factory TransactionModel.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return TransactionModel(
      id: doc.id,
      title: data['title'] as String,
      amount: (data['amount'] as num).toDouble(),
      type: data['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      categoryId: data['categoryId'] as String?,
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'categoryId': categoryId,
      'date': Timestamp.fromDate(date),
      'note': note,
    };
  }

  /// [categoryId] defaults to the sentinel `_unset` so it can be explicitly
  /// cleared with `copyWith(categoryId: null)` — omitting it keeps the
  /// current value, same as every other field here.
  TransactionModel copyWith({
    String? title,
    double? amount,
    TransactionType? type,
    Object? categoryId = _unset,
    DateTime? date,
    String? note,
  }) {
    return TransactionModel(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
