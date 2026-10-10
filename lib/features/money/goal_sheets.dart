import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/app_settings.dart';
import 'package:monthly_traq/app/category_icons.dart';
import 'package:monthly_traq/app/haptics.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/money/money_common.dart';
import 'package:monthly_traq/models/goal_models.dart';
import 'package:monthly_traq/models/repayment_models.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/models/wallet_models.dart';
import 'package:monthly_traq/services/goals_repository.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/services/wallets_repository.dart';
import 'package:monthly_traq/widgets/ui.dart';
import 'package:monthly_traq/l10n/l10n.dart';

/// Icons that suit things people save up for.
const _goalIconKeys = [
  'savings',
  'smartphone',
  'two_wheeler',
  'directions_car',
  'home',
  'computer',
  'flight',
  'school',
  'favorite',
  'card_giftcard',
  'mosque',
  'watch',
  'sports_esports',
  'child_care',
  'celebration',
  'diamond',
  'tv',
  'kitchen',
];

// Goal: add / edit / delete

Future<void> showGoalEditor(BuildContext context, {GoalModel? existing}) =>
    showMoneySheet<void>(
      context,
      _GoalEditor(existing: existing),
      guarded: true,
    );

class _GoalEditor extends StatefulWidget {
  final GoalModel? existing;

  const _GoalEditor({this.existing});

  @override
  State<_GoalEditor> createState() => _GoalEditorState();
}

class _GoalEditorState extends State<_GoalEditor> {
  late final GoalModel? _e = widget.existing;
  late final _name = TextEditingController(text: _e?.name);
  late final _target = TextEditingController(
    text: _e == null ? '' : plainAmount(_e.target),
  );
  late final _savedBefore = TextEditingController(
    text: _e == null || _e.savedBefore == 0 ? '' : plainAmount(_e.savedBefore),
  );
  late IconData _icon = _e?.icon ?? iconForKey('savings');
  late DateTime? _targetDate = _e?.targetDate;

  String? _nameError;
  String? _targetError;
  String? _savedError;
  bool _saving = false;

  late final _initial = (
    name: _name.text,
    target: _target.text,
    saved: _savedBefore.text,
    icon: _icon,
    date: _targetDate,
  );

  bool get _isEditing => _e != null;

  @override
  void initState() {
    super.initState();
    _initial; // Record the starting point now, before anything changes.
  }

