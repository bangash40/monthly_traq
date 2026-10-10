import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:monthly_traq/models/repayment_models.dart';

/// A brokerage account the person invests through, e.g. "AKD Trade". Its
/// value is copied in from the broker's app now and then.
class InvestAccount {
  final String id;
  final String name;
  final Color color;

  const InvestAccount({
    required this.id,
    required this.name,
    required this.color,
  });

  factory InvestAccount.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return InvestAccount(
      id: doc.id,
      name: data['name'] as String,
      color: Color(data['color'] as int),
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'color': color.toARGB32()};
}

enum InvestEntryKind {
  /// Money put into the account.
  deposit,

  /// Money taken out of it.
  withdraw,

  /// A dividend received (paid out, so it doesn't change the account's
  /// value — it's part of the gain).
  dividend,

  /// The account's value, copied from the broker's app; [InvestEntry
  /// .amount] is the whole value, not a change.
  value;

  static InvestEntryKind byName(String? name) =>
      values.where((k) => k.name == name).firstOrNull ?? value;
}

/// Something that happened in an investment account.
class InvestEntry {
  final String id;
  final String accountId;
  final InvestEntryKind kind;
  final double amount;
  final DateTime date;

  /// Deposit: where the money came from. Withdrawal and dividend: where it
  /// went. Always [PaymentSource.none] for value updates.
  final PaymentSource source;

  /// The transaction it added: an expense for a deposit from monthly
  /// money, income for a withdrawal or dividend into it.
  final String? transactionId;

  /// The wallet entry it added: "Spent" for a deposit, "Add" for a
  /// withdrawal or dividend.
  final String? walletEntryId;

  const InvestEntry({
    required this.id,
    required this.accountId,
    required this.kind,
    required this.amount,
    required this.date,
    this.source = PaymentSource.none,
    this.transactionId,
    this.walletEntryId,
  });

  factory InvestEntry.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return InvestEntry(
      id: doc.id,
      accountId: data['accountId'] as String,
      kind: InvestEntryKind.byName(data['kind'] as String?),
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      source: PaymentSource.byName(data['source'] as String?),
      transactionId: data['transactionId'] as String?,
      walletEntryId: data['walletEntryId'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'accountId': accountId,
    'kind': kind.name,
    'amount': amount,
    'date': Timestamp.fromDate(date),
    'source': source.name,
    'transactionId': transactionId,
    'walletEntryId': walletEntryId,
  };
}
