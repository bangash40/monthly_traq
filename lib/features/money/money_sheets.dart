import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/app_settings.dart';
import 'package:monthly_traq/app/category_icons.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/money/money_common.dart';
import 'package:monthly_traq/models/wallet_models.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/services/wallets_repository.dart';
import 'package:monthly_traq/widgets/budget_sheet.dart';
import 'package:monthly_traq/widgets/ui.dart';
import 'package:monthly_traq/l10n/l10n.dart';

/// Icons that suit a wallet: mobile wallets, banks, cash, cards…
const _walletIconKeys = [
  'account_balance_wallet',
  'smartphone',
  'account_balance',
  'payments',
  'credit_card',
  'savings',
  'paid',
  'currency_exchange',
  'home',
  'work',
  'card_giftcard',
  'security',
];

void _toastError(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        error is SyncTimeoutException
            ? context.l10n.noInternetTryAgain
            : context.l10n.couldntSaveTryAgain,
      ),
    ),
  );
}

String _plain(double amount) => GroupedNumberFormatter.formatText(
  amount == amount.roundToDouble()
      ? amount.toStringAsFixed(0)
      : amount.toStringAsFixed(2),
);

// Wallet: add / edit / delete

Future<void> showWalletEditor(BuildContext context, {WalletModel? existing}) =>
    showMoneySheet<void>(
      context,
      _WalletEditor(existing: existing),
      guarded: true,
    );

class _WalletEditor extends StatefulWidget {
  final WalletModel? existing;

  const _WalletEditor({this.existing});

  @override
  State<_WalletEditor> createState() => _WalletEditorState();
}

class _WalletEditorState extends State<_WalletEditor> {
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _opening = TextEditingController(
    text: widget.existing == null
        ? ''
        : _plain(widget.existing!.openingBalance),
  );
  late final IconData _initialIcon =
      widget.existing?.icon ?? iconForKey('account_balance_wallet');
  late IconData _icon = _initialIcon;
  late final String _initialName = widget.existing?.name ?? '';
  late final String _initialOpening = widget.existing == null
      ? ''
      : _plain(widget.existing!.openingBalance);
  String? _nameError;
  String? _amountError;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  bool _isDirty() =>
      _name.text != _initialName ||
      _opening.text != _initialOpening ||
      _icon != _initialIcon;

