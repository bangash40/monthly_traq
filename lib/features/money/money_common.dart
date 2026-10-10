import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/app_settings.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/services/wallet_ledger.dart';
import 'package:monthly_traq/services/wallets_repository.dart';
import 'package:monthly_traq/widgets/budget_sheet.dart';
import 'package:monthly_traq/widgets/ui.dart';
import 'package:monthly_traq/l10n/l10n.dart';

/// Every wallet's balance and what's owed to each person, rebuilt whenever
/// anything in the wallets changes. Call from `build`.
WalletLedger watchLedger(BuildContext context) =>
    context.watch<WalletsRepository>().ledger;

/// Parses what an [AmountField] holds ("12,500.50" → 12500.5); null when
/// it isn't a number.
double? parseAmount(String text) =>
    double.tryParse(text.replaceAll(',', '').trim());

/// A money input matching the budget sheet's: the currency symbol in front
/// and digits grouped as they're typed.
class AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  const AmountField({
    super.key,
    required this.controller,
    this.errorText,
    this.autofocus = false,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final symbol = context.select<TransactionsRepository, String>(
      (r) => r.currencySymbol,
    );
    final grouping = context.select<AppSettings, bool>(
      (s) => s.thousandsSeparator,
    );
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [GroupedNumberFormatter(grouping: grouping)],
      style: AppText.amountLarge.copyWith(fontSize: 26),
      decoration: InputDecoration(
        errorText: errorText,
        hintText: '0',
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 18, right: 10),
          child: Text(
            symbol,
            style: AppText.section.copyWith(fontSize: 21, color: c.muted),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
      onSubmitted: onSubmitted,
    );
  }
}

/// The frame every Money sheet shares: a title (and optional line under
/// it), content that scrolls when it doesn't fit, and the main button
/// pinned at the bottom above the keyboard.
class MoneySheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget button;

  /// Extra actions shown beside the title (e.g. delete).
  final Widget? trailing;

  /// Whether something was typed or changed. When it returns true, back
  /// and tapping outside ask before discarding it. Open such sheets with
  /// `showMoneySheet(guarded: true)` so a swipe can't skip the question.
  final bool Function()? isDirty;

  const MoneySheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    required this.button,
    this.trailing,
    this.isDirty,
  });

  @override
  Widget build(BuildContext context) {
    final isDirty = this.isDirty;
    if (isDirty == null) return _build(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (!isDirty() ||
            await confirmDialog(
                  context,
                  title: context.l10n.discardChangesTitle,
                  message: context.l10n.discardChangesBody,
                  confirmLabel: context.l10n.discard,
                  cancelLabel: context.l10n.keepEditing,
                  destructive: true,
                ) ==
                true) {
          navigator.pop();
        }
      },
      child: _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppText.section.copyWith(fontSize: 24),
                ),
              ),
              ?trailing,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: AppText.body.copyWith(color: c.muted)),
          ],
          const SizedBox(height: 18),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
          const SizedBox(height: 18),
          button,
        ],
      ),
    );
  }
}

/// Opens [sheet] from the bottom. A [guarded] sheet (one you type into)
/// can't be swiped away, so closing it always goes through its
/// [MoneySheet.isDirty] check.
Future<T?> showMoneySheet<T>(
  BuildContext context,
  Widget sheet, {
  bool guarded = false,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  enableDrag: !guarded,
  builder: (context) => sheet,
);

/// A two-button question: true for [confirmLabel], false or null for
/// [cancelLabel] or dismissing it.
Future<bool?> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,

  /// Defaults to "Cancel".
  String? cancelLabel,
  bool destructive = false,
}) => showDialog<bool>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(dialogContext, false),
        child: Text(cancelLabel ?? dialogContext.l10n.cancel),
      ),
      TextButton(
        onPressed: () => Navigator.pop(dialogContext, true),
        style: destructive
            ? TextButton.styleFrom(
                foregroundColor: dialogContext.colors.spending,
              )
            : null,
        child: Text(confirmLabel),
      ),
    ],
  ),
);

/// What the wallet picker returns: a wallet, or "no wallet".
class WalletChoice {
  final String? walletId;

  const WalletChoice(this.walletId);
}

/// Lets the person pick a wallet (with its balance); [allowNone] adds a
/// "No wallet" option. Null if dismissed.
Future<WalletChoice?> pickWallet(
  BuildContext context, {
  String? selectedId,
  bool allowNone = false,

  /// Defaults to "Which wallet?".
  String? title,
  String? excludeId,
}) {
  return showMoneySheet<WalletChoice>(
    context,
    _WalletPickerSheet(
      selectedId: selectedId,
      allowNone: allowNone,
      title: title ?? context.l10n.whichWallet,
      excludeId: excludeId,
    ),
  );
}

