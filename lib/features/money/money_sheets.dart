import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
            ? error.toString()
            : 'Couldn\'t save. Please try again.',
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
      _nameError = name.isEmpty ? 'Give the wallet a name' : null;
      _amountError = opening == null
          ? 'Enter an amount, or leave it empty'
          : null;
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
        title: 'You already have $name',
        message: _isEditing
            ? 'Another wallet is called $name. Use the same name for both?'
            : 'Add another wallet with the same name?',
        confirmLabel: _isEditing ? 'Save anyway' : 'Add anyway',
        cancelLabel: 'Go back',
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
      title: 'Delete ${existing.name}?',
      message:
          'Everything recorded in it is deleted too, including money you '
          'received in it from others and moves to or from it.',
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
      title: _isEditing ? 'Edit wallet' : 'New wallet',
      isDirty: _isDirty,
      trailing: _isEditing
          ? IconButton(
              tooltip: 'Delete wallet',
              onPressed: _delete,
              icon: Icon(Icons.delete_outline, color: c.spending),
            )
          : null,
      button: ElevatedButton(
        onPressed: _saving ? null : _save,
        child: ButtonLabel(
          _isEditing ? 'Save changes' : 'Add wallet',
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
              hintText: 'e.g. JazzCash',
              errorText: _nameError,
              counterText: '',
            ),
          ),
        ),
        const SizedBox(height: 16),
        LabeledField(
          label: _isEditing
              ? 'Your own money when added'
              : 'Your own money in it now',
          field: AmountField(controller: _opening, errorText: _amountError),
        ),
        const SizedBox(height: 6),
        Text(
          'Only what\'s yours. Money you\'re keeping for someone is added '
          'next with "Received", on top of this.',
          style: AppText.label.copyWith(color: c.muted),
        ),
        const SizedBox(height: 16),
        Text(
          'Icon',
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

String _dateLabel(DateTime date) {
  final now = DateTime.now();
  if (DateUtils.isSameDay(date, now)) return 'Today';
  if (DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))) {
    return 'Yesterday';
  }
  return DateFormat(date.year == now.year ? 'EEE, d MMM' : 'd MMM y')
      .format(date);
}

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
    title: 'Delete this correction?',
    message:
        'The wallet goes back to the balance it showed before you corrected '
        'it.',
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
  confirmLabel: 'Delete',
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
    setState(() {
      _personError = _hasPerson && _person == null
          ? 'Pick whose money it is'
          : null;
      _walletError = _walletId == null ? 'Pick a wallet' : null;
      _toWalletError = _kind == WalletEntryKind.transfer
          ? _toWalletId == null
                ? 'Pick where it went'
                : _toWalletId == _walletId
                ? 'Pick a different wallet'
                : null
          : null;
      _amountError = amount == null || amount <= 0
          ? 'Enter an amount above zero'
          : _kind == WalletEntryKind.giveBack &&
                _person != null &&
                amount > canGiveBack + 0.005
          ? canGiveBack <= 0
                ? 'You aren\'t keeping any of $name\'s money'
                : 'You\'re keeping ${money.format(canGiveBack)} for $name'
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
        final walletName = repo.walletById(_walletId)?.name ?? 'This wallet';
        final proceed = await confirmDialog(
          context,
          title: 'More than $walletName has',
          message:
              '$walletName has ${signedMoney(money, available)}. Saving '
              'this takes it to ${signedMoney(money, available - amount)}.',
          confirmLabel: 'Save anyway',
          cancelLabel: 'Go back',
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
      title: 'Delete this entry?',
      message:
          'Only for an entry made by mistake. The wallet changes as if it '
          'never happened.',
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
    String pickerTitle = 'Which wallet?',
  }) {
    final c = context.colors;
    final wallet = context.watch<WalletsRepository>().walletById(walletId);
    return LabeledField(
      label: label,
      field: FieldButton(
        leading: wallet != null
            ? IconTile(icon: wallet.icon, color: wallet.color, size: 36)
            : Icon(Icons.account_balance_wallet_outlined, color: c.muted),
        label: wallet?.name ?? 'Choose a wallet',
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

    final (String title, String? subtitle) = switch (_kind) {
      WalletEntryKind.spend => (
        _isEditing ? 'Edit spending' : 'Spent',
        _isEditing ? null : 'Money you spent from a wallet.',
      ),
      WalletEntryKind.add => (
        _isEditing ? 'Edit added money' : 'Add your money',
        _isEditing ? null : 'Money of your own you put into a wallet.',
      ),
      WalletEntryKind.receive => (
        _isEditing ? 'Edit received money' : 'Received to keep',
        _isEditing
            ? null
            : 'Money someone gave you to keep. It\'s theirs, not yours, '
                  'until you send it back.',
      ),
      WalletEntryKind.giveBack => (
        _isEditing ? 'Edit money sent back' : 'Send back',
        name == null
            ? 'Money you returned to someone.'
            : canGiveBack > 0
            ? 'You\'re keeping ${money.format(canGiveBack)} for $name.'
            : 'You aren\'t keeping any of $name\'s money.',
      ),
      WalletEntryKind.transfer => (
        _isEditing ? 'Edit move' : 'Move money',
        _isEditing ? null : 'From one of your wallets to another.',
      ),
      WalletEntryKind.adjust => ('Correction', null),
    };

    final personField = LabeledField(
      label: _kind == WalletEntryKind.receive ? 'From' : 'To',
      field: FieldButton(
        leading: name != null
            ? PersonAvatar(name: name, radius: 18)
            : Icon(Icons.person_outline, color: c.muted),
        label: name ?? 'Choose someone',
        empty: name == null,
        error: _personError,
        onTap: () async {
          final choice = await pickPerson(
            context,
            selectedId: _person?.personId,
            title: _kind == WalletEntryKind.receive
                ? 'Whose money?'
                : 'Send back to',
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
      label: 'Amount',
      field: AmountField(
        controller: _amount,
        errorText: _amountError,
        autofocus: !_isEditing && (!_hasPerson || _person != null),
      ),
    );

    final walletField = switch (_kind) {
      WalletEntryKind.transfer => _walletField(
        label: 'From',
        walletId: _walletId,
        error: _walletError,
        pickerTitle: 'Move from',
        onPicked: (id) => setState(() {
          _walletId = id;
          _walletError = null;
        }),
      ),
      _ => _walletField(
        label: switch (_kind) {
          WalletEntryKind.spend || WalletEntryKind.giveBack => 'From wallet',
          _ => 'Into wallet',
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
              tooltip: 'Delete entry',
              onPressed: _delete,
              icon: Icon(Icons.delete_outline, color: c.spending),
            )
          : null,
      button: ElevatedButton(
        onPressed: _saving ? null : _save,
        child: ButtonLabel(
          _isEditing ? 'Save changes' : 'Save',
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
            label: 'To',
            walletId: _toWalletId,
            error: _toWalletError,
            pickerTitle: 'Move to',
            excludeId: _walletId,
            onPicked: (id) => setState(() {
              _toWalletId = id;
              _toWalletError = null;
            }),
          ),
        ],
        const SizedBox(height: 16),
        LabeledField(
          label: 'Date',
          field: FieldButton(
            leading: Icon(Icons.calendar_today_outlined, color: c.muted),
            label: _dateLabel(_date),
            onTap: _pickDate,
          ),
        ),
        const SizedBox(height: 16),
        LabeledField(
          label: _kind == WalletEntryKind.spend
              ? 'What for (optional)'
              : 'Note (optional)',
          field: TextField(
            controller: _note,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: switch (_kind) {
                WalletEntryKind.spend => 'e.g. Bike repair',
                WalletEntryKind.receive => 'e.g. Keep it until he asks',
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
    setState(() => _error = name.isEmpty ? 'Enter a name' : null);
    if (_error != null) return;

    final sameName = context.read<WalletsRepository>().people.any(
      (p) =>
          p.id != widget.person.id &&
          p.name.trim().toLowerCase() == name.toLowerCase(),
    );
    if (sameName) {
      final proceed = await confirmDialog(
        context,
        title: '$name is already in your list',
        message:
            'Two people with the same name are easy to mix up. Use it '
            'anyway?',
        confirmLabel: 'Save anyway',
        cancelLabel: 'Go back',
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
      title: 'Delete ${person.name}?',
      message:
          'Everything received from and sent back to ${person.name} is '
          'deleted too, and your wallets change as if none of it happened.',
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
      title: 'Edit person',
      isDirty: () => _name.text != widget.person.name,
      trailing: IconButton(
        tooltip: 'Delete person',
        onPressed: _delete,
        icon: Icon(Icons.delete_outline, color: c.spending),
      ),
      button: ElevatedButton(
        onPressed: _saving ? null : _save,
        child: ButtonLabel('Save changes', loading: _saving),
      ),
      children: [
        LabeledField(
          label: 'Name',
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
    setState(() => _error = actual == null ? 'Enter the balance' : null);
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
      title: 'Correct ${widget.wallet.name}',
      isDirty: () => _actual.text != _plain(widget.current),
      subtitle:
          'The app shows ${money.format(widget.current)}. Enter what your '
          '${widget.wallet.name} actually has, and the difference is recorded.',
      button: ElevatedButton(
        onPressed: _saving ? null : _save,
        child: ButtonLabel('Save balance', loading: _saving),
      ),
      children: [
        LabeledField(
          label: 'Real balance now',
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