  bool _isDirty() =>
      _name.text != _initial.name ||
      _target.text != _initial.target ||
      _savedBefore.text != _initial.saved ||
      _icon != _initial.icon ||
      _targetDate != _initial.date;

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _savedBefore.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime(now.year, now.month + 6, now.day),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 20),
      helpText: context.l10n.reachItBy,
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _save() async {
    final money = context.moneyNow;
    final name = _name.text.trim();
    final target = parseAmount(_target.text);
    final savedBefore = _savedBefore.text.trim().isEmpty
        ? 0.0
        : parseAmount(_savedBefore.text);
    setState(() {
      _nameError = name.isEmpty ? context.l10n.whatSavingFor : null;
      _targetError = target == null || target <= 0
          ? context.l10n.enterHowMuchItCosts
          : null;
      _savedError = savedBefore == null || savedBefore < 0
          ? context.l10n.enterAmountOrLeaveEmpty
          : target != null && savedBefore > target
          ? context.l10n.moreThanTarget(money.format(target))
          : null;
    });
    if (_nameError != null || _targetError != null || _savedError != null) {
      return;
    }

    final repo = context.read<GoalsRepository>();
    final sameName = repo.goals.any(
      (g) =>
          g.id != _e?.id && g.name.trim().toLowerCase() == name.toLowerCase(),
    );
    if (sameName) {
      final proceed = await confirmDialog(
        context,
        title: context.l10n.youAlreadyHave(name),
        message: context.l10n.sameGoalNameBody,
        confirmLabel: context.l10n.saveAnyway,
        cancelLabel: context.l10n.goBack,
      );
      if (proceed != true || !mounted) return;
    }

    setState(() => _saving = true);
    final goal = GoalModel(
      id: _e?.id ?? '',
      name: name,
      icon: _icon,
      color: _e?.color ?? repo.nextColor,
      target: target!,
      savedBefore: savedBefore!,
      targetDate: _targetDate,
      doneAt: _e?.doneAt,
      createdAt: _e?.createdAt ?? DateTime.now(),
      addSource: _e?.addSource ?? PaymentSource.budget,
      categoryId: _e?.categoryId,
      walletId: _e?.walletId,
    );
    try {
      if (_isEditing) {
        await repo.updateGoal(goal);
      } else {
        await repo.addGoal(goal);
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
      message: context.l10n.deleteGoalBody,
      confirmLabel: context.l10n.delete,
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    final navigator = Navigator.of(context);
    try {
      await context.read<GoalsRepository>().deleteGoal(existing.id);
      navigator.pop();
    } catch (e) {
      if (mounted) toastSaveError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MoneySheet(
      title: _isEditing ? context.l10n.editGoal : context.l10n.newGoal,
      subtitle: _isEditing ? null : context.l10n.newGoalSubtitle,
      isDirty: _isDirty,
      trailing: _isEditing
          ? IconButton(
              tooltip: context.l10n.deleteGoal,
              onPressed: _delete,
              icon: Icon(Icons.delete_outline, color: c.spending),
            )
          : null,
      button: ElevatedButton(
        onPressed: _saving ? null : _save,
        child: ButtonLabel(
          _isEditing ? context.l10n.saveChanges : context.l10n.addGoal,
          loading: _saving,
        ),
      ),
      children: [
        LabeledField(
          label: context.l10n.savingFor,
          field: TextField(
            controller: _name,
            autofocus: !_isEditing,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 60,
            decoration: InputDecoration(
              hintText: context.l10n.goalNameHint,
              errorText: _nameError,
              counterText: '',
            ),
          ),
        ),
        const SizedBox(height: 16),
        LabeledField(
          label: context.l10n.target,
          field: AmountField(controller: _target, errorText: _targetError),
        ),
        const SizedBox(height: 16),
        LabeledField(
          label: context.l10n.alreadySavedOptional,
          field: AmountField(controller: _savedBefore, errorText: _savedError),
        ),
        const SizedBox(height: 16),
        LabeledField(
          label: context.l10n.reachItByOptional,
          field: Row(
            children: [
              Expanded(
                child: FieldButton(
                  leading: Icon(Icons.flag_outlined, color: c.muted),
                  label: _targetDate == null
                      ? context.l10n.goalNoDate
                      : friendlyDate(context.l10n, _targetDate!),
                  empty: _targetDate == null,
                  onTap: _pickDate,
                ),
              ),
              if (_targetDate != null)
                IconButton(
                  tooltip: context.l10n.removeDate,
                  onPressed: () => setState(() => _targetDate = null),
                  icon: Icon(Icons.close, color: c.muted),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.goalDateHelp,
          style: AppText.label.copyWith(color: c.muted),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.icon,
          style: AppText.rowTitle.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            for (final key in _goalIconKeys)
              Material(
                color: iconForKey(key) == _icon ? c.primary : c.surfaceHigh,
                borderRadius: BorderRadius.circular(AppRadius.iconTile),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.iconTile),
                  onTap: () => setState(() => _icon = iconForKey(key)),
                  child: Icon(
                    iconForKey(key),
                    size: 22,
                    color: iconForKey(key) == _icon ? c.onPrimary : c.muted,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// Adding money / taking it out

Future<void> showGoalMoneySheet(
  BuildContext context,
  GoalModel goal,
  GoalEntryKind kind,
) => showMoneySheet<void>(
  context,
  _GoalMoneySheet(goal: goal, kind: kind),
  guarded: true,
);

class _GoalMoneySheet extends StatefulWidget {
  final GoalModel goal;
  final GoalEntryKind kind;

  const _GoalMoneySheet({required this.goal, required this.kind});

  @override
  State<_GoalMoneySheet> createState() => _GoalMoneySheetState();
}

class _GoalMoneySheetState extends State<_GoalMoneySheet> {
  final _amount = TextEditingController();
  late PaymentSource _source;
  String? _categoryId;
  String? _walletId;
  DateTime _date = DateTime.now();

  String? _amountError;
  String? _categoryError;
  String? _walletError;
  bool _saving = false;

  GoalModel get _g => widget.goal;
  bool get _adding => widget.kind == GoalEntryKind.add;

  @override
  void initState() {
    super.initState();
    final txRepo = context.read<TransactionsRepository>();
    final wallets = context.read<WalletsRepository>();
    if (_adding) {
      _source = _g.addSource;
      if (_source == PaymentSource.wallet && !wallets.hasWallets) {
        _source = PaymentSource.budget;
      }
    } else {
      _source = wallets.hasWallets ? PaymentSource.wallet : PaymentSource.none;
    }
    _categoryId = txRepo.categoryById(_g.categoryId)?.id;
    final lastWallet = context.read<AppSettings>().lastWalletId;
    _walletId =
        wallets.walletById(_g.walletId)?.id ??
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

  Future<void> _save() async {
    final money = context.moneyNow;
    final repo = context.read<GoalsRepository>();
    final txRepo = context.read<TransactionsRepository>();
    final walletsRepo = context.read<WalletsRepository>();
    final before = repo.progressOf(_g);
    final amount = parseAmount(_amount.text);
    setState(() {
      _amountError = amount == null || amount <= 0
          ? context.l10n.amountAboveZero
          : !_adding && amount > before.saved + 0.005
          ? context.l10n.onlyAmountSaved(money.format(before.saved))
          : null;
      _categoryError = _source == PaymentSource.budget && _categoryId == null
          ? context.l10n.pickExpenseCategory
          : null;
      _walletError = _source == PaymentSource.wallet && _walletId == null
          ? context.l10n.pickWallet
          : null;
    });
    if (_amountError != null ||
        _categoryError != null ||
        _walletError != null) {
      return;
    }

    if (_adding && _source == PaymentSource.wallet) {
      final balance = walletsRepo.ledger.of(_walletId!).total;
      if (amount! > balance + 0.005) {
        final name =
            walletsRepo.walletById(_walletId)?.name ?? context.l10n.thisWallet;
        final proceed = await confirmDialog(
          context,
          title: context.l10n.moreThanWalletHas(name),
          message: context.l10n.moreThanWalletBody(
            name,
            signedMoney(money, balance),
            signedMoney(money, balance - amount),
          ),
          confirmLabel: context.l10n.saveAnyway,
          cancelLabel: context.l10n.goBack,
        );
        if (proceed != true || !mounted) return;
      }
    }

    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final l10n = context.l10n;
    try {
      String? transactionId;
      String? walletEntryId;
      switch (_source) {
        case PaymentSource.budget:
          transactionId = await txRepo.addTransaction(
            TransactionModel(
              id: '',
              title: _g.name,
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
              // Adding takes it out of the wallet; taking out puts it back.
              kind: _adding ? WalletEntryKind.spend : WalletEntryKind.add,
              walletId: _walletId!,
              amount: amount!,
              date: _date,
              note: _adding
                  ? l10n.savedForGoal(_g.name)
                  : l10n.fromGoal(_g.name),
            ),
          );
        case PaymentSource.none:
          break;
      }
      await repo.addEntry(
        GoalEntry(
          id: '',
          goalId: _g.id,
          kind: widget.kind,
          amount: amount!,
          date: _date,
          source: _source,
          transactionId: transactionId,
          walletEntryId: walletEntryId,
        ),
        categoryId: _adding && _source == PaymentSource.budget
            ? _categoryId
            : null,
        walletId: _adding && _source == PaymentSource.wallet ? _walletId : null,
      );
      if (!mounted) return;
      final reachedNow =
          _adding && !before.isReached && before.saved + amount >= _g.target;
      final hostContext = navigator.context;
      navigator.pop();
      if (reachedNow && hostContext.mounted) {
        await showGoalReached(hostContext, _g);
      }
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
    final repo = context.watch<GoalsRepository>();
    final txRepo = context.watch<TransactionsRepository>();
    final wallets = context.watch<WalletsRepository>();
    final p = repo.progressOf(_g);
    final category = txRepo.categoryById(_categoryId);
    final wallet = wallets.walletById(_walletId);

    final walletField = FieldButton(
      leading: wallet != null
          ? IconTile(icon: wallet.icon, color: wallet.color, size: 36)
          : Icon(Icons.account_balance_wallet_outlined, color: c.muted),
      label: wallet?.name ?? context.l10n.chooseWallet,
      empty: wallet == null,
      error: _walletError,
      onTap: () async {
        final choice = await pickWallet(
          context,
          selectedId: _walletId,
          title: _adding
              ? context.l10n.fromWhichWallet
              : context.l10n.intoWhichWallet,
        );
        if (choice?.walletId != null) {
          setState(() {
            _walletId = choice!.walletId;
            _walletError = null;
          });
        }
      },
    );

    return MoneySheet(
      title: _adding
          ? context.l10n.addToGoal(_g.name)
          : context.l10n.takeOutOfGoal(_g.name),
      subtitle: _adding
          ? p.isReached
                ? context.l10n.savedReachedIt(money.format(p.saved))
                : context.l10n.savedToGo(
                    money.format(p.saved),
                    money.format(p.remaining),
                  )
          : context.l10n.savedTakingOutLowers(money.format(p.saved)),
      isDirty: _isDirty,
      button: ElevatedButton(
        onPressed: _saving ? null : _save,
        child: ButtonLabel(
          _adding ? context.l10n.add : context.l10n.takeOut,
          loading: _saving,
        ),
      ),
      children: [
        LabeledField(
          label: context.l10n.amount,
          field: AmountField(
            controller: _amount,
            errorText: _amountError,
            autofocus: true,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _adding ? context.l10n.from : context.l10n.whereItGoes,
          style: AppText.rowTitle.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        ChoicePills<PaymentSource>(
          options: [
            if (_adding) (PaymentSource.budget, context.l10n.monthlyMoney),
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
                onTap: () async {
                  final picked = await pickExpenseCategory(
                    context,
                    selectedId: _categoryId,
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
                category == null
                    ? context.l10n.addsExpenseGoalHint
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
              walletField,
              const SizedBox(height: 6),
              Text(
                _adding
                    ? context.l10n.goalFromWalletHelp
                    : context.l10n.goalToWalletHelp,
                style: AppText.label.copyWith(color: c.muted),
              ),
            ],
          ),
          PaymentSource.none => Text(
            context.l10n.onlyUpdatesGoal,
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

/// The moment a goal is reached: a celebration, and the choice to mark it
/// done now.
Future<void> showGoalReached(BuildContext context, GoalModel goal) async {
  haptic(context, Haptic.success);
  final money = context.moneyNow;
  final c = context.colors;
  final markDone = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(Icons.celebration, color: c.accent, size: 44),
      title: Text(dialogContext.l10n.youReachedGoal(goal.name)),
      content: Text(
        dialogContext.l10n.goalReachedBody(money.format(goal.target)),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(dialogContext.l10n.notYet),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(dialogContext.l10n.markAsDone),
        ),
      ],
    ),
  );
  if (markDone != true || !context.mounted) return;
  try {
    await context.read<GoalsRepository>().setDone(goal, true);
  } catch (e) {
    if (context.mounted) toastSaveError(context, e);
  }
}

/// Deletes a goal entry after asking, along with the expense or wallet
/// entry it added.
Future<void> confirmDeleteGoalEntry(
  BuildContext context,
  GoalEntry entry,
) async {
  final money = context.moneyNow;
  final repo = context.read<GoalsRepository>();
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
      : walletsRepo.walletById(linkedEntry.walletId)?.name ??
            context.l10n.theWallet;

  final confirmed = await confirmDialog(
    context,
    title: entry.kind == GoalEntryKind.add
        ? context.l10n.deleteThisSaving
        : context.l10n.deleteThisTakeOut,
    message: [
      entry.kind == GoalEntryKind.add
          ? context.l10n.goalGoesDownBy(money.format(entry.amount))
          : context.l10n.goesBackIntoGoal(money.format(entry.amount)),
      if (linkedTx) context.l10n.expenseDeletedToo,
      if (walletName != null) context.l10n.walletEntryDeletedToo(walletName),
    ].join(' '),
    confirmLabel: context.l10n.delete,
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
