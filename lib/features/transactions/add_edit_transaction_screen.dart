import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/haptics.dart';
import 'package:monthly_traq/app/app_settings.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/settings/categories_screen.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/calculator.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/category_editor_sheet.dart';
import 'package:monthly_traq/widgets/delete_transaction.dart';
import 'package:monthly_traq/widgets/motion.dart';
import 'package:monthly_traq/widgets/ui.dart';

/// Adds a transaction, or edits [existing]: amount on a calculator keypad,
/// a category, a date and an optional note, all on one screen.
class AddEditTransactionScreen extends StatefulWidget {
  final TransactionModel? existing;

  const AddEditTransactionScreen({super.key, this.existing});

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  /// Categories shown before "More" collapses the rest.
  static const _collapsedCount = 9;

  late TransactionType _type = widget.existing?.type ?? TransactionType.expense;
  late String? _categoryId = widget.existing?.categoryId;
  late final Calculator _calc = widget.existing != null
      ? Calculator.fromAmount(widget.existing!.amount)
      : Calculator();
  late DateTime _date = widget.existing?.date ?? DateTime.now();
  late String _note = widget.existing?.title ?? '';
  bool _showAllCategories = false;
  bool _isSaving = false;

  /// True for a moment after saving, while the button shows "Saved".
  bool _justSaved = false;
  String? _error;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    // When editing into a category past the first row or two, show them
    // all so the selection is visible.
    final repo = context.read<TransactionsRepository>();
    final index = _categoriesFor(repo).indexWhere((c) => c.id == _categoryId);
    _showAllCategories = index >= _collapsedCount;
  }

  List<CategoryModel> _categoriesFor(TransactionsRepository repo) =>
      repo.categories.where((c) => c.type == _type).toList();

  void _press(void Function() edit) {
    haptic(context, Haptic.tick);
    setState(() {
      edit();
      _error = null;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(now.year - 2),
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

  Future<void> _editNote() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _NoteSheet(initial: _note),
    );
    if (result != null) setState(() => _note = result);
  }

  Future<void> _newCategory() async {
    final created = await showCategoryEditor(context, type: _type);
    if (created != null && mounted) {
      setState(() {
        _categoryId = created.id;
        _showAllCategories = true;
      });
    }
  }

  void _editCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoriesScreen(initialType: _type),
      ),
    );
  }

  Future<void> _save() async {
    final amount = _calc.value;
    if (amount <= 0) {
      setState(() => _error = 'Enter an amount above zero');
      return;
    }
    if (_categoryId == null) {
      setState(() => _error = 'Pick a category');
      return;
    }

    setState(() => _isSaving = true);
    final repo = context.read<TransactionsRepository>();
    try {
      final existing = widget.existing;
      if (existing != null) {
        await repo.updateTransaction(
          existing.copyWith(
            title: _note.trim(),
            amount: amount,
            type: _type,
            categoryId: _categoryId,
            date: _date,
          ),
        );
      } else {
        await repo.addTransaction(
          TransactionModel(
            id: '',
            title: _note.trim(),
            amount: amount,
            type: _type,
            categoryId: _categoryId,
            date: _date,
          ),
        );
      }
      if (!mounted) return;
      // A brief "Saved" tick on the button before closing, so it's clear
      // the entry went in.
      haptic(context, Haptic.success);
      setState(() => _justSaved = true);
      await Future<void>.delayed(
        Motion.of(context, const Duration(milliseconds: 450)),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save: $e')));
    }
  }

  Future<void> _delete() async {
    final navigator = Navigator.of(context);
    final deleted = await deleteTransactionWithUndo(context, widget.existing!);
    if (deleted && mounted) navigator.pop();
  }

  String get _dateLabel {
    final now = DateTime.now();
    if (DateUtils.isSameDay(_date, now)) return 'Today';
    if (DateUtils.isSameDay(_date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return DateFormat(_date.year == now.year ? 'MMM d' : 'MMM d, y')
        .format(_date);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final repo = context.watch<TransactionsRepository>();
    final money = context.money;
    final grouping = context.select<AppSettings, bool>(
      (s) => s.thousandsSeparator,
    );
    final value = _calc.value;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                const BackCircleButton(icon: Icons.close, tooltip: 'Close'),
                const SizedBox(width: 12),
                Expanded(
                  child: AppSegmented<TransactionType>(
                    value: _type,
                    segments: const [
                      AppSegment(TransactionType.expense, 'Expense'),
                      AppSegment(TransactionType.income, 'Income'),
                    ],
                    onChanged: (type) => setState(() {
                      if (type == _type) return;
                      _type = type;
                      _categoryId = null;
                      _showAllCategories = false;
                      _error = null;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                if (_isEditing)
                  Tooltip(
                    message: 'Delete',
                    child: Material(
                      color: c.tint(c.spendingFill),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _delete,
                        child: SizedBox.square(
                          dimension: 48,
                          child: Icon(Icons.delete_outline, color: c.spending),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              children: [
                SizedBox(
                  height: 22,
                  child: _calc.hasOperator
                      ? Text(
                          _calc.display(grouping: grouping),
                          textAlign: TextAlign.center,
                          style: AppText.tabular(
                            AppText.rowTitle.copyWith(
                              color: c.muted,
                              fontSize: 17,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 4),
                Semantics(
                  liveRegion: true,
                  label: 'Amount',
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      money.format(
                        value,
                        sign: value < 0 ? MoneySign.expense : MoneySign.none,
                      ),
                      style: AppText.display.copyWith(
                        color: value < 0 ? c.spending : c.ink,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Chip(
                      icon: Icons.calendar_today_outlined,
                      label: _dateLabel,
                      onTap: _pickDate,
                    ),
                    _Chip(
                      icon: Icons.edit_note,
                      label: _note.trim().isEmpty ? 'Add a note' : _note.trim(),
                      muted: _note.trim().isEmpty,
                      onTap: _editNote,
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: AppText.rowTitle.copyWith(color: c.spending),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Category',
                        style: AppText.section.copyWith(color: c.muted),
                      ),
                    ),
                    TextButton(
                      onPressed: _editCategories,
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _CategoryGrid(
                  categories: _categoriesFor(repo),
                  selectedId: _categoryId,
                  collapsed: !_showAllCategories,
                  collapsedCount: _collapsedCount,
                  onSelect: (id) {
                    haptic(context, Haptic.tick);
                    setState(() {
                      _categoryId = id;
                      _error = null;
                    });
                  },
                  onMore: () => setState(() => _showAllCategories = true),
                  onNew: _newCategory,
                ),
              ],
            ),
          ),
          _Keypad(
            calc: _calc,
            onPress: _press,
            isSaving: _isSaving,
            justSaved: _justSaved,
            saveLabel: _isEditing
                ? 'Save changes'
                : _type == TransactionType.income
                ? 'Save income'
                : 'Save expense',
            onSave: _save,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool muted;
  final VoidCallback onTap;

  const _Chip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surface,
      shape: StadiumBorder(side: BorderSide(color: c.hairline)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: muted ? c.muted : c.ink),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.rowTitle.copyWith(
                    fontSize: 16,
                    color: muted ? c.muted : c.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedId;
  final bool collapsed;
  final int collapsedCount;
  final ValueChanged<String> onSelect;
  final VoidCallback onMore;
  final VoidCallback onNew;

  const _CategoryGrid({
    required this.categories,
    required this.selectedId,
    required this.collapsed,
    required this.collapsedCount,
    required this.onSelect,
    required this.onMore,
    required this.onNew,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final showMore = collapsed && categories.length > collapsedCount + 1;
    final shown = showMore ? categories.take(collapsedCount) : categories;

    // Five columns whose height follows their content, so a larger text
    // size grows the rows instead of overflowing them.
    const columns = 5;
    const spacing = 10.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        Widget tile(Widget child) => SizedBox(width: width, child: child);

        return Wrap(
          spacing: spacing,
          runSpacing: 14,
          children: [
            for (final category in shown)
              tile(
                _CategoryTile(
                  icon: category.icon,
                  label: category.name,
                  color: category.color,
                  background: c.tint(category.color),
                  selected: category.id == selectedId,
                  onTap: () => onSelect(category.id),
                ),
              ),
            tile(
              showMore
                  ? _CategoryTile(
                      icon: Icons.more_horiz,
                      label: 'More',
                      color: c.muted,
                      background: c.surfaceHigh,
                      onTap: onMore,
                    )
                  : _CategoryTile(
                      icon: Icons.add,
                      label: 'New',
                      color: c.accent,
                      background: c.primarySoft,
                      onTap: onNew,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected ? color : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppText.label.copyWith(
                color: selected ? c.ink : c.muted,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  final Calculator calc;
  final void Function(void Function() edit) onPress;
  final bool isSaving;
  final bool justSaved;
  final String saveLabel;
  final VoidCallback onSave;

  const _Keypad({
    required this.calc,
    required this.onPress,
    required this.isSaving,
    required this.justSaved,
    required this.saveLabel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    Widget digit(String d) =>
        _Key(label: d, onTap: () => onPress(() => calc.digit(d)));
    Widget op(String o, String shown, String name) => _Key(
      label: shown,
      semanticLabel: name,
      isOperator: true,
      onTap: () => onPress(() => calc.operator(o)),
    );

    final rows = [
      [digit('1'), digit('2'), digit('3'), op('÷', '÷', 'Divide')],
      [digit('4'), digit('5'), digit('6'), op('×', '×', 'Multiply')],
      [digit('7'), digit('8'), digit('9'), op('-', '−', 'Minus')],
      [
        _Key(
          label: '.',
          semanticLabel: 'Decimal point',
          onTap: () => onPress(calc.decimal),
        ),
        digit('0'),
        _Key(
          icon: Icons.backspace_outlined,
          semanticLabel: 'Delete digit',
          onTap: () => onPress(calc.backspace),
          onLongPress: () => onPress(calc.clear),
        ),
        op('+', '+', 'Plus'),
      ],
    ];

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
        border: Border(top: BorderSide(color: c.hairline)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final row in rows)
              Row(children: [for (final key in row) Expanded(child: key)]),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  // Stays in its normal color while showing "Saved".
                  onPressed: justSaved ? () {} : (isSaving ? null : onSave),
                  child: AnimatedSwitcher(
                    duration: Motion.of(context, Motion.short),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: Tween(begin: 0.85, end: 1.0).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: justSaved
                        ? const ButtonLabel(
                            'Saved',
                            key: ValueKey('saved'),
                            icon: Icons.check_circle,
                          )
                        : ButtonLabel(
                            saveLabel,
                            key: const ValueKey('save'),
                            loading: isSaving,
                            icon: Icons.check,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final String? semanticLabel;
  final bool isOperator;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _Key({
    this.label,
    this.icon,
    this.semanticLabel,
    this.isOperator = false,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = isOperator ? c.accent : c.ink;

    return Padding(
      padding: const EdgeInsets.all(3.5),
      child: Semantics(
        button: true,
        label: semanticLabel ?? label,
        excludeSemantics: true,
        child: Material(
          color: isOperator ? c.primarySoft : c.surfaceHigh,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.button),
            onTap: onTap,
            onLongPress: onLongPress,
            child: SizedBox(
              height: 50,
              child: Center(
                child: icon != null
                    ? Icon(icon, color: color, size: 24)
                    : Text(
                        label!,
                        style: AppText.section.copyWith(
                          fontSize: isOperator ? 24 : 22,
                          color: color,
                          fontWeight: isOperator
                              ? FontWeight.w700
                              : FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Edits the note shown on the transaction ("Groceries at Imtiaz").
class _NoteSheet extends StatefulWidget {
  final String initial;

  const _NoteSheet({required this.initial});

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          Text('Note', style: AppText.section.copyWith(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            'Shown as the transaction\'s name. Leave it empty to use the '
            'category name.',
            style: AppText.body.copyWith(color: c.muted),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 100,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'e.g. Groceries at Imtiaz',
              counterText: '',
            ),
            onSubmitted: (value) => Navigator.pop(context, value.trim()),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _controller.text.trim()),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