class _WalletPickerSheet extends StatelessWidget {
  final String? selectedId;
  final bool allowNone;
  final String title;
  final String? excludeId;

  const _WalletPickerSheet({
    required this.selectedId,
    required this.allowNone,
    required this.title,
    required this.excludeId,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ledger = watchLedger(context);
    final wallets = [
      for (final w in context.watch<WalletsRepository>().wallets)
        if (w.id != excludeId) w,
    ];

    Widget row({
      required Widget leading,
      required String label,
      String? value,
      required bool selected,
      required VoidCallback onTap,
    }) => InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppText.rowTitle.copyWith(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (value != null)
              Text(value, style: AppText.label.copyWith(color: c.muted)),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? c.accent : c.faint,
              size: 22,
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppText.section.copyWith(fontSize: 24)),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: GroupCard(
                children: [
                  for (final w in wallets)
                    row(
                      leading: IconTile(icon: w.icon, color: w.color, size: 40),
                      label: w.name,
                      value: context.money.format(ledger.of(w.id).total),
                      selected: w.id == selectedId,
                      onTap: () => Navigator.pop(context, WalletChoice(w.id)),
                    ),
                  if (allowNone)
                    row(
                      leading: IconTile(
                        icon: Icons.block,
                        color: c.muted,
                        size: 40,
                      ),
                      label: context.l10n.noWallet,
                      selected: selectedId == null,
                      onTap: () =>
                          Navigator.pop(context, const WalletChoice(null)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The color for other people's money in bars and legends: a calm blue,
/// not a warning — keeping someone's money is normal, not a problem.
const othersColor = Color(0xFF2A78D6);

/// "Rs. 3,000", or "−Rs. 3,000" below zero.
String signedMoney(MoneyFormatter money, double value) =>
    money.format(value, sign: value < 0 ? MoneySign.expense : MoneySign.none);

/// A field-like button showing a choice (a wallet, a person, a date), with
/// an error line under it when needed.
class FieldButton extends StatelessWidget {
  final Widget leading;
  final String label;

  /// Shows [label] muted, as a placeholder.
  final bool empty;
  final String? error;
  final VoidCallback onTap;

  const FieldButton({
    super.key,
    required this.leading,
    required this.label,
    required this.onTap,
    this.empty = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
            side: BorderSide(color: error != null ? c.spending : c.hairline),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.button),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  leading,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: AppText.rowTitle.copyWith(
                        fontSize: 16,
                        color: empty ? c.muted : c.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.expand_more, color: c.muted),
                ],
              ),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 6),
            child: Text(
              error!,
              style: AppText.caption.copyWith(color: c.spending),
            ),
          ),
      ],
    );
  }
}

/// A round initial for a person.
class PersonAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final bool muted;

  const PersonAvatar({
    super.key,
    required this.name,
    this.radius = 22,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final initial = name.trim().isEmpty
        ? '?'
        : name.trim().characters.first.toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: muted
          ? c.surfaceHigh
          : othersColor.withValues(alpha: 0.14),
      child: Text(
        initial,
        style: AppText.rowTitle.copyWith(
          color: muted ? c.muted : othersColor,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.75,
        ),
      ),
    );
  }
}

/// What the person picker returns: someone already added, or a new name to
/// add when the entry is saved.
class PersonChoice {
  final String? personId;
  final String? newName;

  const PersonChoice.existing(String this.personId) : newName = null;
  const PersonChoice.newPerson(String this.newName) : personId = null;
}

/// Lets the person pick whose money it is, or type someone new. Null if
/// dismissed.
Future<PersonChoice?> pickPerson(
  BuildContext context, {
  String? selectedId,

  /// Defaults to "Whose money?".
  String? title,
}) => showMoneySheet<PersonChoice>(
  context,
  _PersonPickerSheet(
    selectedId: selectedId,
    title: title ?? context.l10n.whoseMoney,
  ),
);

class _PersonPickerSheet extends StatefulWidget {
  final String? selectedId;
  final String title;

  const _PersonPickerSheet({required this.selectedId, required this.title});

  @override
  State<_PersonPickerSheet> createState() => _PersonPickerSheetState();
}

