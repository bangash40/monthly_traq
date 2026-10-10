import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/app_settings.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/money/money_common.dart';
import 'package:monthly_traq/models/investment_models.dart';
import 'package:monthly_traq/models/repayment_models.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/models/wallet_models.dart';
import 'package:monthly_traq/services/investments_repository.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/services/wallets_repository.dart';
import 'package:monthly_traq/widgets/ui.dart';

Future<void> _pickDateInto(
  BuildContext context,
  DateTime current,
  ValueChanged<DateTime> onPicked,
) async {
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: current,
    firstDate: DateTime(now.year - 10),
    lastDate: now,
  );
  if (picked != null) {
    onPicked(
      DateTime(
        picked.year,
        picked.month,
        picked.day,
        current.hour,
        current.minute,
      ),
    );
  }
}

// Account: add / rename / delete

Future<void> showInvestAccountEditor(
  BuildContext context, {
  InvestAccount? existing,
}) => showMoneySheet<void>(
  context,
  _AccountEditor(existing: existing),
  guarded: true,
);

class _AccountEditor extends StatefulWidget {
  final InvestAccount? existing;

  const _AccountEditor({this.existing});

  @override
  State<_AccountEditor> createState() => _AccountEditorState();
}

class _AccountEditorState extends State<_AccountEditor> {
  late final _name = TextEditingController(text: widget.existing?.name);
  final _putIn = TextEditingController();
  final _value = TextEditingController();
  String? _nameError;
  String? _putInError;
  String? _valueError;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  bool _isDirty() =>
      _name.text != (widget.existing?.name ?? '') ||
      _putIn.text.isNotEmpty ||
      _value.text.isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    _putIn.dispose();
    _value.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final putIn = _putIn.text.trim().isEmpty ? 0.0 : parseAmount(_putIn.text);
    final value = parseAmount(_value.text);
    setState(() {
      _nameError = name.isEmpty ? 'Name the account' : null;
      if (!_isEditing) {
        _putInError = putIn == null || putIn < 0
            ? 'Enter an amount, or leave it empty'
            : null;
        _valueError = value == null || value < 0
            ? 'Enter what it\'s worth now'
            : null;
      }
    });
    if (_nameError != null || _putInError != null || _valueError != null) {
      return;
    }

