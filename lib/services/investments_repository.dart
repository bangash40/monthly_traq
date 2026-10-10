import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monthly_traq/app/palette.dart';
import 'package:monthly_traq/models/investment_models.dart';
import 'package:monthly_traq/services/investment_math.dart';
import 'package:monthly_traq/services/write_sync.dart';

/// The signed-in user's investment accounts and what happened in them —
/// mirrored live from `users/{uid}/investAccounts` and
/// `users/{uid}/investEntries`.
class InvestmentsRepository extends ChangeNotifier {
  InvestmentsRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StreamSubscription<User?>? _authSub;
  final _subs = <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];

  List<InvestAccount> _accounts = [];
  List<InvestEntry> _entries = [];

  /// Every account, in the order they were added.
  List<InvestAccount> get accounts => List.unmodifiable(_accounts);

  /// Every entry, oldest first.
  List<InvestEntry> get entries => List.unmodifiable(_entries);

  bool get hasAccounts => _accounts.isNotEmpty;

  InvestAccount? accountById(String? id) =>
      id == null ? null : _accounts.where((a) => a.id == id).firstOrNull;

  InvestProgress progressOf(InvestAccount account) =>
      InvestProgress.of(account, _entries);

  InvestTotals get totals => InvestTotals.of(_accounts.map(progressOf));

  List<InvestEntry> entriesFor(String accountId) => [
    for (final e in _entries)
      if (e.accountId == accountId) e,
  ];

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = _auth.currentUser?.uid;
    return uid == null ? null : _firestore.collection('users').doc(uid);
  }

  void _onAuthChanged(User? user) {
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs.clear();
    _accounts = [];
    _entries = [];
    notifyListeners();
    if (user == null) return;

    final userDoc = _firestore.collection('users').doc(user.uid);
    _subs
      ..add(
        userDoc
            .collection('investAccounts')
            .orderBy('createdAt')
            .snapshots()
            .listen((snap) {
              _accounts = snap.docs.map(InvestAccount.fromDoc).toList();
              notifyListeners();
            }, onError: _ignoreReadError),
      )
      ..add(
        userDoc.collection('investEntries').orderBy('date').snapshots().listen((
          snap,
        ) {
          _entries = snap.docs.map(InvestEntry.fromDoc).toList();
          notifyListeners();
        }, onError: _ignoreReadError),
      );
  }

  /// A refused or failed read (e.g. before the security rules allowing
  /// investments are published) leaves the lists empty instead of
  /// throwing.
  void _ignoreReadError(Object error) {}

  @override
  void dispose() {
    _authSub?.cancel();
    for (final sub in _subs) {
      sub.cancel();
    }
    super.dispose();
  }

  /// Adds an account with what was put in so far and what it's worth now.
  Future<void> addAccount({
    required String name,
    required double putIn,
    required double value,
  }) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    final color = AppPalette
        .categorical[(_accounts.length + 4) % AppPalette.categorical.length];
    final doc = userDoc.collection('investAccounts').doc();
    final now = DateTime.now();
    final batch = _firestore.batch()
      ..set(doc, {
        ...InvestAccount(id: doc.id, name: name, color: color).toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    void entry(InvestEntryKind kind, double amount, DateTime date) =>
        batch.set(userDoc.collection('investEntries').doc(), {
          ...InvestEntry(
            id: '',
            accountId: doc.id,
            kind: kind,
            amount: amount,
            date: date,
          ).toMap(),
          'createdAt': FieldValue.serverTimestamp(),
        });
    // The money put in comes just before the value, so the value counts.
    if (putIn > 0) {
      entry(
        InvestEntryKind.deposit,
        putIn,
        now.subtract(const Duration(seconds: 1)),
      );
    }
    entry(InvestEntryKind.value, value, now);
    await settleWrite(batch.commit());
  }

  Future<void> renameAccount(String id, String name) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await settleWrite(
      userDoc.collection('investAccounts').doc(id).update({'name': name}),
    );
  }

  /// Deletes the account and its history. Expenses and wallet entries its
  /// entries added are kept.
  Future<void> deleteAccount(String id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    final batch = _firestore.batch();
    for (final e in entriesFor(id)) {
      batch.delete(userDoc.collection('investEntries').doc(e.id));
    }
    batch.delete(userDoc.collection('investAccounts').doc(id));
    await settleWrite(batch.commit());
  }

  Future<void> addEntry(InvestEntry entry) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await settleWrite(
      userDoc.collection('investEntries').add({
        ...entry.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      }),
    );
  }

  Future<void> deleteEntry(String id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await settleWrite(userDoc.collection('investEntries').doc(id).delete());
  }
}
