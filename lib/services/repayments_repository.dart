import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:monthly_traq/models/repayment_models.dart';
import 'package:monthly_traq/services/repayment_schedule.dart';
import 'package:monthly_traq/services/write_sync.dart';

/// The signed-in user's repayments (money they owe and pay back over time)
/// and the payments made on them — mirrored live from
/// `users/{uid}/repayments` and `users/{uid}/repaymentPayments`.
class RepaymentsRepository extends ChangeNotifier {
  RepaymentsRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StreamSubscription<User?>? _authSub;
  final _subs = <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];

  List<RepaymentModel> _repayments = [];
  List<RepaymentPayment> _payments = [];

  /// Every repayment, in the order they were added.
  List<RepaymentModel> get repayments => List.unmodifiable(_repayments);

  /// Every payment, oldest first.
  List<RepaymentPayment> get payments => List.unmodifiable(_payments);

  bool get hasRepayments => _repayments.isNotEmpty;

  RepaymentModel? repaymentById(String? id) =>
      id == null ? null : _repayments.where((r) => r.id == id).firstOrNull;

  RepaymentProgress progressOf(RepaymentModel repayment) =>
      RepaymentProgress.of(repayment, _payments);

  List<RepaymentPayment> paymentsFor(String repaymentId) => [
    for (final p in _payments)
      if (p.repaymentId == repaymentId) p,
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
    _repayments = [];
    _payments = [];
    notifyListeners();
    if (user == null) return;

    final userDoc = _firestore.collection('users').doc(user.uid);
    _subs
      ..add(
        userDoc
            .collection('repayments')
            .orderBy('createdAt')
            .snapshots()
            .listen((snap) {
              _repayments = snap.docs.map(RepaymentModel.fromDoc).toList();
              notifyListeners();
            }, onError: _ignoreReadError),
      )
      ..add(
        userDoc
            .collection('repaymentPayments')
            .orderBy('date')
            .snapshots()
            .listen((snap) {
              _payments = snap.docs.map(RepaymentPayment.fromDoc).toList();
              notifyListeners();
            }, onError: _ignoreReadError),
      );
  }

  /// A refused or failed read (e.g. before the security rules allowing
  /// repayments are published) leaves the lists empty instead of throwing.
  void _ignoreReadError(Object error) {}

  @override
  void dispose() {
    _authSub?.cancel();
    for (final sub in _subs) {
      sub.cancel();
    }
    super.dispose();
  }

  Future<void> addRepayment(RepaymentModel repayment) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await settleWrite(
      userDoc.collection('repayments').add({
        ...repayment.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      }),
    );
  }

  Future<void> updateRepayment(RepaymentModel repayment) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await settleWrite(
      userDoc
          .collection('repayments')
          .doc(repayment.id)
          .set(repayment.toMap(), SetOptions(merge: true)),
    );
  }

  /// Deletes the repayment and its payment history. Expenses and wallet
  /// entries the payments added are kept: that money was really spent.
  Future<void> deleteRepayment(String id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    final batch = _firestore.batch();
    for (final p in paymentsFor(id)) {
      batch.delete(userDoc.collection('repaymentPayments').doc(p.id));
    }
    batch.delete(userDoc.collection('repayments').doc(id));
    await settleWrite(batch.commit());
  }

  /// Records a payment. A full installment (or more) moves the due date on
  /// to the next one; a smaller one leaves it. The repayment also
  /// remembers how it was paid, to start the next payment the same way.
  Future<void> addPayment({
    required RepaymentModel repayment,
    required double amount,
    required DateTime date,
    required PaymentSource source,
    String? transactionId,
    String? walletEntryId,
    String? categoryId,
    String? walletId,
  }) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    final installment = repayment.installment;
    final due = repayment.nextDue;
    final advances =
        repayment.hasSchedule &&
        due != null &&
        installment != null &&
        amount >= installment - 0.005;
    final payment = RepaymentPayment(
      id: '',
      repaymentId: repayment.id,
      amount: amount,
      date: date,
      source: source,
      transactionId: transactionId,
      walletEntryId: walletEntryId,
      advancedFrom: advances ? due : null,
    );
    final batch = _firestore.batch()
      ..set(userDoc.collection('repaymentPayments').doc(), {
        ...payment.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      })
      ..update(userDoc.collection('repayments').doc(repayment.id), {
        if (advances)
          'nextDue': Timestamp.fromDate(nextDueAfter(repayment, due)),
        'paySource': source.name,
        'categoryId': ?categoryId,
        'walletId': ?walletId,
      });
    await settleWrite(batch.commit());
  }

  /// Deletes a payment. If it moved the due date on (and nothing moved it
  /// since), the due date goes back.
  Future<void> deletePayment(RepaymentPayment payment) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    final batch = _firestore.batch()
      ..delete(userDoc.collection('repaymentPayments').doc(payment.id));
    final repayment = repaymentById(payment.repaymentId);
    final from = payment.advancedFrom;
    if (repayment != null &&
        from != null &&
        repayment.nextDue == nextDueAfter(repayment, from)) {
      batch.update(userDoc.collection('repayments').doc(repayment.id), {
        'nextDue': Timestamp.fromDate(from),
      });
    }
    await settleWrite(batch.commit());
  }
}
