import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monthly_traq/l10n/app_localizations.dart';

/// How often a repayment is due.
enum RepaymentFrequency {
  daily,
  monthly,
  everyMonths,
  yearly,
  none;

  String label(AppLocalizations l10n) => switch (this) {
    daily => l10n.frequencyDaily,
    monthly => l10n.frequencyMonthly,
    everyMonths => l10n.frequencyEveryMonths,
    yearly => l10n.frequencyYearly,
    none => l10n.frequencyNone,
  };

  static RepaymentFrequency byName(String? name) =>
      values.where((f) => f.name == name).firstOrNull ?? none;
}

/// Where a payment's money came from.
enum PaymentSource {
  /// The monthly money: the payment also added an expense transaction.
  budget,

  /// A wallet: the payment also added a "Spent" entry there.
  wallet,

  /// Only recorded against the repayment.
  none;

  static PaymentSource byName(String? name) =>
      values.where((s) => s.name == name).firstOrNull ?? none;
}

/// Money the person owes and pays back over time: an installment, a loan, a
/// qisht. What's been paid is [paidBefore] plus its [RepaymentPayment]s.
class RepaymentModel {
  final String id;
  final String name;

  /// Who it's owed to, if they said.
  final String? lender;
  final double total;

  /// Paid before it was added to the app.
  final double paidBefore;
  final RepaymentFrequency frequency;

  /// For [RepaymentFrequency.everyMonths]: how many months apart.
  final int everyMonths;

  /// The usual payment; null for [RepaymentFrequency.none].
  final double? installment;

  /// When the next payment is due; null for [RepaymentFrequency.none].
  final DateTime? nextDue;

  /// The day of the month payments fall on, so a 31st stays the 31st (or
  /// the month's last day) instead of drifting to the 28th after February.
  final int? anchorDay;

  /// How the last payment was made, to start the next one the same way.
  final PaymentSource paySource;
  final String? categoryId;
  final String? walletId;

  const RepaymentModel({
    required this.id,
    required this.name,
    this.lender,
    required this.total,
    this.paidBefore = 0,
    required this.frequency,
    this.everyMonths = 1,
    this.installment,
    this.nextDue,
    this.anchorDay,
    this.paySource = PaymentSource.budget,
    this.categoryId,
    this.walletId,
  });

  bool get hasSchedule =>
      frequency != RepaymentFrequency.none && nextDue != null;

  factory RepaymentModel.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return RepaymentModel(
      id: doc.id,
      name: data['name'] as String,
      lender: data['lender'] as String?,
      total: (data['total'] as num).toDouble(),
      paidBefore: (data['paidBefore'] as num? ?? 0).toDouble(),
      frequency: RepaymentFrequency.byName(data['frequency'] as String?),
      everyMonths: data['everyMonths'] as int? ?? 1,
      installment: (data['installment'] as num?)?.toDouble(),
      nextDue: (data['nextDue'] as Timestamp?)?.toDate(),
      anchorDay: data['anchorDay'] as int?,
      paySource: PaymentSource.byName(data['paySource'] as String?),
      categoryId: data['categoryId'] as String?,
      walletId: data['walletId'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'lender': lender,
    'total': total,
    'paidBefore': paidBefore,
    'frequency': frequency.name,
    'everyMonths': everyMonths,
    'installment': installment,
    'nextDue': nextDue == null ? null : Timestamp.fromDate(nextDue!),
    'anchorDay': anchorDay,
    'paySource': paySource.name,
    'categoryId': categoryId,
    'walletId': walletId,
  };

  RepaymentModel copyWith({
    DateTime? nextDue,
    PaymentSource? paySource,
    String? categoryId,
    String? walletId,
  }) => RepaymentModel(
    id: id,
    name: name,
    lender: lender,
    total: total,
    paidBefore: paidBefore,
    frequency: frequency,
    everyMonths: everyMonths,
    installment: installment,
    nextDue: nextDue ?? this.nextDue,
    anchorDay: anchorDay,
    paySource: paySource ?? this.paySource,
    categoryId: categoryId ?? this.categoryId,
    walletId: walletId ?? this.walletId,
  );
}

/// One payment towards a repayment.
class RepaymentPayment {
  final String id;
  final String repaymentId;
  final double amount;
  final DateTime date;
  final PaymentSource source;

  /// The expense transaction it added (for [PaymentSource.budget]).
  final String? transactionId;

  /// The wallet "Spent" entry it added (for [PaymentSource.wallet]).
  final String? walletEntryId;

  /// The due date before this payment moved it on; null if it didn't (a
  /// partial payment, or no schedule). Deleting the payment moves it back.
  final DateTime? advancedFrom;

  const RepaymentPayment({
    required this.id,
    required this.repaymentId,
    required this.amount,
    required this.date,
    required this.source,
    this.transactionId,
    this.walletEntryId,
    this.advancedFrom,
  });

  factory RepaymentPayment.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return RepaymentPayment(
      id: doc.id,
      repaymentId: data['repaymentId'] as String,
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      source: PaymentSource.byName(data['source'] as String?),
      transactionId: data['transactionId'] as String?,
      walletEntryId: data['walletEntryId'] as String?,
      advancedFrom: (data['advancedFrom'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'repaymentId': repaymentId,
    'amount': amount,
    'date': Timestamp.fromDate(date),
    'source': source.name,
    'transactionId': transactionId,
    'walletEntryId': walletEntryId,
    'advancedFrom': advancedFrom == null
        ? null
        : Timestamp.fromDate(advancedFrom!),
  };
}
