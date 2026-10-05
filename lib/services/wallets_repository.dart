import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monthly_traq/app/palette.dart';
import 'package:monthly_traq/models/wallet_models.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/services/wallet_ledger.dart';

const _writeTimeout = Duration(seconds: 10);

/// The signed-in user's wallets, the people whose money they keep, and
/// everything that happened in the wallets — mirrored live from
/// `users/{uid}/wallets`, `users/{uid}/people` and
/// `users/{uid}/walletEntries`. Separate from transactions: nothing here
/// touches monthly income, spending or budget.
class WalletsRepository extends ChangeNotifier {
  WalletsRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StreamSubscription<User?>? _authSub;
  final _subs = <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];

  List<WalletModel> _wallets = [];
  List<PersonModel> _people = [];
  List<WalletEntry> _entries = [];
  WalletLedger? _ledger;

  List<WalletModel> get wallets => List.unmodifiable(_wallets);

  /// Everyone, in the order they were added.
  List<PersonModel> get people => List.unmodifiable(_people);

  /// Every entry, oldest first.
  List<WalletEntry> get entries => List.unmodifiable(_entries);

  bool get hasWallets => _wallets.isNotEmpty;

  /// Balances and what's owed, worked out once per change.
  WalletLedger get ledger => _ledger ??= WalletLedger.compute(
    wallets: _wallets,
    people: _people,
    entries: _entries,
  );

  WalletModel? walletById(String? id) =>
      id == null ? null : _wallets.where((w) => w.id == id).firstOrNull;

  PersonModel? personById(String? id) =>
      id == null ? null : _people.where((p) => p.id == id).firstOrNull;

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = _auth.currentUser?.uid;
    return uid == null ? null : _firestore.collection('users').doc(uid);
  }

  Future<T> _withTimeout<T>(Future<T> future) => future.timeout(
    _writeTimeout,
    onTimeout: () => throw SyncTimeoutException(),
  );

  void _changed() {
    _ledger = null;
    notifyListeners();
  }

  void _onAuthChanged(User? user) {
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs.clear();
    _wallets = [];
    _people = [];
    _entries = [];
    _changed();
    if (user == null) return;

    final userDoc = _firestore.collection('users').doc(user.uid);
    _subs
      ..add(
        userDoc.collection('wallets').orderBy('createdAt').snapshots().listen((
          snap,
        ) {
          final list = snap.docs.map(WalletModel.fromDoc).toList();
          // Explicitly ordered wallets first, then the rest as created.
          final indexed = list.indexed.toList()
            ..sort((a, b) {
              final ao = a.$2.sortOrder, bo = b.$2.sortOrder;
              if (ao != null && bo != null) return ao.compareTo(bo);
              if (ao != null) return -1;
              if (bo != null) return 1;
              return a.$1.compareTo(b.$1);
            });
          _wallets = [for (final e in indexed) e.$2];
          _changed();
        }, onError: _ignoreReadError),
      )
      ..add(
        userDoc.collection('people').orderBy('createdAt').snapshots().listen((
          snap,
        ) {
          _people = snap.docs.map(PersonModel.fromDoc).toList();
          _changed();
        }, onError: _ignoreReadError),
      )
      ..add(
        userDoc.collection('walletEntries').orderBy('date').snapshots().listen((
          snap,
        ) {
          _entries = snap.docs.map(WalletEntry.fromDoc).toList();
          _changed();
        }, onError: _ignoreReadError),
      );
  }

  /// A refused or failed read (e.g. before the security rules allowing
  /// wallets are published) leaves the lists empty instead of throwing.
  void _ignoreReadError(Object error) {}

  @override
  void dispose() {
    _authSub?.cancel();
    for (final sub in _subs) {
      sub.cancel();
    }
    super.dispose();
  }

  // Wallets

  Future<void> addWallet({
    required String name,
    required IconData icon,
    required double openingBalance,
  }) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    final color =
        AppPalette.categorical[_wallets.length % AppPalette.categorical.length];
    final wallet = WalletModel(
      id: '',
      name: name,
      icon: icon,
      color: color,
      openingBalance: openingBalance,
      sortOrder: DateTime.now().millisecondsSinceEpoch,
    );
    await _withTimeout(
      userDoc.collection('wallets').add({
        ...wallet.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      }),
    );
  }

  Future<void> updateWallet(WalletModel wallet) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _withTimeout(
      userDoc
          .collection('wallets')
          .doc(wallet.id)
          .set(wallet.toMap(), SetOptions(merge: true)),
    );
  }

  /// Deletes the wallet and everything recorded in it (including moves to
  /// or from it).
  Future<void> deleteWallet(String id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    final batch = _firestore.batch();
    for (final e in _entries.where(
      (e) => e.walletId == id || e.toWalletId == id,
    )) {
      batch.delete(userDoc.collection('walletEntries').doc(e.id));
    }
    batch.delete(userDoc.collection('wallets').doc(id));
    await _withTimeout(batch.commit());
  }

  // People

  /// Adds someone and returns their id.
  Future<String?> addPerson(String name) async {
    final userDoc = _userDoc;
    if (userDoc == null) return null;
    final doc = userDoc.collection('people').doc();
    await _withTimeout(
      doc.set({
        ...PersonModel(id: doc.id, name: name).toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      }),
    );
    return doc.id;
  }

  Future<void> renamePerson(String id, String name) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _withTimeout(
      userDoc.collection('people').doc(id).update({'name': name}),
    );
  }

  /// Deletes someone with all their entries, as if none of it happened.
  Future<void> deletePerson(String id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    final batch = _firestore.batch();
    for (final e in _entries.where((e) => e.personId == id)) {
      batch.delete(userDoc.collection('walletEntries').doc(e.id));
    }
    batch.delete(userDoc.collection('people').doc(id));
    await _withTimeout(batch.commit());
  }

  // Entries

  Future<void> addEntry(WalletEntry entry) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _withTimeout(
      userDoc.collection('walletEntries').add({
        ...entry.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      }),
    );
  }

  Future<void> updateEntry(WalletEntry entry) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _withTimeout(
      userDoc
          .collection('walletEntries')
          .doc(entry.id)
          .set(entry.toMap(), SetOptions(merge: true)),
    );
  }

  Future<void> deleteEntry(String id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _withTimeout(userDoc.collection('walletEntries').doc(id).delete());
  }

  /// Records the difference between what the app shows ([current]) and the
  /// wallet's real balance ([actual]). Does nothing when they match.
  Future<void> correctBalance({
    required String walletId,
    required double current,
    required double actual,
  }) async {
    final difference = actual - current;
    if (difference.abs() < 0.005) return;
    await addEntry(
      WalletEntry(
        id: '',
        kind: WalletEntryKind.adjust,
        walletId: walletId,
        amount: difference,
        date: DateTime.now(),
      ),
    );
  }
}
