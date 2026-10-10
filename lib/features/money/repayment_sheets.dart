import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/app_settings.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/money/money_common.dart';
import 'package:monthly_traq/models/repayment_models.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/models/wallet_models.dart';
import 'package:monthly_traq/services/repayments_repository.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/services/wallets_repository.dart';
import 'package:monthly_traq/widgets/ui.dart';
import 'package:monthly_traq/l10n/l10n.dart';

// Repayment: add / edit / delete

Future<void> showRepaymentEditor(
  BuildContext context, {
  RepaymentModel? existing,
}) => showMoneySheet<void>(
  context,
  _RepaymentEditor(existing: existing),
  guarded: true,
);

class _RepaymentEditor extends StatefulWidget {
  final RepaymentModel? existing;

  const _RepaymentEditor({this.existing});

  @override
  State<_RepaymentEditor> createState() => _RepaymentEditorState();
}

class _RepaymentEditorState extends State<_RepaymentEditor> {
  late final RepaymentModel? _e = widget.existing;
  late final _name = TextEditingController(text: _e?.name);
  late final _lender = TextEditingController(text: _e?.lender);
  late final _total = TextEditingController(
    text: _e == null ? '' : plainAmount(_e.total),
  );
  late final _paidBefore = TextEditingController(
    text: _e == null || _e.paidBefore == 0 ? '' : plainAmount(_e.paidBefore),
  );
  late final _installment = TextEditingController(
    text: _e?.installment == null ? '' : plainAmount(_e!.installment!),
  );
  late RepaymentFrequency _frequency =
      _e?.frequency ?? RepaymentFrequency.monthly;
  late int _everyMonths = _e == null || _e.everyMonths < 2 ? 3 : _e.everyMonths;
  late DateTime? _nextDue = _e?.nextDue;

  String? _nameError;
  String? _totalError;
  String? _paidBeforeError;
  String? _installmentError;
  String? _dueError;
  bool _saving = false;

  late final _initial = (
    name: _name.text,
    lender: _lender.text,
    total: _total.text,
    paidBefore: _paidBefore.text,
    installment: _installment.text,
    frequency: _frequency,
    everyMonths: _everyMonths,
    nextDue: _nextDue,
  );

  bool get _isEditing => _e != null;
  bool get _scheduled => _frequency != RepaymentFrequency.none;

  @override
  void initState() {
    super.initState();
    _initial; // Record the starting point now, before anything changes.
  }

  bool _isDirty() =>
      _name.text != _initial.name ||
      _lender.text != _initial.lender ||
      _total.text != _initial.total ||
      _paidBefore.text != _initial.paidBefore ||
      _installment.text != _initial.installment ||
      _frequency != _initial.frequency ||
      _everyMonths != _initial.everyMonths ||
      _nextDue != _initial.nextDue;

