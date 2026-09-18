import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/add_category_dialog.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final TransactionModel? existing;

  const AddEditTransactionScreen({super.key, this.existing});

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  late final _titleController = TextEditingController(
    text: widget.existing?.title,
  );

  late TransactionType _type = widget.existing?.type ?? TransactionType.expense;
  late String? _categoryId = widget.existing?.categoryId;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openAmountSheet());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _formatAmountForInput(double amount) {
    if (amount == amount.roundToDouble()) return amount.toInt().toString();
    return amount.toString();
  }

  Future<void> _openAmountSheet() async {
    final repo = context.read<TransactionsRepository>();
    final category = repo.categories.firstWhere(
      (c) => c.id == _categoryId,
      orElse: () => const CategoryModel(
        id: '',
        name: '',
        icon: Icons.category,
        color: Colors.grey,
      ),
    );
    if (category.id.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _AmountEntrySheet(
          category: category,
          titleController: _titleController,
          initialAmount: widget.existing != null
              ? _formatAmountForInput(widget.existing!.amount)
              : '0',
          initialDate: widget.existing?.date ?? DateTime.now(),
          isEditing: _isEditing,
          onSave: (amount, date) => _performSave(amount: amount, date: date),
        );
      },
    );
  }

  Future<void> _performSave({
    required String amount,
    required DateTime date,
  }) async {
    final amountValue = double.parse(amount);
    final repo = context.read<TransactionsRepository>();
    final title = _titleController.text.trim();

    if (_isEditing) {
      await repo.updateTransaction(
        widget.existing!.copyWith(
          title: title,
          amount: amountValue,
          type: _type,
          categoryId: _categoryId,
          date: date,
        ),
      );
    } else {
      await repo.addTransaction(
        TransactionModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: title,
          amount: amountValue,
          type: _type,
          categoryId: _categoryId,
          date: date,
        ),
      );
    }

    if (!mounted) return;
    Navigator.pop(context); // close the amount sheet
    Navigator.pop(context); // close this screen
  }

  Future<void> _delete() async {
    try {
      await context.read<TransactionsRepository>().deleteTransaction(
        widget.existing!.id,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not delete: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionsRepository>();
    final categories = repo.categories.where((c) => c.type == _type).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit' : 'Add',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SegmentedButton<TransactionType>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Expense'),
                      icon: Icon(Icons.arrow_upward_rounded),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Income'),
                      icon: Icon(Icons.arrow_downward_rounded),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _type = selection.first;
                      _categoryId = null;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              Text('Category', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              _CategoryGrid(
                categories: categories,
                selectedId: _categoryId,
                onSelect: (id) {
                  setState(() => _categoryId = id);
                  _openAmountSheet();
                },
                onAddCategory: () async {
                  final repo = context.read<TransactionsRepository>();
                  final created = await showAddCategoryDialog(
                    context,
                    repo,
                    type: _type,
                  );
                  if (created != null) {
                    setState(() => _categoryId = created.id);
                    _openAmountSheet();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountEntrySheet extends StatefulWidget {
  final CategoryModel category;
  final TextEditingController titleController;
  final String initialAmount;
  final DateTime initialDate;
  final bool isEditing;
  final Future<void> Function(String amount, DateTime date) onSave;

  const _AmountEntrySheet({
    required this.category,
    required this.titleController,
    required this.initialAmount,
    required this.initialDate,
    required this.isEditing,
    required this.onSave,
  });

  @override
  State<_AmountEntrySheet> createState() => _AmountEntrySheetState();
}

const _kOperators = '+-×÷';

class _AmountEntrySheetState extends State<_AmountEntrySheet> {
  late String _amount = widget.initialAmount;
  late DateTime _date = widget.initialDate;
  String? _amountError;
  bool _isSaving = false;

  static const _maxDigits = 12;

  int _lastOperatorIndex() {
    for (var i = _amount.length - 1; i >= 0; i--) {
      if (_kOperators.contains(_amount[i])) return i;
    }
    return -1;
  }

  String get _lastSegment {
    final index = _lastOperatorIndex();
    return index == -1 ? _amount : _amount.substring(index + 1);
  }

  void _appendDigit(String digit) {
    setState(() {
      final last = _lastSegment;
      if (last == '0') {
        _amount = _amount.substring(0, _amount.length - 1) + digit;
      } else if (last.replaceAll('.', '').length < _maxDigits) {
        _amount += digit;
      }
    });
  }

  void _appendOperator(String op) {
    setState(() {
      if (_amount.isEmpty) return;
      final lastChar = _amount[_amount.length - 1];
      if (_kOperators.contains(lastChar)) {
        _amount = _amount.substring(0, _amount.length - 1) + op;
      } else {
        _amount += op;
      }
    });
  }

  void _appendDecimal() {
    if (_lastSegment.contains('.')) return;
    setState(() => _amount += '.');
  }

  void _backspace() {
    setState(() {
      if (_amount.length <= 1) {
        _amount = '0';
      } else {
        _amount = _amount.substring(0, _amount.length - 1);
      }
    });
  }

  String _formatNumber(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  /// Evaluates a `+ - × ÷` expression left-to-right, giving `×`/`÷` the
  /// usual precedence over `+`/`-`. A dangling trailing operator (the user
  /// tapped an operator but never finished the second number) is dropped so
  /// "evaluate whatever's valid so far" never throws.
  double _evaluateExpression(String expression) {
    var expr = expression;
    while (expr.isNotEmpty && _kOperators.contains(expr[expr.length - 1])) {
      expr = expr.substring(0, expr.length - 1);
    }
    if (expr.isEmpty) return 0;

    final tokens = <String>[];
    var current = '';
    for (final char in expr.split('')) {
      if (_kOperators.contains(char)) {
        tokens.add(current);
        tokens.add(char);
        current = '';
      } else {
        current += char;
      }
    }
    tokens.add(current);

    final pass1 = <String>[tokens[0]];
    for (var i = 1; i < tokens.length; i += 2) {
      final op = tokens[i];
      final rhs = double.parse(tokens[i + 1]);
      if (op == '×' || op == '÷') {
        final lhs = double.parse(pass1.removeLast());
        final result = op == '×' ? lhs * rhs : (rhs == 0 ? 0.0 : lhs / rhs);
        pass1.add(_formatNumber(result));
      } else {
        pass1.add(op);
        pass1.add(tokens[i + 1]);
      }
    }

    var result = double.parse(pass1[0]);
    for (var i = 1; i < pass1.length; i += 2) {
      final op = pass1[i];
      final rhs = double.parse(pass1[i + 1]);
      result = op == '+' ? result + rhs : result - rhs;
    }
    return result;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  /// The tick button is double-duty: with a pending `+ - × ÷` operator in
  /// the expression, the first tap evaluates it (like a calculator's "=");
  /// only once the expression is a plain number does a tap actually save.
  Future<void> _handleTick() async {
    if (_lastOperatorIndex() != -1) {
      setState(() {
        _amount = _formatNumber(_evaluateExpression(_amount));
        _amountError = null;
      });
      return;
    }
    await _handleSave();
  }

  Future<void> _handleSave() async {
    final amountValue = double.tryParse(_amount);

    setState(() {
      _amountError = (amountValue == null || amountValue <= 0)
          ? 'Enter a valid amount'
          : null;
    });
    if (_amountError != null) return;

    setState(() => _isSaving = true);
    try {
      await widget.onSave(_amount, _date);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save: $e')));
      setState(() => _isSaving = false);
    }
  }

  String get _dateLabel {
    final today = DateTime.now();
    final isToday =
        _date.year == today.year &&
        _date.month == today.month &&
        _date.day == today.day;
    return isToday ? 'Today' : DateFormat('MMM d').format(_date);
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: widget.category.color.withValues(
                      alpha: 0.18,
                    ),
                    foregroundColor: widget.category.color,
                    child: Icon(widget.category.icon, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.category.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  child: Text(
                    _amount,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (_amountError != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _amountError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              TextField(
                controller: widget.titleController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  hintText: 'Enter a title (optional)...',
                  prefixIcon: const Icon(Icons.edit_outlined, size: 18),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              _KeypadRow(
                children: [
                  _KeyButton(label: '7', onTap: () => _appendDigit('7')),
                  _KeyButton(label: '8', onTap: () => _appendDigit('8')),
                  _KeyButton(label: '9', onTap: () => _appendDigit('9')),
                  _KeyButton(label: _dateLabel, onTap: _pickDate),
                ],
              ),
              _KeypadRow(
                children: [
                  _KeyButton(label: '4', onTap: () => _appendDigit('4')),
                  _KeyButton(label: '5', onTap: () => _appendDigit('5')),
                  _KeyButton(label: '6', onTap: () => _appendDigit('6')),
                  Row(
                    children: [
                      Expanded(
                        child: _KeyButton(
                          label: '+',
                          onTap: () => _appendOperator('+'),
                        ),
                      ),
                      Expanded(
                        child: _KeyButton(
                          label: '−',
                          onTap: () => _appendOperator('-'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _KeypadRow(
                children: [
                  _KeyButton(label: '1', onTap: () => _appendDigit('1')),
                  _KeyButton(label: '2', onTap: () => _appendDigit('2')),
                  _KeyButton(label: '3', onTap: () => _appendDigit('3')),
                  Row(
                    children: [
                      Expanded(
                        child: _KeyButton(
                          label: '×',
                          onTap: () => _appendOperator('×'),
                        ),
                      ),
                      Expanded(
                        child: _KeyButton(
                          label: '÷',
                          onTap: () => _appendOperator('÷'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _KeypadRow(
                children: [
                  _KeyButton(label: '.', onTap: _appendDecimal),
                  _KeyButton(label: '0', onTap: () => _appendDigit('0')),
                  _KeyButton(icon: Icons.backspace_outlined, onTap: _backspace),
                  _KeyButton(
                    label: _lastOperatorIndex() != -1 ? '=' : null,
                    icon: _lastOperatorIndex() != -1 ? null : Icons.check,
                    isPrimary: true,
                    isLoading: _isSaving,
                    onTap: _isSaving ? null : _handleTick,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _kKeyRowHeight = 56.0;

class _KeypadRow extends StatelessWidget {
  final List<Widget> children;

  const _KeypadRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kKeyRowHeight,
      child: Row(
        children: [for (final child in children) Expanded(child: child)],
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback? onTap;

  const _KeyButton({
    this.label,
    this.icon,
    this.isPrimary = false,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = themeAccent(context);
    final foreground = isPrimary
        ? Colors.black
        : Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: isPrimary
            ? accent
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : icon != null
                ? Icon(icon, color: foreground, size: 20)
                : FittedBox(
                    child: Text(
                      label ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: foreground,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onAddCategory;

  const _CategoryGrid({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
    required this.onAddCategory,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 4,
      childAspectRatio: 0.82,
      children: [
        for (final category in categories)
          _CategoryTile(
            category: category,
            isSelected: category.id == selectedId,
            onTap: () => onSelect(category.id),
          ),
        _AddCategoryTile(onTap: onAddCategory),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: category.color.withValues(alpha: 0.18),
              border: isSelected
                  ? Border.all(color: category.color, width: 2.5)
                  : null,
            ),
            child: Icon(category.icon, color: category.color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? themeAccent(context)
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCategoryTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddCategoryTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),
            child: Icon(Icons.add, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            'Add category',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
}
