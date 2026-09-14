enum TransactionType { income, expense }

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

  TransactionModel copyWith({
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? date,
    String? note,
  }) {
    return TransactionModel(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