  @override
  void dispose() {
    _name.dispose();
    _lender.dispose();
    _total.dispose();
    _paidBefore.dispose();
    _installment.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final now = DateTime.now();
    final initial = _nextDue ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
      helpText: context.l10n.nextPaymentDue,
    );
    if (picked != null) {
      setState(() {
        _nextDue = picked;
        _dueError = null;
      });
    }
  }

  Future<void> _save() async {
    final money = context.moneyNow;
    final name = _name.text.trim();
    final lender = _lender.text.trim();
    final total = parseAmount(_total.text);
    final paidBefore = _paidBefore.text.trim().isEmpty
        ? 0.0
        : parseAmount(_paidBefore.text);
    final installment = parseAmount(_installment.text);
    final l10n = context.l10n;
    setState(() {
      _nameError = name.isEmpty ? l10n.giveItName : null;
      _totalError = total == null || total <= 0 ? l10n.enterTotalOwed : null;
      _paidBeforeError = paidBefore == null || paidBefore < 0
          ? l10n.amountOrEmpty
          : total != null && paidBefore > total
          ? l10n.moreThanTotal(money.format(total))
          : null;
      _installmentError =
          _scheduled && (installment == null || installment <= 0)
          ? l10n.enterEachPayment
          : null;
      _dueError = _scheduled && _nextDue == null ? l10n.pickNextDue : null;
    });
    if (_nameError != null ||
        _totalError != null ||
        _paidBeforeError != null ||
        _installmentError != null ||
        _dueError != null) {
      return;
    }

    final repo = context.read<RepaymentsRepository>();
    final sameName = repo.repayments.any(
      (r) =>
          r.id != _e?.id && r.name.trim().toLowerCase() == name.toLowerCase(),
    );
    if (sameName) {
      final proceed = await confirmDialog(
        context,
        title: l10n.youAlreadyHave(name),
        message: l10n.sameRepaymentNameBody,
        confirmLabel: l10n.saveAnyway,
        cancelLabel: l10n.goBack,
      );
      if (proceed != true || !mounted) return;
    }

    setState(() => _saving = true);
    final repayment = RepaymentModel(
      id: _e?.id ?? '',
      name: name,
      lender: lender.isEmpty ? null : lender,
      total: total!,
      paidBefore: paidBefore!,
      frequency: _frequency,
      everyMonths: _frequency == RepaymentFrequency.everyMonths
          ? _everyMonths
          : 1,
      installment: _scheduled ? installment : null,
      nextDue: _scheduled ? _nextDue : null,
      anchorDay: _scheduled ? _nextDue!.day : null,
      paySource: _e?.paySource ?? PaymentSource.budget,
      categoryId: _e?.categoryId,
      walletId: _e?.walletId,
    );
    try {
      if (_isEditing) {
        await repo.updateRepayment(repayment);
      } else {
        await repo.addRepayment(repayment);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      toastSaveError(context, e);
    }
  }

  Future<void> _delete() async {
    final existing = _e!;
    final confirmed = await confirmDialog(
      context,
      title: context.l10n.deleteNamed(existing.name),
      message: context.l10n.deleteRepaymentBody,
      confirmLabel: context.l10n.delete,
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    final navigator = Navigator.of(context);
    try {
      await context.read<RepaymentsRepository>().deleteRepayment(existing.id);
      navigator.pop();
    } catch (e) {
      if (mounted) toastSaveError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MoneySheet(
      title: _isEditing
          ? context.l10n.editRepayment
          : context.l10n.newRepayment,
      subtitle: _isEditing ? null : context.l10n.newRepaymentHelp,
      isDirty: _isDirty,
      trailing: _isEditing
          ? IconButton(
              tooltip: context.l10n.deleteRepayment,
              onPressed: _delete,
              icon: Icon(Icons.delete_outline, color: c.spending),
            )
          : null,
      button: ElevatedButton(
        onPressed: _saving ? null : _save,
        child: ButtonLabel(
          _isEditing
              ? context.l10n.saveChanges
              : context.l10n.addRepaymentButton,
          loading: _saving,
        ),
      ),
      children: [
        LabeledField(
          label: context.l10n.name,
          field: TextField(
            controller: _name,
            autofocus: !_isEditing,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 60,
            decoration: InputDecoration(
              hintText: context.l10n.repaymentNameHint,
              errorText: _nameError,
              counterText: '',
            ),
          ),
        ),
        const SizedBox(height: 16),
        LabeledField(
          label: context.l10n.lenderOptional,
          field: TextField(
            controller: _lender,
            textCapitalization: TextCapitalization.words,
            maxLength: 60,
            decoration: InputDecoration(
              hintText: context.l10n.lenderHint,
              counterText: '',
            ),
          ),
        ),
        const SizedBox(height: 16),
        LabeledField(
          label: context.l10n.totalYouOwe,
          field: AmountField(controller: _total, errorText: _totalError),
        ),
        const SizedBox(height: 16),
        LabeledField(
          label: context.l10n.alreadyPaidOptional,
          field: AmountField(
            controller: _paidBefore,
            errorText: _paidBeforeError,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.alreadyPaidHelp,
          style: AppText.label.copyWith(color: c.muted),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.howOften,
          style: AppText.rowTitle.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        ChoicePills<RepaymentFrequency>(
          options: [
            for (final f in RepaymentFrequency.values)
              (f, f.label(context.l10n)),
          ],
          value: _frequency,
          onChanged: (f) => setState(() => _frequency = f),
        ),
        if (_frequency == RepaymentFrequency.everyMonths) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.everyNMonths(_everyMonths),
                  style: AppText.rowTitle.copyWith(fontSize: 16),
                ),
              ),
              IconButton.filledTonal(
                tooltip: context.l10n.fewerMonths,
                onPressed: _everyMonths > 2
                    ? () => setState(() => _everyMonths--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: context.l10n.moreMonths,
                onPressed: _everyMonths < 24
                    ? () => setState(() => _everyMonths++)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
        if (_scheduled) ...[
          const SizedBox(height: 16),
          LabeledField(
            label: context.l10n.eachPayment,
            field: AmountField(
              controller: _installment,
              errorText: _installmentError,
            ),
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: context.l10n.nextPaymentDue,
            field: FieldButton(
              leading: Icon(Icons.event_outlined, color: c.muted),
              label: _nextDue == null
                  ? context.l10n.pickDate
                  : friendlyDate(context.l10n, _nextDue!),
              empty: _nextDue == null,
              error: _dueError,
              onTap: _pickDue,
            ),
          ),
        ] else ...[
          const SizedBox(height: 10),
          Text(
            context.l10n.noScheduleHelp,
            style: AppText.label.copyWith(color: c.muted),
          ),
        ],
      ],
    );
  }
}

// Paying an installment

Future<void> showPaySheet(BuildContext context, RepaymentModel repayment) =>
    showMoneySheet<void>(
      context,
      _PaySheet(repayment: repayment),
      guarded: true,
    );

class _PaySheet extends StatefulWidget {
  final RepaymentModel repayment;

  const _PaySheet({required this.repayment});

  @override
  State<_PaySheet> createState() => _PaySheetState();
}

class _PaySheetState extends State<_PaySheet> {
  late final TextEditingController _amount;
  late PaymentSource _source;
  String? _categoryId;
  String? _walletId;
  DateTime _date = DateTime.now();

  String? _amountError;
  String? _categoryError;
  String? _walletError;
  bool _saving = false;

  late final String _initialAmount;

  RepaymentModel get _r => widget.repayment;

  @override
  void initState() {
    super.initState();
    final repo = context.read<RepaymentsRepository>();
    final txRepo = context.read<TransactionsRepository>();
    final wallets = context.read<WalletsRepository>();
    final remaining = repo.progressOf(_r).remaining;
    final installment = _r.installment;
    final suggested = installment == null
        ? null
        : (installment < remaining ? installment : remaining);
    _amount = TextEditingController(
      text: suggested == null ? '' : plainAmount(suggested),
    );
    _initialAmount = _amount.text;

    _source = _r.paySource;
    if (_source == PaymentSource.wallet && !wallets.hasWallets) {
      _source = PaymentSource.budget;
    }
    _categoryId = txRepo.categoryById(_r.categoryId)?.id;
    final lastWallet = context.read<AppSettings>().lastWalletId;
    _walletId =
        wallets.walletById(_r.walletId)?.id ??
        wallets.walletById(lastWallet)?.id ??
        (wallets.wallets.length == 1 ? wallets.wallets.single.id : null);
  }

  bool _isDirty() =>
      _amount.text != _initialAmount ||
      !DateUtils.isSameDay(_date, DateTime.now());

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) {
      setState(
        () => _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _date.hour,
          _date.minute,
        ),
      );
    }
  }

  Future<void> _pickCategory() async {
    final picked = await pickExpenseCategory(context, selectedId: _categoryId);
    if (picked != null) {
      setState(() {
        _categoryId = picked;
        _categoryError = null;
      });
    }
  }

  Future<void> _save() async {
    final money = context.moneyNow;
    final repo = context.read<RepaymentsRepository>();
    final txRepo = context.read<TransactionsRepository>();
    final walletsRepo = context.read<WalletsRepository>();
    final remaining = repo.progressOf(_r).remaining;
    final amount = parseAmount(_amount.text);
    final l10n = context.l10n;
    setState(() {
      _amountError = amount == null || amount <= 0
          ? l10n.amountAboveZero
          : amount > remaining + 0.005
          ? l10n.onlyLeftToPay(money.format(remaining))
          : null;
      _categoryError = _source == PaymentSource.budget && _categoryId == null
          ? l10n.pickExpenseCategory
          : null;
      _walletError = _source == PaymentSource.wallet && _walletId == null
          ? l10n.pickWallet
          : null;
    });
    if (_amountError != null ||
        _categoryError != null ||
        _walletError != null) {
      return;
    }

    if (_source == PaymentSource.wallet) {
      final balance = walletsRepo.ledger.of(_walletId!).total;
      if (amount! > balance + 0.005) {
        final name = walletsRepo.walletById(_walletId)?.name ?? l10n.thisWallet;
        final proceed = await confirmDialog(
          context,
          title: l10n.moreThanWalletHas(name),
          message: l10n.moreThanWalletBody(
            name,
            signedMoney(money, balance),
            signedMoney(money, balance - amount),
          ),
          confirmLabel: l10n.saveAnyway,
          cancelLabel: l10n.goBack,
        );
        if (proceed != true || !mounted) return;
      }
    }

    setState(() => _saving = true);
    try {
      String? transactionId;
      String? walletEntryId;
      switch (_source) {
        case PaymentSource.budget:
          transactionId = await txRepo.addTransaction(
            TransactionModel(
              id: '',
              title: _r.name,
              amount: amount!,
              type: TransactionType.expense,
              categoryId: _categoryId,
              date: _date,
            ),
          );
        case PaymentSource.wallet:
          walletEntryId = await walletsRepo.addEntry(
            WalletEntry(
              id: '',
              kind: WalletEntryKind.spend,
              walletId: _walletId!,
              amount: amount!,
              date: _date,
              note: _r.name,
            ),
          );
        case PaymentSource.none:
          break;
      }
      await repo.addPayment(
        repayment: _r,
        amount: amount!,
        date: _date,
        source: _source,
        transactionId: transactionId,
        walletEntryId: walletEntryId,
        categoryId: _source == PaymentSource.budget ? _categoryId : null,
        walletId: _source == PaymentSource.wallet ? _walletId : null,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      toastSaveError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final repo = context.watch<RepaymentsRepository>();
    final txRepo = context.watch<TransactionsRepository>();
    final wallets = context.watch<WalletsRepository>();
    final remaining = repo.progressOf(_r).remaining;
    final category = txRepo.categoryById(_categoryId);
    final wallet = wallets.walletById(_walletId);
    final due = _r.nextDue;

    return MoneySheet(
      title: context.l10n.payNamed(_r.name),
      subtitle: [
        context.l10n.leftToPaySentence(money.format(remaining)),
        if (_r.hasSchedule && due != null)
          context.l10n.nextDueSentence(DateFormat('d MMM').format(due)),
      ].join(' '),
      isDirty: _isDirty,
      button: ElevatedButton(
        onPressed: _saving ? null : _save,
        child: ButtonLabel(context.l10n.savePayment, loading: _saving),
      ),
      children: [
        LabeledField(
          label: context.l10n.amount,
          field: AmountField(
            controller: _amount,
            errorText: _amountError,
            autofocus: _amount.text.isEmpty,
          ),
        ),
        if (_r.installment != null) ...[
          const SizedBox(height: 6),
          Text(
            context.l10n.fullPaymentHelp(money.format(_r.installment!)),
            style: AppText.label.copyWith(color: c.muted),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          context.l10n.paidFrom,
          style: AppText.rowTitle.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        ChoicePills<PaymentSource>(
          options: [
            (PaymentSource.budget, context.l10n.monthlyMoney),
            if (wallets.hasWallets)
              (PaymentSource.wallet, context.l10n.aWalletOption),
            (PaymentSource.none, context.l10n.justRecordIt),
          ],
          value: _source,
          onChanged: (s) => setState(() => _source = s),
        ),
        const SizedBox(height: 12),
        switch (_source) {
          PaymentSource.budget => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FieldButton(
                leading: category != null
                    ? IconTile(
                        icon: category.icon,
                        color: category.color,
                        size: 36,
                      )
                    : Icon(Icons.category_outlined, color: c.muted),
                label: category?.name ?? context.l10n.chooseCategory,
                empty: category == null,
                error: _categoryError,
                onTap: _pickCategory,
              ),
              const SizedBox(height: 6),
              Text(
                category == null
                    ? context.l10n.addsExpenseHere
                    : category.excludeFromBudget
                    ? context.l10n.addsExpenseNotCounted(category.name)
                    : context.l10n.addsExpenseCounted(category.name),
                style: AppText.label.copyWith(color: c.muted),
              ),
            ],
          ),
          PaymentSource.wallet => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FieldButton(
                leading: wallet != null
                    ? IconTile(icon: wallet.icon, color: wallet.color, size: 36)
                    : Icon(
                        Icons.account_balance_wallet_outlined,
                        color: c.muted,
                      ),
                label: wallet?.name ?? context.l10n.chooseWallet,
                empty: wallet == null,
                error: _walletError,
                onTap: () async {
                  final choice = await pickWallet(
                    context,
                    selectedId: _walletId,
                    title: context.l10n.paidFrom,
                  );
                  if (choice?.walletId != null) {
                    setState(() {
                      _walletId = choice!.walletId;
                      _walletError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.addsSpentEntry,
                style: AppText.label.copyWith(color: c.muted),
              ),
            ],
          ),
          PaymentSource.none => Text(
            context.l10n.onlyUpdatesRepayment,
            style: AppText.label.copyWith(color: c.muted),
          ),
        },
        const SizedBox(height: 16),
        LabeledField(
          label: context.l10n.date,
          field: FieldButton(
            leading: Icon(Icons.calendar_today_outlined, color: c.muted),
            label: friendlyDate(context.l10n, _date),
            onTap: _pickDate,
          ),
        ),
      ],
    );
  }
}

/// Deletes a payment after asking, along with the expense or wallet entry
/// it added.
Future<void> confirmDeletePayment(
  BuildContext context,
  RepaymentPayment payment,
) async {
  final money = context.moneyNow;
  final l10n = context.l10n;
  final repo = context.read<RepaymentsRepository>();
  final txRepo = context.read<TransactionsRepository>();
  final walletsRepo = context.read<WalletsRepository>();
  final linkedTx =
      payment.transactionId != null &&
      txRepo.transactions.any((t) => t.id == payment.transactionId);
  final linkedEntry = walletsRepo.entries
      .where((e) => e.id == payment.walletEntryId)
      .firstOrNull;
  final from = payment.advancedFrom;
  final repayment = repo.repaymentById(payment.repaymentId);
  final movesBack =
      from != null && repayment?.nextDue != null && repayment!.nextDue != from;

  final confirmed = await confirmDialog(
    context,
    title: l10n.deletePaymentTitle,
    message: [
      l10n.paymentGoesBack(money.format(payment.amount)),
      if (linkedTx) l10n.expenseDeletedToo,
      if (linkedEntry != null)
        l10n.spentEntryDeletedToo(
          walletsRepo.walletById(linkedEntry.walletId)?.name ?? l10n.theWallet,
        ),
      if (movesBack) l10n.dueDateGoesBack(DateFormat('d MMM').format(from)),
    ].join(' '),
    confirmLabel: l10n.delete,
    destructive: true,
  );
  if (confirmed != true) return;
  try {
    await repo.deletePayment(payment);
    if (linkedTx) await txRepo.deleteTransaction(payment.transactionId!);
    if (linkedEntry != null) await walletsRepo.deleteEntry(linkedEntry.id);
  } catch (e) {
    if (context.mounted) toastSaveError(context, e);
  }
}
