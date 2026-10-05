import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:monthly_traq/app/category_icons.dart';

/// A place money is kept: JazzCash, Easypaisa, a bank account, cash…
/// Wallets are their own world: nothing in them counts as monthly income,
/// spending or budget.
class WalletModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  /// The person's own money in the wallet when it was added. Money they
  /// were keeping for others at that point is added as [WalletEntryKind
  /// .receive] entries, on top of this.
  final double openingBalance;
  final int? sortOrder;

  const WalletModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.openingBalance,
    this.sortOrder,
  });

  factory WalletModel.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return WalletModel(
      id: doc.id,
      name: data['name'] as String,
      icon: iconForKey(data['iconKey'] as String? ?? 'account_balance_wallet'),
      color: Color(data['color'] as int),
      openingBalance: (data['openingBalance'] as num).toDouble(),
      sortOrder: data['sortOrder'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'iconKey': keyForIcon(icon),
    'color': color.toARGB32(),
    'openingBalance': openingBalance,
    if (sortOrder != null) 'sortOrder': sortOrder,
  };
}

/// Someone whose money the person keeps in their wallets (an amanat): a
/// cousin, a friend… What's owed to them is worked out from their
/// [WalletEntryKind.receive] and [WalletEntryKind.giveBack] entries.
class PersonModel {
  final String id;
  final String name;

  const PersonModel({required this.id, required this.name});

  factory PersonModel.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) => PersonModel(id: doc.id, name: doc.data()['name'] as String);

  Map<String, dynamic> toMap() => {'name': name};
}

enum WalletEntryKind {
  /// The person spent money from the wallet.
  spend,

  /// The person put more of their own money in.
  add,

  /// Someone gave the person money to keep, into this wallet.
  receive,

  /// The person sent some of someone's kept money back to them.
  giveBack,

  /// Money moved from this wallet to [WalletEntry.toWalletId].
  transfer,

  /// A correction so the wallet matches its real balance; [WalletEntry
  /// .amount] is the signed difference.
  adjust;

  static WalletEntryKind byName(String? name) =>
      values.where((k) => k.name == name).firstOrNull ?? adjust;
}

/// One thing that happened in a wallet.
class WalletEntry {
  final String id;
  final WalletEntryKind kind;
  final String walletId;

  /// Where a transfer went; null otherwise.
  final String? toWalletId;

  /// Whose money was received or given back; null otherwise.
  final String? personId;

  /// Always positive, except for [WalletEntryKind.adjust].
  final double amount;
  final DateTime date;
  final String? note;

  const WalletEntry({
    required this.id,
    required this.kind,
    required this.walletId,
    this.toWalletId,
    this.personId,
    required this.amount,
    required this.date,
    this.note,
  });

  factory WalletEntry.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return WalletEntry(
      id: doc.id,
      kind: WalletEntryKind.byName(data['kind'] as String?),
      walletId: data['walletId'] as String,
      toWalletId: data['toWalletId'] as String?,
      personId: data['personId'] as String?,
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'kind': kind.name,
    'walletId': walletId,
    'toWalletId': toWalletId,
    'personId': personId,
    'amount': amount,
    'date': Timestamp.fromDate(date),
    'note': note,
  };
}