  @override
  void dispose() {
    _name.dispose();
    _opening.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final opening = _opening.text.trim().isEmpty
        ? 0.0
        : parseAmount(_opening.text);
    setState(() {
      _nameError = name.isEmpty ? context.l10n.walletNameError : null;
      _amountError = opening == null ? context.l10n.amountOrEmpty : null;
    });
    if (_nameError != null || _amountError != null) return;

    final repo = context.read<WalletsRepository>();
    final sameName = repo.wallets.any(
      (w) =>
          w.id != widget.existing?.id &&
          w.name.trim().toLowerCase() == name.toLowerCase(),
    );
    if (sameName) {
      final proceed = await confirmDialog(
        context,
        title: context.l10n.youAlreadyHave(name),
        message: _isEditing
            ? context.l10n.walletSameNameEdit(name)
            : context.l10n.walletSameNameAdd,
        confirmLabel: _isEditing
            ? context.l10n.saveAnyway
            : context.l10n.addAnyway,
        cancelLabel: context.l10n.goBack,
      );
      if (proceed != true || !mounted) return;
    }

    setState(() => _saving = true);
    try {
      final existing = widget.existing;
      if (existing == null) {
        await repo.addWallet(name: name, icon: _icon, openingBalance: opening!);
      } else {
        await repo.updateWallet(
          WalletModel(
            id: existing.id,
            name: name,
            icon: _icon,
            color: existing.color,
            openingBalance: opening!,
            sortOrder: existing.sortOrder,
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _toastError(context, e);
    }
  }

  Future<void> _delete() async {
    final existing = widget.existing!;
    final confirmed = await _confirmDelete(
      context,
      title: context.l10n.deleteNamed(existing.name),
      message: context.l10n.deleteWalletBody,
    );
    if (confirmed != true || !mounted) return;
    final navigator = Navigator.of(context);
    try {
      await context.read<WalletsRepository>().deleteWallet(existing.id);
      navigator.pop();
    } catch (e) {
      if (mounted) _toastError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MoneySheet(
      title: _isEditing ? context.l10n.editWallet : context.l10n.newWallet,
      isDirty: _isDirty,
      trailing: _isEditing
          ? IconButton(
              tooltip: context.l10n.deleteWallet,
              onPressed: _delete,
              icon: Icon(Icons.delete_outline, color: c.spending),
            )
          : null,
      button: ElevatedButton(
        onPressed: _saving ? null : _save,
        child: ButtonLabel(
          _isEditing ? context.l10n.saveChanges : context.l10n.addWalletButton,
          loading: _saving,
        ),
      ),
      children: [
        LabeledField(
          label: context.l10n.name,
          field: TextField(
            controller: _name,
            autofocus: !_isEditing,
            textCapitalization: TextCapitalization.words,
            maxLength: 40,
            decoration: InputDecoration(
              hintText: context.l10n.walletNameHint,
              errorText: _nameError,
              counterText: '',
            ),
          ),
        ),
        const SizedBox(height: 16),
        LabeledField(
          label: _isEditing
              ? context.l10n.ownMoneyWhenAdded
              : context.l10n.ownMoneyNow,
          field: AmountField(controller: _opening, errorText: _amountError),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.ownMoneyHelp,
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
            for (final key in _walletIconKeys)
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

// Wallet entries: spent, add money, received, send back, move

/// Adds an entry of [kind] (starting on [walletId] / [personId] when
/// given), or edits [existing].
Future<void> showEntrySheet(
  BuildContext context, {
  WalletEntryKind? kind,
  String? walletId,
  String? personId,
  WalletEntry? existing,
}) {
  assert(kind != null || existing != null);
  final entryKind = existing?.kind ?? kind!;
  if (entryKind == WalletEntryKind.adjust) {
    return _confirmDeleteCorrection(context, existing!);
  }
  return showMoneySheet<void>(
    context,
    _EntrySheet(
      kind: entryKind,
      walletId: walletId,
      personId: personId,
      existing: existing,
    ),
    guarded: true,
  );
}

/// Corrections can't be edited, only removed.
Future<void> _confirmDeleteCorrection(
  BuildContext context,
  WalletEntry entry,
) async {
  final confirmed = await _confirmDelete(
    context,
    title: context.l10n.deleteCorrectionTitle,
    message: context.l10n.deleteCorrectionBody,
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await context.read<WalletsRepository>().deleteEntry(entry.id);
  } catch (e) {
    if (context.mounted) _toastError(context, e);
  }
}

Future<bool?> _confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
}) => confirmDialog(
  context,
  title: title,
  message: message,
  confirmLabel: context.l10n.delete,
  destructive: true,
);

class _EntrySheet extends StatefulWidget {
  final WalletEntryKind kind;
  final String? walletId;
  final String? personId;
  final WalletEntry? existing;

  const _EntrySheet({
    required this.kind,
    this.walletId,
    this.personId,
    this.existing,
  });

  @override
  State<_EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends State<_EntrySheet> {
  late final _amount = TextEditingController(
    text: widget.existing == null ? '' : _plain(widget.existing!.amount),
  );
  late final _note = TextEditingController(text: widget.existing?.note);
  late DateTime _date = widget.existing?.date ?? DateTime.now();
  String? _walletId;
  String? _toWalletId;
  PersonChoice? _person;

  String? _amountError;
  String? _walletError;
  String? _toWalletError;
  String? _personError;
  bool _saving = false;

  WalletEntryKind get _kind => widget.kind;
  bool get _isEditing => widget.existing != null;
  bool get _hasPerson =>
      _kind == WalletEntryKind.receive || _kind == WalletEntryKind.giveBack;

  @override
  void initState() {
    super.initState();
    final repo = context.read<WalletsRepository>();
    final existing = widget.existing;
    if (existing != null) {
      _walletId = existing.walletId;
      _toWalletId = existing.toWalletId;
      if (existing.personId != null) {
        _person = PersonChoice.existing(existing.personId!);
      }
    } else {
      if (widget.personId != null) {
        _person = PersonChoice.existing(widget.personId!);
      }
      _walletId = widget.walletId ?? _defaultWallet(repo);
    }
    _initial; // Record the starting point now, before anything changes.
  }

  // What the sheet opened with, to tell whether anything was changed.
  late final _initial = (
    amount: _amount.text,
    note: _note.text,
    date: _date,
    walletId: _walletId,
    toWalletId: _toWalletId,
    person: _person?.personId ?? _person?.newName,
  );

  bool _isDirty() =>
      _amount.text != _initial.amount ||
      _note.text != _initial.note ||
      _date != _initial.date ||
      _walletId != _initial.walletId ||
      _toWalletId != _initial.toWalletId ||
      (_person?.personId ?? _person?.newName) != _initial.person;

  /// Spent, Send back and Move take money out of [_walletId].
  bool get _takesOut =>
      _kind == WalletEntryKind.spend ||
      _kind == WalletEntryKind.giveBack ||
      _kind == WalletEntryKind.transfer;

  /// What the wallet has to take this from: its balance, plus this entry's
  /// own amount when editing it (it's already been taken out).
  double _available(WalletsRepository repo) {
    final existing = widget.existing;
    final already = existing != null && existing.walletId == _walletId
        ? existing.amount
        : 0.0;
    return repo.ledger.of(_walletId!).total + already;
  }

  /// Sending back starts on the wallet holding most of that person's
  /// money; anything else on the last wallet used, or the only one.
  String? _defaultWallet(WalletsRepository repo) {
    final personId = _person?.personId;
    if (_kind == WalletEntryKind.giveBack && personId != null) {
      final placement = repo.ledger.placementOf(personId).entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (placement.isNotEmpty) return placement.first.key;
    }
    final last = context.read<AppSettings>().lastWalletId;
    if (repo.walletById(last) != null) return last;
    return repo.wallets.length == 1 ? repo.wallets.single.id : null;
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  String? _personName(WalletsRepository repo) => _person == null
      ? null
      : _person!.newName ?? repo.personById(_person!.personId)?.name;

  /// How much can be sent back to the chosen person: what's owed, plus this
  /// entry's own amount when editing it.
  double _canGiveBack(WalletsRepository repo) {
    final personId = _person?.personId;
    if (personId == null) return 0;
    final existing = widget.existing;
    final already = existing != null && existing.personId == personId
        ? existing.amount
        : 0.0;
    return repo.ledger.owedTo(personId) + already;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked == null) return;
    // Keep the time of day so the order within a day stays meaningful.
    setState(() {
      _date = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _date.hour,
        _date.minute,
      );
    });
  }

  Future<void> _save() async {
    final repo = context.read<WalletsRepository>();
    final money = context.moneyNow;
    final amount = parseAmount(_amount.text);
    final name = _personName(repo);
    final canGiveBack = _canGiveBack(repo);
    final l10n = context.l10n;
    setState(() {
      _personError = _hasPerson && _person == null ? l10n.pickWhoseMoney : null;
      _walletError = _walletId == null ? l10n.pickWallet : null;
      _toWalletError = _kind == WalletEntryKind.transfer
          ? _toWalletId == null
                ? l10n.pickWhereItWent
                : _toWalletId == _walletId
                ? l10n.pickDifferentWallet
                : null
          : null;
      _amountError = amount == null || amount <= 0
          ? l10n.amountAboveZero
          : _kind == WalletEntryKind.giveBack &&
                _person != null &&
                amount > canGiveBack + 0.005
          ? canGiveBack <= 0
                ? l10n.notKeepingAny(name ?? '')
                : l10n.keepingFor(money.format(canGiveBack), name ?? '')
          : null;
    });
    if (_personError != null ||
        _walletError != null ||
        _toWalletError != null ||
        _amountError != null) {
      return;
    }

    if (_takesOut) {
      final available = _available(repo);
      if (amount! > available + 0.005) {
        final walletName = repo.walletById(_walletId)?.name ?? l10n.thisWallet;
        final proceed = await confirmDialog(
          context,
          title: l10n.moreThanWalletHas(walletName),
          message: l10n.moreThanWalletBody(
            walletName,
            signedMoney(money, available),
            signedMoney(money, available - amount),
          ),
          confirmLabel: l10n.saveAnyway,
          cancelLabel: l10n.goBack,
        );
        if (proceed != true || !mounted) return;
      }
    }

    setState(() => _saving = true);
    final settings = context.read<AppSettings>();
    final note = _note.text.trim().isEmpty ? null : _note.text.trim();
    try {
      var personId = _person?.personId;
      if (_hasPerson && personId == null) {
        personId = await repo.addPerson(_person!.newName!);
        if (personId == null) throw StateError('Not signed in');
      }
      final entry = WalletEntry(
        id: widget.existing?.id ?? '',
        kind: _kind,
        walletId: _walletId!,
        toWalletId: _kind == WalletEntryKind.transfer ? _toWalletId : null,
        personId: _hasPerson ? personId : null,
        amount: amount!,
        date: _date,
        note: note,
      );
      if (_isEditing) {
        await repo.updateEntry(entry);
      } else {
        await repo.addEntry(entry);
      }
      settings.setLastWalletId(_walletId);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _toastError(context, e);
    }
  }

  Future<void> _delete() async {
    final confirmed = await _confirmDelete(
      context,
      title: context.l10n.deleteEntryTitle,
      message: context.l10n.deleteEntryBody,
    );
    if (confirmed != true || !mounted) return;
    final navigator = Navigator.of(context);
    try {
      await context.read<WalletsRepository>().deleteEntry(widget.existing!.id);
      navigator.pop();
    } catch (e) {
      if (mounted) _toastError(context, e);
    }
  }

  Widget _walletField({
    required String label,
    required String? walletId,
    required String? error,
    required ValueChanged<String> onPicked,
    String? excludeId,
    String? pickerTitle,
  }) {
    final c = context.colors;
    final wallet = context.watch<WalletsRepository>().walletById(walletId);
    return LabeledField(
      label: label,
      field: FieldButton(
        leading: wallet != null
            ? IconTile(icon: wallet.icon, color: wallet.color, size: 36)
            : Icon(Icons.account_balance_wallet_outlined, color: c.muted),
        label: wallet?.name ?? context.l10n.chooseWallet,
        empty: wallet == null,
        error: error,
        onTap: () async {
          final choice = await pickWallet(
            context,
            selectedId: walletId,
            title: pickerTitle,
            excludeId: excludeId,
          );
          if (choice?.walletId != null) onPicked(choice!.walletId!);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final repo = context.watch<WalletsRepository>();
    final name = _personName(repo);
    final canGiveBack = _canGiveBack(repo);
    final l10n = context.l10n;

    final (String title, String? subtitle) = switch (_kind) {
      WalletEntryKind.spend => (
        _isEditing ? l10n.editSpending : l10n.spent,
        _isEditing ? null : l10n.spentHelp,
      ),
      WalletEntryKind.add => (
        _isEditing ? l10n.editAddedMoney : l10n.addYourMoney,
        _isEditing ? null : l10n.addYourMoneyHelp,
      ),
      WalletEntryKind.receive => (
        _isEditing ? l10n.editReceivedMoney : l10n.receivedToKeep,
        _isEditing ? null : l10n.receivedToKeepHelp,
      ),
      WalletEntryKind.giveBack => (
        _isEditing ? l10n.editMoneySentBack : l10n.sendBack,
        name == null
            ? l10n.sendBackHelp
            : canGiveBack > 0
            ? l10n.keepingForSentence(money.format(canGiveBack), name)
            : l10n.notKeepingAnySentence(name),
      ),
      WalletEntryKind.transfer => (
        _isEditing ? l10n.editMove : l10n.moveMoney,
        _isEditing ? null : l10n.moveMoneyHelp,
      ),
      WalletEntryKind.adjust => (l10n.correction, null),
    };

    final personField = LabeledField(
      label: _kind == WalletEntryKind.receive ? l10n.from : l10n.to,
      field: FieldButton(
        leading: name != null
            ? PersonAvatar(name: name, radius: 18)
            : Icon(Icons.person_outline, color: c.muted),
        label: name ?? l10n.chooseSomeone,
        empty: name == null,
        error: _personError,
        onTap: () async {
          final choice = await pickPerson(
            context,
            selectedId: _person?.personId,
            title: _kind == WalletEntryKind.receive
                ? l10n.whoseMoney
                : l10n.sendBackTo,
          );
          if (choice == null) return;
          setState(() {
            _person = choice;
            _personError = null;
            if (_kind == WalletEntryKind.giveBack && !_isEditing) {
              _walletId = _defaultWallet(repo) ?? _walletId;
            }
          });
        },
      ),
    );

    final amountField = LabeledField(
      label: l10n.amount,
      field: AmountField(
        controller: _amount,
        errorText: _amountError,
        autofocus: !_isEditing && (!_hasPerson || _person != null),
      ),
    );

    final walletField = switch (_kind) {
      WalletEntryKind.transfer => _walletField(
        label: l10n.from,
        walletId: _walletId,
        error: _walletError,
        pickerTitle: l10n.moveFrom,
        onPicked: (id) => setState(() {
          _walletId = id;
          _walletError = null;
        }),
      ),
      _ => _walletField(
        label: switch (_kind) {
          WalletEntryKind.spend || WalletEntryKind.giveBack => l10n.fromWallet,
          _ => l10n.intoWallet,
        },
        walletId: _walletId,
        error: _walletError,
        onPicked: (id) => setState(() {
          _walletId = id;
          _walletError = null;
        }),
      ),
    };

    return MoneySheet(
      title: title,
      subtitle: subtitle,
      isDirty: _isDirty,
      trailing: _isEditing
          ? IconButton(
              tooltip: l10n.deleteEntry,
              onPressed: _delete,
              icon: Icon(Icons.delete_outline, color: c.spending),
            )
          : null,
      button: ElevatedButton(
        onPressed: _saving ? null : _save,
        child: ButtonLabel(
          _isEditing ? l10n.saveChanges : l10n.save,
          loading: _saving,
        ),
      ),
      children: [
        if (_hasPerson) ...[personField, const SizedBox(height: 16)],
        amountField,
        const SizedBox(height: 16),
        walletField,
        if (_kind == WalletEntryKind.transfer) ...[
          const SizedBox(height: 16),
          _walletField(
            label: l10n.to,
            walletId: _toWalletId,
            error: _toWalletError,
            pickerTitle: l10n.moveTo,
            excludeId: _walletId,
            onPicked: (id) => setState(() {
              _toWalletId = id;
              _toWalletError = null;
            }),
          ),
        ],
        const SizedBox(height: 16),
        LabeledField(
          label: l10n.date,
          field: FieldButton(
            leading: Icon(Icons.calendar_today_outlined, color: c.muted),
            label: friendlyDate(context.l10n, _date),
            onTap: _pickDate,
          ),
        ),
        const SizedBox(height: 16),
        LabeledField(
          label: _kind == WalletEntryKind.spend
              ? l10n.whatForOptional
              : l10n.noteOptional,
          field: TextField(
            controller: _note,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: switch (_kind) {
                WalletEntryKind.spend => l10n.spentNoteHint,
                WalletEntryKind.receive => l10n.receivedNoteHint,
                _ => null,
              },
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }
}

// A person: rename / delete

Future<void> showPersonEditor(BuildContext context, PersonModel person) =>
    showMoneySheet<void>(context, _PersonEditor(person: person), guarded: true);

class _PersonEditor extends StatefulWidget {
  final PersonModel person;

  const _PersonEditor({required this.person});

  @override
  State<_PersonEditor> createState() => _PersonEditorState();
}

class _PersonEditorState extends State<_PersonEditor> {
  late final _name = TextEditingController(text: widget.person.name);
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    setState(() => _error = name.isEmpty ? context.l10n.enterName : null);
    if (_error != null) return;

    final sameName = context.read<WalletsRepository>().people.any(
      (p) =>
          p.id != widget.person.id &&
          p.name.trim().toLowerCase() == name.toLowerCase(),
    );
    if (sameName) {
      final proceed = await confirmDialog(
        context,
        title: context.l10n.alreadyInList(name),
        message: context.l10n.samePersonNameBody,
        confirmLabel: context.l10n.saveAnyway,
        cancelLabel: context.l10n.goBack,
      );
      if (proceed != true || !mounted) return;
    }

    setState(() => _saving = true);
    try {
      await context.read<WalletsRepository>().renamePerson(
        widget.person.id,
        name,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _toastError(context, e);
    }
  }

  Future<void> _delete() async {
    final person = widget.person;
    final confirmed = await _confirmDelete(
      context,
      title: context.l10n.deleteNamed(person.name),
      message: context.l10n.deletePersonBody(person.name),
    );
    if (confirmed != true || !mounted) return;
    final navigator = Navigator.of(context);
    try {
      await context.read<WalletsRepository>().deletePerson(person.id);
      navigator.pop();
    } catch (e) {
      if (mounted) _toastError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MoneySheet(
      title: context.l10n.editPerson,
      isDirty: () => _name.text != widget.person.name,
      trailing: IconButton(
        tooltip: context.l10n.deletePerson,
        onPressed: _delete,
        icon: Icon(Icons.delete_outline, color: c.spending),
      ),
      button: ElevatedButton(
        onPressed: _saving ? null : _save,
        child: ButtonLabel(context.l10n.saveChanges, loading: _saving),
      ),
      children: [
        LabeledField(
          label: context.l10n.name,
          field: TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            maxLength: 60,
            decoration: InputDecoration(errorText: _error, counterText: ''),
          ),
        ),
      ],
    );
  }
}

// Correct a wallet's balance

Future<void> showCorrectBalanceSheet(
  BuildContext context,
  WalletModel wallet,
  double current,
) => showMoneySheet<void>(
  context,
  _CorrectBalanceSheet(wallet: wallet, current: current),
  guarded: true,
);

class _CorrectBalanceSheet extends StatefulWidget {
  final WalletModel wallet;
  final double current;

  const _CorrectBalanceSheet({required this.wallet, required this.current});

  @override
  State<_CorrectBalanceSheet> createState() => _CorrectBalanceSheetState();
}

class _CorrectBalanceSheetState extends State<_CorrectBalanceSheet> {
  late final _actual = TextEditingController(text: _plain(widget.current));
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _actual.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final actual = parseAmount(_actual.text);
    setState(() => _error = actual == null ? context.l10n.enterBalance : null);
    if (_error != null) return;
    setState(() => _saving = true);
    try {
      await context.read<WalletsRepository>().correctBalance(
        walletId: widget.wallet.id,
        current: widget.current,
        actual: actual!,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _toastError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final money = context.money;
    return MoneySheet(
      title: context.l10n.correctWallet(widget.wallet.name),
      isDirty: () => _actual.text != _plain(widget.current),
      subtitle: context.l10n.correctBalanceHelp(
        money.format(widget.current),
        widget.wallet.name,
      ),
      button: ElevatedButton(
        onPressed: _saving ? null : _save,
        child: ButtonLabel(context.l10n.saveBalance, loading: _saving),
      ),
      children: [
        LabeledField(
          label: context.l10n.realBalanceNow,
          field: AmountField(
            controller: _actual,
            errorText: _error,
            autofocus: true,
          ),
        ),
      ],
    );
  }
}
