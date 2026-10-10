import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monthly_traq/app/palette.dart';
import 'package:monthly_traq/models/goal_models.dart';
import 'package:monthly_traq/services/goal_progress.dart';
import 'package:monthly_traq/services/write_sync.dart';

/// The signed-in user's savings goals and the money added to or taken out
/// of them — mirrored live from `users/{uid}/goals` and
/// `users/{uid}/goalEntries`.
class GoalsRepository extends ChangeNotifier {
  GoalsRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StreamSubscription<User?>? _authSub;
  final _subs = <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];

  List<GoalModel> _goals = [];
  List<GoalEntry> _entries = [];

  /// Every goal, in the order they were added.
  List<GoalModel> get goals => List.unmodifiable(_goals);

  /// Every entry, oldest first.
  List<GoalEntry> get entries => List.unmodifiable(_entries);

  bool get hasGoals => _goals.isNotEmpty;

  GoalModel? goalById(String? id) =>
      id == null ? null : _goals.where((g) => g.id == id).firstOrNull;

  GoalProgress progressOf(GoalModel goal) => GoalProgress.of(goal, _entries);

  List<GoalEntry> entriesFor(String goalId) => [
    for (final e in _entries)
      if (e.goalId == goalId) e,
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
    _goals = [];
    _entries = [];
    notifyListeners();
    if (user == null) return;

    final userDoc = _firestore.collection('users').doc(user.uid);
    _subs
      ..add(
        userDoc.collection('goals').orderBy('createdAt').snapshots().listen((
          snap,
        ) {
          _goals = snap.docs.map(GoalModel.fromDoc).toList();
          notifyListeners();
        }, onError: _ignoreReadError),
      )
      ..add(
        userDoc.collection('goalEntries').orderBy('date').snapshots().listen((
          snap,
        ) {
          _entries = snap.docs.map(GoalEntry.fromDoc).toList();
          notifyListeners();
        }, onError: _ignoreReadError),
      );
  }

  /// A refused or failed read (e.g. before the security rules allowing
  /// goals are published) leaves the lists empty instead of throwing.
  void _ignoreReadError(Object error) {}

  @override
  void dispose() {
    _authSub?.cancel();
    for (final sub in _subs) {
      sub.cancel();
    }
    super.dispose();
  }

  /// The color the next new goal gets.
  Color get nextColor =>
      AppPalette.categorical[_goals.length % AppPalette.categorical.length];

  Future<void> addGoal(GoalModel goal) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await settleWrite(
      userDoc.collection('goals').add({
        ...goal.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      }),
    );
  }

  Future<void> updateGoal(GoalModel goal) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await settleWrite(
      userDoc
          .collection('goals')
          .doc(goal.id)
          .set(goal.toMap(), SetOptions(merge: true)),
    );
  }

  /// Marks a goal done (bought it!), or back to still saving.
  Future<void> setDone(GoalModel goal, bool done) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await settleWrite(
      userDoc.collection('goals').doc(goal.id).update({
        'doneAt': done ? Timestamp.fromDate(DateTime.now()) : null,
      }),
    );
  }

  /// Deletes the goal and its history. Expenses and wallet entries its
  /// entries added are kept.
  Future<void> deleteGoal(String id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    final batch = _firestore.batch();
    for (final e in entriesFor(id)) {
      batch.delete(userDoc.collection('goalEntries').doc(e.id));
    }
    batch.delete(userDoc.collection('goals').doc(id));
    await settleWrite(batch.commit());
  }

  /// Records money added or taken out. Adding also remembers where it came
  /// from on the goal, to start the next time the same way.
  Future<void> addEntry(
    GoalEntry entry, {
    String? categoryId,
    String? walletId,
  }) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    final batch = _firestore.batch()
      ..set(userDoc.collection('goalEntries').doc(), {
        ...entry.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    if (entry.kind == GoalEntryKind.add) {
      batch.update(userDoc.collection('goals').doc(entry.goalId), {
        'addSource': entry.source.name,
        'categoryId': ?categoryId,
        'walletId': ?walletId,
      });
    }
    await settleWrite(batch.commit());
  }

  Future<void> deleteEntry(String id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await settleWrite(userDoc.collection('goalEntries').doc(id).delete());
  }
}