    final repo = context.read<InvestmentsRepository>();
    final sameName = repo.accounts.any(
      (a) =>
          a.id != widget.existing?.id &&
          a.name.trim().toLowerCase() == name.toLowerCase(),
    );
    if (sameName) {
      final proceed = await confirmDialog(
        context,
        title: 'You already have $name',
        message:
            'Two accounts with the same name are easy to mix up. Save anyway?',
        confirmLabel: 'Save anyway',
        cancelLabel: 'Go back',
      );
      if (proceed != true || !mounted) return;
    }

    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await repo.renameAccount(widget.existing!.id, name);
      } else {
        await repo.addAccount(name: name, putIn: putIn!, value: value!);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      toastSaveError(context, e);
    }
  }

  Future<void> _delete() async {
    final existing = widget.existing!;
    final confirmed = await confirmDialog(
      context,
      title: 'Delete ${existing.name}?',
      message:
          'Its history is deleted. Expenses, income and wallet entries it '
          'added are kept.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    final navigator = Navigator.of(context);
    try {
      await context.read<InvestmentsRepository>().deleteAccount(existing.id);
      navigator.pop();
    } catch (e) {
      if (mounted) toastSaveError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MoneySheet(
      title: _isEditing ? 'Edit account' : 'New account',
      subtitle: _isEditing
          ? null
          : 'A broker account you invest through. Copy the numbers from '
                'your broker\'s app.',
      isDirty: _isDirty,
      trailing: _isEditing
          ? IconButton(
              tooltip: 'Delete account',
              onPressed: _delete,
              icon: Icon(Icons.delete_outline, color: c.spending),
            )
          : null,
      button: ElevatedButton(
        onPressed: _saving ? null : _save,
        child: ButtonLabel(
          _isEditing ? 'Save changes' : 'Add account',
          loading: _saving,
        ),
      ),
      children: [
        LabeledField(
          label: 'Name',
          field: TextField(
            controller: _name,
            autofocus: !_isEditing,
            textCapitalization: TextCapitalization.words,
            maxLength: 40,
            decoration: InputDecoration(
              hintText: 'e.g. AKD Trade',
              errorText: _nameError,
              counterText: '',
            ),
          ),
        ),
        if (!_isEditing) ...[
          const SizedBox(height: 16),
          LabeledField(
            label: 'Money you\'ve put in so far',
            field: AmountField(controller: _putIn, errorText: _putInError),
          ),
          const SizedBox(height: 6),
          Text(
            'Everything you deposited, minus anything you took out.',
            style: AppText.label.copyWith(color: c.muted),
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: 'What it\'s worth now',
            field: AmountField(controller: _value, errorText: _valueError),
          ),
          const SizedBox(height: 6),
          Text(
            'Shares plus cash, as your broker\'s app shows it.',
            style: AppText.label.copyWith(color: c.muted),
          ),
        ],
      ],
    );
  }
}

// Updating the value

Future<void> showUpdateValueSheet(
  BuildContext context,
  InvestAccount account,
) => showMoneySheet<void>(
  context,
  _UpdateValueSheet(account: account),
  guarded: true,
);

class _UpdateValueSheet extends StatefulWidget {
  final InvestAccount account;

  const _UpdateValueSheet({required this.account});

  @override
  State<_UpdateValueSheet> createState() => _UpdateValueSheetState();
}

class _UpdateValueSheetState extends State<_UpdateValueSheet> {
  late final TextEditingController _value;
  late final String _initial;
  DateTime _date = DateTime.now();
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<InvestmentsRepository>().progressOf(widget.account);
    _value = TextEditingController(text: plainAmount(p.value));
    _initial = _value.text;
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = parseAmount(_value.text);
    setState(
      () => _error = value == null || value < 0
          ? 'Enter what it\'s worth now'
          : null,
    );
    if (_error != null) return;
    setState(() => _saving = true);
    try {
      await context.read<InvestmentsRepository>().addEntry(
        InvestEntry(
          id: '',
          accountId: widget.account.id,
          kind: InvestEntryKind.value,
          amount: value!,
          date: _date,
        ),
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
    return MoneySheet(
      title: 'Update ${widget.account.name}',
      subtitle:
          'Copy the total value — shares plus cash — from your broker\'s app.',
      isDirty: () =>
          _value.text != _initial ||
          !DateUtils.isSameDay(_date, DateTime.now()),
      button: ElevatedButton(
        onPressed: _saving ? null : _save,
        child: ButtonLabel('Save value', loading: _saving),
      ),
      children: [
        LabeledField(
          label: 'Worth now',
          field: AmountField(
            controller: _value,
            errorText: _error,
            autofocus: true,
          ),
        ),
        const SizedBox(height: 16),
        LabeledField(
          label: 'Date',
          field: FieldButton(
            leading: Icon(Icons.calendar_today_outlined, color: c.muted),
            label: friendlyDate(_date),
            onTap: () =>
                _pickDateInto(context, _date, (d) => setState(() => _date = d)),
          ),
        ),
      ],
    );
  }
}

// Putting money in, taking it out, dividends

Future<void> showInvestMoneySheet(
  BuildContext context,
  InvestAccount account,
  InvestEntryKind kind,
) => showMoneySheet<void>(
  context,
  _MoneySheet(account: account, kind: kind),
  guarded: true,
);

class _MoneySheet extends StatefulWidget {
  final InvestAccount account;
  final InvestEntryKind kind;

  const _MoneySheet({required this.account, required this.kind});

  @override
  State<_MoneySheet> createState() => _MoneySheetState();
}

class _MoneySheetState extends State<_MoneySheet> {
  final _amount = TextEditingController();
  PaymentSource _source = PaymentSource.budget;
  String? _categoryId;
  String? _walletId;
  DateTime _date = DateTime.now();
  String? _amountError;
  String? _categoryError;
  String? _walletError;
  bool _saving = false;

  InvestAccount get _a => widget.account;
  bool get _depositing => widget.kind == InvestEntryKind.deposit;

  /// The transaction a "monthly money" entry adds: an expense when putting
  /// money in, income when it comes out.
  TransactionType get _txType =>
      _depositing ? TransactionType.expense : TransactionType.income;

  @override
  void initState() {
    super.initState();
    final txRepo = context.read<TransactionsRepository>();
    final wallets = context.read<WalletsRepository>();
    // Money coming out most likely lands in "Investments" income.
    if (!_depositing) {
      _categoryId = txRepo.categories
          .where(
            (cat) =>
                cat.type == TransactionType.income &&
                cat.name.toLowerCase().contains('invest'),
          )
          .firstOrNull
          ?.id;
    }
    final lastWallet = context.read<AppSettings>().lastWalletId;
    _walletId =
        wallets.walletById(lastWallet)?.id ??
        (wallets.wallets.length == 1 ? wallets.wallets.single.id : null);
  }

  bool _isDirty() =>
      _amount.text.isNotEmpty || !DateUtils.isSameDay(_date, DateTime.now());

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final money = context.moneyNow;
    final repo = context.read<InvestmentsRepository>();
    final txRepo = context.read<TransactionsRepository>();
    final walletsRepo = context.read<WalletsRepository>();
    final value = repo.progressOf(_a).value;
    final amount = parseAmount(_amount.text);
    setState(() {
      _amountError = amount == null || amount <= 0
          ? 'Enter an amount above zero'
          : widget.kind == InvestEntryKind.withdraw && amount > value + 0.005
          ? '${_a.name} is worth ${money.format(value)}'
          : null;
      _categoryError = _source == PaymentSource.budget && _categoryId == null
          ? 'Pick a category'
          : null;
      _walletError = _source == PaymentSource.wallet && _walletId == null
          ? 'Pick a wallet'
          : null;
    });
    if (_amountError != null ||
        _categoryError != null ||
        _walletError != null) {
      return;
    }

    if (_depositing && _source == PaymentSource.wallet) {
      final balance = walletsRepo.ledger.of(_walletId!).total;
      if (amount! > balance + 0.005) {
        final name = walletsRepo.walletById(_walletId)?.name ?? 'This wallet';
        final proceed = await confirmDialog(
          context,
          title: 'More than $name has',
          message:
              '$name has ${signedMoney(money, balance)}. Saving this takes '
              'it to ${signedMoney(money, balance - amount)}.',
          confirmLabel: 'Save anyway',
          cancelLabel: 'Go back',
        );
        if (proceed != true || !mounted) return;
      }
    }

    setState(() => _saving = true);
    try {
      String? transactionId;
      String? walletEntryId;
      final note = switch (widget.kind) {
        InvestEntryKind.deposit => 'Invested in ${_a.name}',
        InvestEntryKind.dividend => 'Dividend from ${_a.name}',
        _ => 'From ${_a.name}',
      };
      switch (_source) {
        case PaymentSource.budget:
          transactionId = await txRepo.addTransaction(
            TransactionModel(
              id: '',
              title: note,
              amount: amount!,
              type: _txType,
              categoryId: _categoryId,
              date: _date,
            ),
          );
        case PaymentSource.wallet:
          walletEntryId = await walletsRepo.addEntry(
            WalletEntry(
              id: '',
              kind: _depositing ? WalletEntryKind.spend : WalletEntryKind.add,
              walletId: _walletId!,
              amount: amount!,
              date: _date,
              note: note,
            ),
          );
        case PaymentSource.none:
          break;
      }
      await repo.addEntry(
        InvestEntry(
          id: '',
          accountId: _a.id,
          kind: widget.kind,
          amount: amount!,
          date: _date,
          source: _source,
          transactionId: transactionId,
          walletEntryId: walletEntryId,
        ),
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
    final repo = context.watch<InvestmentsRepository>();
    final txRepo = context.watch<TransactionsRepository>();
    final wallets = context.watch<WalletsRepository>();
    final category = txRepo.categoryById(_categoryId);
    final wallet = wallets.walletById(_walletId);
    final value = repo.progressOf(_a).value;

    final (String title, String subtitle) = switch (widget.kind) {
      InvestEntryKind.deposit => (
        'Put money in',
        'Money you deposited into ${_a.name}.',
      ),
      InvestEntryKind.withdraw => (
        'Take money out',
        '${_a.name} is worth ${money.format(value)}.',
      ),
      _ => ('Dividend', 'A dividend from shares in ${_a.name}.'),
    };

    return MoneySheet(
      title: title,
      subtitle: subtitle,
      isDirty: _isDirty,
      button: ElevatedButton(
        onPressed: _saving ? null : _save,
        child: ButtonLabel('Save', loading: _saving),
      ),
      children: [
        LabeledField(
          label: 'Amount',
          field: AmountField(
            controller: _amount,
            errorText: _amountError,
            autofocus: true,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _depositing ? 'From' : 'Where it went',
          style: AppText.rowTitle.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        ChoicePills<PaymentSource>(
          options: [
            (
              PaymentSource.budget,
              _depositing ? 'Monthly money' : 'Income this month',
            ),
            if (wallets.hasWallets) (PaymentSource.wallet, 'A wallet'),
            (PaymentSource.none, 'Just record it'),
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
                label: category?.name ?? 'Choose a category',
                empty: category == null,
                error: _categoryError,
                onTap: () async {
                  final picked = await pickCategory(
                    context,
                    selectedId: _categoryId,
                    type: _txType,
                  );
                  if (picked != null) {
                    setState(() {
                      _categoryId = picked;
                      _categoryError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 6),
              Text(
                _depositing
                    ? (category == null
                          ? 'Adds an expense in this category.'
                          : category.excludeFromBudget
                          ? 'Adds an expense in ${category.name}. Not counted '
                                'in your monthly budget.'
                          : 'Adds an expense in ${category.name}. Counts '
                                'toward your monthly budget.')
                    : 'Adds income in ${category?.name ?? 'this category'}.',
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
                label: wallet?.name ?? 'Choose a wallet',
                empty: wallet == null,
                error: _walletError,
                onTap: () async {
                  final choice = await pickWallet(
                    context,
                    selectedId: _walletId,
                    title: _depositing
                        ? 'From which wallet?'
                        : 'Into which wallet?',
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
                _depositing
                    ? 'Takes it out of the wallet.'
                    : 'Adds it to the wallet as your own money.',
                style: AppText.label.copyWith(color: c.muted),
              ),
            ],
          ),
          PaymentSource.none => Text(
            'Only updates this account. Nothing is added to your '
            'transactions or wallets.',
            style: AppText.label.copyWith(color: c.muted),
          ),
        },
        const SizedBox(height: 16),
        LabeledField(
          label: 'Date',
          field: FieldButton(
            leading: Icon(Icons.calendar_today_outlined, color: c.muted),
            label: friendlyDate(_date),
            onTap: () =>
                _pickDateInto(context, _date, (d) => setState(() => _date = d)),
          ),
        ),
      ],
    );
  }
}

/// Deletes an entry after asking, along with the transaction or wallet
/// entry it added.
Future<void> confirmDeleteInvestEntry(
  BuildContext context,
  InvestEntry entry,
) async {
  final money = context.moneyNow;
  final repo = context.read<InvestmentsRepository>();
  final txRepo = context.read<TransactionsRepository>();
  final walletsRepo = context.read<WalletsRepository>();
  final linkedTx =
      entry.transactionId != null &&
      txRepo.transactions.any((t) => t.id == entry.transactionId);
  final linkedEntry = walletsRepo.entries
      .where((e) => e.id == entry.walletEntryId)
      .firstOrNull;
  final walletName = linkedEntry == null
      ? null
      : walletsRepo.walletById(linkedEntry.walletId)?.name ?? 'the wallet';

  final confirmed = await confirmDialog(
    context,
    title: switch (entry.kind) {
      InvestEntryKind.value => 'Delete this value?',
      InvestEntryKind.dividend => 'Delete this dividend?',
      _ => 'Delete this entry?',
    },
    message: [
      switch (entry.kind) {
        InvestEntryKind.value =>
          'The account goes back to the value before it.',
        InvestEntryKind.deposit =>
          'The ${money.format(entry.amount)} comes off what you put in.',
        InvestEntryKind.withdraw =>
          'The ${money.format(entry.amount)} goes back into what you put in.',
        InvestEntryKind.dividend =>
          'The ${money.format(entry.amount)} comes off your gain.',
      },
      if (linkedTx) 'The transaction it added is deleted too.',
      if (walletName != null)
        'The entry it added in $walletName is deleted too.',
    ].join(' '),
    confirmLabel: 'Delete',
    destructive: true,
  );
  if (confirmed != true) return;
  try {
    await repo.deleteEntry(entry.id);
    if (linkedTx) await txRepo.deleteTransaction(entry.transactionId!);
    if (linkedEntry != null) await walletsRepo.deleteEntry(linkedEntry.id);
  } catch (e) {
    if (context.mounted) toastSaveError(context, e);
  }
}
