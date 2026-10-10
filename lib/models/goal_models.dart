import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:monthly_traq/app/category_icons.dart';
import 'package:monthly_traq/models/repayment_models.dart';

/// Something the person is saving up for: a mobile, a bike… What's saved
/// is [savedBefore] plus money added, minus money taken out.
class GoalModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double target;

  /// Saved before the goal was added to the app.
  final double savedBefore;

  /// When they'd like to have it; null for no date.
  final DateTime? targetDate;

  /// When it was marked done (bought it!); null while still saving.
  final DateTime? doneAt;

  /// When the goal was added — the start of its "on track" line.
  final DateTime createdAt;

  /// How money was last added, to start the next time the same way.
  final PaymentSource addSource;
  final String? categoryId;
  final String? walletId;

  const GoalModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.target,
    this.savedBefore = 0,
    this.targetDate,
    this.doneAt,
    required this.createdAt,
    this.addSource = PaymentSource.budget,
    this.categoryId,
    this.walletId,
  });

  bool get isDone => doneAt != null;

  factory GoalModel.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return GoalModel(
      id: doc.id,
      name: data['name'] as String,
      icon: iconForKey(data['iconKey'] as String? ?? 'savings'),
      color: Color(data['color'] as int),
      target: (data['target'] as num).toDouble(),
      savedBefore: (data['savedBefore'] as num? ?? 0).toDouble(),
      targetDate: (data['targetDate'] as Timestamp?)?.toDate(),
      doneAt: (data['doneAt'] as Timestamp?)?.toDate(),
      // Null for a moment while a new goal's server timestamp is pending.
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      addSource: PaymentSource.byName(data['addSource'] as String?),
      categoryId: data['categoryId'] as String?,
      walletId: data['walletId'] as String?,
    );
  }

  /// Everything but createdAt, which is written once when the goal is added.
  Map<String, dynamic> toMap() => {
    'name': name,
    'iconKey': keyForIcon(icon),
    'color': color.toARGB32(),
    'target': target,
    'savedBefore': savedBefore,
    'targetDate': targetDate == null ? null : Timestamp.fromDate(targetDate!),
    'doneAt': doneAt == null ? null : Timestamp.fromDate(doneAt!),
    'addSource': addSource.name,
    'categoryId': categoryId,
    'walletId': walletId,
  };
}

enum GoalEntryKind {
  /// Money put towards the goal.
  add,

  /// Money taken back out of it.
  takeOut;

  static GoalEntryKind byName(String? name) =>
      values.where((k) => k.name == name).firstOrNull ?? add;
}

/// Money added to or taken out of a goal.
class GoalEntry {
  final String id;
  final String goalId;
  final GoalEntryKind kind;
  final double amount;
  final DateTime date;

  /// Adding: where the money came from. Taking out: where it went
  /// ([PaymentSource.wallet]) or nowhere in particular ([PaymentSource.none]).
  final PaymentSource source;

  /// The expense transaction it added (adding from monthly money).
  final String? transactionId;

  /// The wallet entry it added: "Spent" when adding from a wallet, "Add"
  /// when taking out into one.
  final String? walletEntryId;

  const GoalEntry({
    required this.id,
    required this.goalId,
    required this.kind,
    required this.amount,
    required this.date,
    required this.source,
    this.transactionId,
    this.walletEntryId,
  });

  factory GoalEntry.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return GoalEntry(
      id: doc.id,
      goalId: data['goalId'] as String,
      kind: GoalEntryKind.byName(data['kind'] as String?),
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      source: PaymentSource.byName(data['source'] as String?),
      transactionId: data['transactionId'] as String?,
      walletEntryId: data['walletEntryId'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'goalId': goalId,
    'kind': kind.name,
    'amount': amount,
    'date': Timestamp.fromDate(date),
    'source': source.name,
    'transactionId': transactionId,
    'walletEntryId': walletEntryId,
  };
}
