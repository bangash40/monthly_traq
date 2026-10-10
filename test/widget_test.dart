import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/widgets/budget_sheet.dart';
import 'package:monthly_traq/widgets/settings_rows.dart';
import 'package:monthly_traq/widgets/transaction_rows.dart';
import 'package:monthly_traq/widgets/ui.dart';
import 'package:monthly_traq/l10n/app_localizations.dart';

/// Pumps [child] inside the app's theme with a money formatter, the same
/// way the real app provides them — no Firebase needed.
Future<void> pumpInApp(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  MoneyFormatter money = const MoneyFormatter(),
}) {
  return tester.pumpWidget(
    Provider<MoneyFormatter>.value(
      value: money,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: themeById('indigo').themeData(brightness),
        home: Scaffold(body: ListView(children: [child])),
      ),
    ),
  );
}

const food = CategoryModel(
  id: 'food',
  name: 'Food',
  icon: Icons.restaurant,
  color: Color(0xFFEB6834),
);

TransactionModel tx(double amount, TransactionType type, {String title = ''}) =>
    TransactionModel(
      id: 't',
      title: title,
      amount: amount,
      type: type,
      categoryId: 'food',
      date: DateTime(2026, 9, 18),
    );

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  group('TransactionRow', () {
    testWidgets('shows spending with a minus and income with a plus', (
      tester,
    ) async {
      await pumpInApp(
        tester,
        Column(
          children: [
            TransactionRow(
              transaction: tx(
                3450,
                TransactionType.expense,
                title: 'Groceries',
              ),
              category: food,
            ),
            TransactionRow(
              transaction: tx(120000, TransactionType.income, title: 'Salary'),
              category: food,
            ),
          ],
        ),
      );
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('−Rs. 3,450'), findsOneWidget);
      expect(find.text('+Rs. 120,000'), findsOneWidget);
    });

    testWidgets('falls back to the category name without a title', (
      tester,
    ) async {
      await pumpInApp(
        tester,
        TransactionRow(
          transaction: tx(500, TransactionType.expense),
          category: food,
          subtitle: 'Food · Today',
        ),
      );
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Food · Today'), findsOneWidget);
    });

    testWidgets('follows the thousands separator setting', (tester) async {
      await pumpInApp(
        tester,
        TransactionRow(
          transaction: tx(120000, TransactionType.income),
          category: food,
        ),
        money: const MoneyFormatter(grouping: false),
      );
      expect(find.text('+Rs. 120000'), findsOneWidget);
    });
  });

  testWidgets('AppSegmented reports taps', (tester) async {
    var selected = 'a';
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: themeById('indigo').themeData(Brightness.light),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => AppSegmented<String>(
              value: selected,
              segments: const [
                AppSegment('a', 'Expense'),
                AppSegment('b', 'Income'),
              ],
              onChanged: (v) => setState(() => selected = v),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Income'));
    await tester.pump();
    expect(selected, 'b');
  });

  group('SettingsRow', () {
    testWidgets('Soon rows show the badge and ignore taps', (tester) async {
      await pumpInApp(
        tester,
        const SettingsRow.soon(icon: Icons.language, label: 'Language'),
      );
      expect(find.text('Soon'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('links show their value and respond to taps', (tester) async {
      var tapped = false;
      await pumpInApp(
        tester,
        SettingsRow(
          icon: Icons.payments_outlined,
          label: 'Currency',
          value: 'PKR · Rs.',
          onTap: () => tapped = true,
        ),
      );
      expect(find.text('PKR · Rs.'), findsOneWidget);
      await tester.tap(find.text('Currency'));
      expect(tapped, isTrue);
    });

    testWidgets('toggles flip when the row is tapped', (tester) async {
      bool? value;
      await pumpInApp(
        tester,
        SettingsRow(
          icon: Icons.numbers,
          label: 'Thousands separator',
          kind: SettingsRowKind.toggle,
          toggleValue: true,
          onToggle: (v) => value = v,
        ),
      );
      await tester.tap(find.text('Thousands separator'));
      expect(value, isFalse);
    });

    testWidgets('PRO rows show the badge', (tester) async {
      await pumpInApp(
        tester,
        SettingsRow(
          icon: Icons.api,
          label: 'API access',
          kind: SettingsRowKind.pro,
          onTap: () {},
        ),
      );
      expect(find.text('PRO'), findsOneWidget);
    });
  });

  testWidgets('EmptyState offers its next step', (tester) async {
    var tapped = false;
    await pumpInApp(
      tester,
      EmptyState(
        icon: Icons.receipt_long,
        title: 'No transactions yet',
        actionLabel: 'Add your first transaction',
        onAction: () => tapped = true,
      ),
    );
    await tester.tap(find.text('Add your first transaction'));
    expect(tapped, isTrue);
  });

  testWidgets('components render in dark mode', (tester) async {
    await pumpInApp(
      tester,
      Column(
        children: [
          const TagBadge(
            '12% vs Aug',
            tone: BadgeTone.income,
            icon: Icons.arrow_downward,
          ),
          TransactionRow(
            transaction: tx(850, TransactionType.expense),
            category: food,
          ),
        ],
      ),
      brightness: Brightness.dark,
    );
    expect(tester.takeException(), isNull);
    expect(find.text('12% vs Aug'), findsOneWidget);
  });

  test('initials', () {
    expect(initialsFor('Alex Morgan', 'alex@example.com'), 'AM');
    expect(initialsFor('farhan ali haider', null), 'FA');
    expect(initialsFor('', 'test@email.com'), 'T');
    expect(initialsFor(null, null), '?');
  });

  test('dayLabel', () {
    final now = DateTime(2026, 9, 28, 15);
    expect(dayLabel(en, DateTime(2026, 9, 28, 8), now: now), 'Today');
    expect(dayLabel(en, DateTime(2026, 9, 27), now: now), 'Yesterday');
    expect(dayLabel(en, DateTime(2026, 9, 22), now: now), 'Tue, Sep 22');
    expect(dayLabel(en, DateTime(2025, 12, 31), now: now), 'Wed, Dec 31, 2025');
  });

  test('groupByDay keeps order and nets each day', () {
    TransactionModel at(int day, double amount, TransactionType type) =>
        TransactionModel(
          id: '$day$amount',
          title: '',
          amount: amount,
          type: type,
          date: DateTime(2026, 9, day, 12),
        );
    final buckets = groupByDay([
      at(28, 3450, TransactionType.expense),
      at(28, 850, TransactionType.expense),
      at(27, 120000, TransactionType.income),
      at(27, 1200, TransactionType.expense),
    ]);
    expect(buckets.map((b) => b.day.day), [28, 27]);
    expect(buckets[0].net, -4300);
    expect(buckets[1].net, 118800);
  });

  group('GroupedNumberFormatter', () {
    test('groups as you type and keeps two decimals', () {
      expect(GroupedNumberFormatter.formatText('60000'), '60,000');
      expect(GroupedNumberFormatter.formatText('1234.567'), '1,234.56');
      expect(GroupedNumberFormatter.formatText('12a3'), '123');
      expect(GroupedNumberFormatter.formatText('1.2.3'), '1.23');
      expect(GroupedNumberFormatter.formatText(''), '');
      expect(
        GroupedNumberFormatter.formatText('60000', grouping: false),
        '60000',
      );
    });
  });
}