class _PersonPickerSheetState extends State<_PersonPickerSheet> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _addNew() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final people = context.read<WalletsRepository>().people;
    // Typing a name that's already there picks that person.
    final match = people
        .where((p) => p.name.toLowerCase() == name.toLowerCase())
        .firstOrNull;
    Navigator.pop(
      context,
      match != null
          ? PersonChoice.existing(match.id)
          : PersonChoice.newPerson(name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final repo = context.watch<WalletsRepository>();
    final ledger = repo.ledger;
    final people = repo.people;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: AppText.section.copyWith(fontSize: 24)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _name,
                  autofocus: people.isEmpty,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 60,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addNew(),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: context.l10n.someoneNewHint,
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: _name.text.trim().isEmpty ? null : _addNew,
                child: Text(context.l10n.add),
              ),
            ],
          ),
          if (people.isNotEmpty) ...[
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: GroupCard(
                  children: [
                    for (final p in people.reversed)
                      InkWell(
                        onTap: () =>
                            Navigator.pop(context, PersonChoice.existing(p.id)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              PersonAvatar(name: p.name, radius: 20),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  p.name,
                                  style: AppText.rowTitle.copyWith(
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (ledger.owedTo(p.id) > 0)
                                Text(
                                  money.format(ledger.owedTo(p.id)),
                                  style: AppText.label.copyWith(color: c.muted),
                                ),
                              const SizedBox(width: 8),
                              Icon(
                                p.id == widget.selectedId
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: p.id == widget.selectedId
                                    ? c.accent
                                    : c.faint,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// "Couldn't save" (or the sync timeout's own message) as a snackbar.
void toastSaveError(BuildContext context, Object error) {
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

/// An amount as an [AmountField] shows it: "12,500", or "12,500.50".
String plainAmount(double amount) => GroupedNumberFormatter.formatText(
  amount == amount.roundToDouble()
      ? amount.toStringAsFixed(0)
      : amount.toStringAsFixed(2),
);

/// "Today", "Tomorrow", "Yesterday", "Mon, 5 Oct", or "5 Oct 2025".
String friendlyDate(AppLocalizations l10n, DateTime date) {
  final now = DateTime.now();
  if (DateUtils.isSameDay(date, now)) return l10n.today;
  if (DateUtils.isSameDay(date, now.add(const Duration(days: 1)))) {
    return l10n.tomorrow;
  }
  if (DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))) {
    return l10n.yesterday;
  }
  return DateFormat(date.year == now.year ? 'EEE, d MMM' : 'd MMM y')
      .format(date);
}

/// A row of pill buttons, one of them selected.
class ChoicePills<T> extends StatelessWidget {
  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;

  const ChoicePills({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (option, label) in options)
          Material(
            color: option == value ? c.primary : c.surfaceHigh,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onChanged(option),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  label,
                  style: AppText.label.copyWith(
                    color: option == value ? c.onPrimary : c.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Lets the person pick an expense category to file a payment or saving
/// under; not-counted ones first, since that's where these usually go.
/// Returns the category id, or null if dismissed.
Future<String?> pickExpenseCategory(
  BuildContext context, {
  String? selectedId,
}) => pickCategory(context, selectedId: selectedId);

/// Like [pickExpenseCategory], for either kind of category.
Future<String?> pickCategory(
  BuildContext context, {
  String? selectedId,
  TransactionType type = TransactionType.expense,
}) => showMoneySheet<String>(
  context,
  _CategoryPicker(selectedId: selectedId, type: type),
);

class _CategoryPicker extends StatelessWidget {
  final String? selectedId;
  final TransactionType type;

  const _CategoryPicker({required this.selectedId, required this.type});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final all = [
      for (final cat in context.watch<TransactionsRepository>().categories)
        if (cat.type == type) cat,
    ];
    final categories = <CategoryModel>[
      ...all.where((cat) => cat.excludeFromBudget),
      ...all.where((cat) => !cat.excludeFromBudget),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.category,
            style: AppText.section.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: GroupCard(
                children: [
                  for (final cat in categories)
                    InkWell(
                      onTap: () => Navigator.pop(context, cat.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            IconTile(
                              icon: cat.icon,
                              color: cat.color,
                              size: 40,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                cat.name,
                                style: AppText.rowTitle.copyWith(fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (cat.excludeFromBudget) ...[
                              TagBadge(context.l10n.notCounted),
                              const SizedBox(width: 8),
                            ],
                            Icon(
                              cat.id == selectedId
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: cat.id == selectedId ? c.accent : c.faint,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
