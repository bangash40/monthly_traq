import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/transaction_model.dart';

// Debug-only demo data. Every sample transaction's document id starts with
// this prefix, which is how [removeSampleData] finds them again without
// touching anything the user entered themselves.
const _samplePrefix = 'sample_';

CollectionReference<Map<String, dynamic>>? _transactionsRef() {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('transactions');
}

/// Writes ~6 months of realistic transactions into the signed-in account,
/// using its existing categories by name. Ids are deterministic per
/// month/slot, so loading twice overwrites rather than duplicates.
/// Returns how many transactions were written.
Future<int> loadSampleData(List<CategoryModel> categories) async {
  final ref = _transactionsRef();
  if (ref == null) return 0;
  await removeSampleData();

  // Older accounts were seeded with a shorter category list (e.g.
  // "Transport", "Bills", "Other"), so each sample category falls back to
  // the closest one that actually exists.
  const fallbacks = {
    'Transportation': ['Transport', 'Car'],
    'Housing': ['Home', 'Bills'],
    'Phone': ['Bills'],
    'Vegetables': ['Food'],
    'Fruits': ['Food'],
    'Snacks': ['Food'],
    'Clothing': ['Shopping'],
    'Electronics': ['Shopping'],
    'Travel': ['Entertainment'],
    'Gifts': ['Social'],
    'Repairs': ['Bills', 'Home'],
    'Part-Time': ['Freelance'],
  };

  String? categoryId(String name, TransactionType type) {
    final candidates = [
      name,
      ...?fallbacks[name],
      if (type == TransactionType.expense) 'Other',
      if (type == TransactionType.income) 'Others',
    ];
    for (final candidate in candidates) {
      for (final c in categories) {
        if (c.name == candidate && c.type == type) return c.id;
      }
    }
    return null;
  }

  final now = DateTime.now();
  final random = Random(42);
  final entries = <String, TransactionModel>{};

  for (var offset = -5; offset <= 0; offset++) {
    final month = DateTime(now.year, now.month + offset);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final lastDay = offset == 0 ? now.day : daysInMonth;
    final monthKey = '${month.year}${month.month.toString().padLeft(2, '0')}';
    var slot = 0;

    void add(
      int day,
      String title,
      double amount,
      String category, {
      TransactionType type = TransactionType.expense,
    }) {
      final index = slot++;
      if (day < 1 || day > lastDay) return;
      var date = DateTime(
        month.year,
        month.month,
        day,
        8 + random.nextInt(13),
        random.nextInt(60),
      );
      if (date.isAfter(now)) date = now.subtract(Duration(minutes: 5 + index));
      final id = '$_samplePrefix${monthKey}_$index';
      entries[id] = TransactionModel(
        id: id,
        title: title,
        amount: amount,
        type: type,
        categoryId: categoryId(category, type),
        date: date,
      );
    }

    int day() => 1 + random.nextInt(lastDay);
    double around(int base, int spread, [int roundTo = 10]) {
      final value = base + random.nextInt(spread * 2 + 1) - spread;
      return ((value / roundTo).round() * roundTo).toDouble();
    }

    // Income.
    add(1, 'Monthly salary', 120000, 'Salary', type: TransactionType.income);
    if (offset.isOdd) {
      add(
        day(),
        'Freelance project',
        around(18000, 6000, 500),
        'Part-Time',
        type: TransactionType.income,
      );
    }
    if (offset == -3) {
      add(15, 'Eid bonus', 30000, 'Bonus', type: TransactionType.income);
    }
    if (offset == -4 || offset == -1) {
      add(
        20,
        'Mutual fund dividend',
        8500,
        'Investments',
        type: TransactionType.income,
      );
    }

    // Fixed monthly costs.
    add(3, 'House rent', 20000, 'Housing');
    add(4, 'Jazz monthly bundle', 1500, 'Phone');
    add(6, 'Netflix', 1100, 'Entertainment');

    // Everyday spending. The current month is lighter so its budget meter
    // lands in the "getting close" range rather than nearly maxed out.
    final isCurrent = offset == 0;
    const groceries = [
      'Groceries at Imtiaz',
      'Carrefour groceries',
      'Al-Fatah groceries',
    ];
    for (var i = 0; i < (isCurrent ? 3 : 4); i++) {
      add(day(), groceries[i % groceries.length], around(3200, 1200), 'Food');
    }
    const meals = [
      'Dinner with friends',
      'Lunch at office cafe',
      'Biryani takeaway',
      'Pizza night',
    ];
    for (var i = 0; i < (isCurrent ? 3 : 4); i++) {
      add(day(), meals[i], around(1500, 700), 'Food');
    }
    const rides = ['Careem ride', 'Fuel', 'Bykea ride', 'Fuel'];
    for (var i = 0; i < (isCurrent ? 4 : 5); i++) {
      add(day(), rides[i % rides.length], around(1100, 600), 'Transportation');
    }
    add(day(), 'Sabzi mandi', around(700, 250), 'Vegetables');
    add(day(), 'Seasonal fruit', around(600, 200), 'Fruits');
    add(day(), 'Chai and snacks', around(350, 120), 'Snacks');
    add(day(), 'Chai and snacks', around(350, 120), 'Snacks');

    // Occasional.
    if (random.nextBool()) add(day(), 'Pharmacy', around(1400, 800), 'Health');
    if (offset != 0 && random.nextBool()) {
      add(day(), 'New shoes', around(4500, 1500, 100), 'Clothing');
    }
    if (!isCurrent && random.nextBool()) {
      add(day(), 'Daraz order', around(2800, 1200, 100), 'Shopping');
    }
    if (!isCurrent && random.nextBool()) {
      add(day(), 'Cinema tickets', around(2200, 500, 100), 'Entertainment');
    }
    if (random.nextBool()) {
      add(day(), 'Friend\'s birthday gift', around(2500, 1000, 100), 'Gifts');
    }

    // One-off bigger purchases, so the trend chart isn't flat.
    if (offset == -3) add(12, 'Wireless headphones', 12500, 'Electronics');
    if (offset == -1) add(18, 'Weekend trip to Murree', 18000, 'Travel');
    if (offset == -2) add(9, 'Online course', 5000, 'Education');
    if (offset == -4) add(22, 'AC service', 3500, 'Repairs');

    // Current month: something on today and yesterday so the day headers
    // show "Today" / "Yesterday".
    if (offset == 0) {
      add(now.day, 'Breakfast', 450, 'Food');
      add(now.day - 1, 'Careem ride', 780, 'Transportation');
    }
  }

  var batch = FirebaseFirestore.instance.batch();
  var inBatch = 0;
  for (final entry in entries.entries) {
    batch.set(ref.doc(entry.key), entry.value.toMap());
    if (++inBatch == 450) {
      await batch.commit();
      batch = FirebaseFirestore.instance.batch();
      inBatch = 0;
    }
  }
  if (inBatch > 0) await batch.commit();
  return entries.length;
}

/// Deletes every sample transaction, leaving the user's own ones alone.
/// Returns how many were removed.
Future<int> removeSampleData() async {
  final ref = _transactionsRef();
  if (ref == null) return 0;
  final snap = await ref.get();
  final samples = snap.docs.where((d) => d.id.startsWith(_samplePrefix));

  var batch = FirebaseFirestore.instance.batch();
  var inBatch = 0;
  var removed = 0;
  for (final doc in samples) {
    batch.delete(doc.reference);
    removed++;
    if (++inBatch == 450) {
      await batch.commit();
      batch = FirebaseFirestore.instance.batch();
      inBatch = 0;
    }
  }
  if (inBatch > 0) await batch.commit();
  return removed;
}
