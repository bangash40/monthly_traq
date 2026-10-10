import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monthly_traq/app/app_settings.dart';
import 'package:monthly_traq/app/home_layout.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/budget_cycle.dart';
import 'package:monthly_traq/services/daily_allowance.dart';

void main() {
  group('HomeLayout', () {
    test('defaults are the classic Home, with extras switched off', () {
      final layout = HomeLayout.defaults;
      expect(layout.visible, [
        HomeCard.balance,
        HomeCard.budget,
        HomeCard.topSpending,
        HomeCard.recent,
      ]);
      expect(layout.isVisible(HomeCard.dailyAllowance), isFalse);
      expect(layout.isVisible(HomeCard.wallets), isFalse);
      expect(layout.order, HomeCard.values);
      expect(layout.isDefault, isTrue);
    });

    test('turning the daily allowance on puts it under the budget', () {
      final layout = HomeLayout.defaults.withVisibility(
        HomeCard.dailyAllowance,
        true,
      );
      expect(layout.visible, [
        HomeCard.balance,
        HomeCard.budget,
        HomeCard.dailyAllowance,
        HomeCard.topSpending,
        HomeCard.recent,
      ]);
      expect(layout.isDefault, isFalse);
    });

    test('turning Wallets on puts it under the balance', () {
      final layout = HomeLayout.defaults.withVisibility(HomeCard.wallets, true);
      expect(layout.visible.take(2), [HomeCard.balance, HomeCard.wallets]);
      expect(layout.isDefault, isFalse);
    });

    test('hiding and showing a card', () {
      final hidden = HomeLayout.defaults.withVisibility(
        HomeCard.topSpending,
        false,
      );
      expect(hidden.visible, isNot(contains(HomeCard.topSpending)));
      expect(hidden.order, HomeCard.values, reason: 'order is kept');
      expect(hidden.isDefault, isFalse);

      final shown = hidden.withVisibility(HomeCard.topSpending, true);
      expect(shown, HomeLayout.defaults);
    });

    test('the last visible card cannot be hidden', () {
      var layout = HomeLayout.defaults;
      for (final card in HomeCard.values.skip(1)) {
        // Already off by default, but switching it off again is harmless.
        layout = layout.withVisibility(card, false);
      }
      expect(layout.visible, [HomeCard.balance]);
      expect(layout.canHide(HomeCard.balance), isFalse);
      expect(layout.withVisibility(HomeCard.balance, false), layout);
    });

    test('moving a card', () {
      // Recent (last) to the top.
      final last = HomeCard.values.length - 1;
      final moved = HomeLayout.defaults.moved(last, 0);
      expect(moved.order, [
        HomeCard.recent,
        HomeCard.balance,
        HomeCard.wallets,
        HomeCard.repayments,
        HomeCard.goals,
        HomeCard.netWorth,
        HomeCard.budget,
        HomeCard.dailyAllowance,
        HomeCard.topSpending,
      ]);
      // Balance (first) to the end.
      expect(HomeLayout.defaults.moved(0, last).order.last, HomeCard.balance);
    });

    test('saves and loads by name', () {
      final layout = HomeLayout.defaults
          .moved(4, 0)
          .withVisibility(HomeCard.budget, false);
      final loaded = HomeLayout.fromNames(
        layout.orderNames,
        layout.hiddenNames,
      );
      expect(loaded, layout);
    });

    test('nothing saved yet gives the defaults', () {
      expect(HomeLayout.fromNames(null, null), HomeLayout.defaults);
    });

    test('unknown names are dropped and missing cards added at the end', () {
      final loaded = HomeLayout.fromNames(
        ['recent', 'someOldCard', 'balance', 'recent'],
        ['someOldCard'],
      );
      expect(loaded.order.first, HomeCard.recent);
      expect(loaded.order[1], HomeCard.balance);
      expect(loaded.order.toSet(), HomeCard.values.toSet());
      expect(loaded.order.length, HomeCard.values.length);
      // A missing extra card joins switched off; a missing classic one on.
      expect(loaded.hidden, HomeLayout.offByDefault);
    });

    test('a card new in this version slots into its default place', () {
      // A default layout saved before the Wallets card existed.
      final loaded = HomeLayout.fromNames(
        ['balance', 'budget', 'dailyAllowance', 'topSpending', 'recent'],
        ['dailyAllowance'],
      );
      expect(loaded.order[1], HomeCard.wallets);
      expect(loaded.isVisible(HomeCard.wallets), isFalse);
      expect(loaded.isDefault, isTrue);

      // A rearranged one keeps its order; Wallets still follows Balance.
      final custom = HomeLayout.fromNames(
        ['recent', 'balance', 'budget', 'dailyAllowance', 'topSpending'],
        ['dailyAllowance'],
      );
      expect(custom.order.take(3), [
        HomeCard.recent,
        HomeCard.balance,
        HomeCard.wallets,
      ]);
    });

    test('a saved layout keeps the allowance on if it was turned on', () {
      final on = HomeLayout.defaults.withVisibility(
        HomeCard.dailyAllowance,
        true,
      );
      expect(HomeLayout.fromNames(on.orderNames, on.hiddenNames), on);
    });
  });

  group('DailyAllowance', () {
    // A 30-day cycle: Sep 1 – Sep 30. "Now" is Sep 21, so 10 days are left
    // counting today.
    final cycle = BudgetCycle.containing(DateTime(2026, 9, 15), 1);
    final now = DateTime(2026, 9, 21, 14);

    var id = 0;
    TransactionModel spend(double amount, DateTime date) => TransactionModel(
      id: '${id++}',
      title: 'x',
      amount: amount,
      type: TransactionType.expense,
      date: date,
    );

    DailyAllowance? compute(double budget, List<TransactionModel> txs) =>
        DailyAllowance.compute(
          budget: budget,
          transactions: txs,
          cycle: cycle,
          now: now,
        );

    test('no budget means no allowance', () {
      expect(compute(0, []), isNull);
    });

    test('splits what was left before today over the days left', () {
      final a = compute(30000, [spend(10000, DateTime(2026, 9, 5))])!;
      expect(a.daysLeft, 10);
      expect(a.perDay, 2000);
      expect(a.spentToday, 0);
      expect(a.leftToday, 2000);
      expect(a.isOverToday, isFalse);
    });

    test('today\'s spending counts down against today\'s allowance', () {
      final a = compute(30000, [
        spend(10000, DateTime(2026, 9, 5)),
        spend(450, DateTime(2026, 9, 21, 9)),
      ])!;
      expect(a.perDay, 2000, reason: 'unchanged by spending today');
      expect(a.spentToday, 450);
      expect(a.leftToday, 1550);
    });

    test('going over today', () {
      final a = compute(30000, [
        spend(10000, DateTime(2026, 9, 5)),
        spend(2500, DateTime(2026, 9, 21)),
      ])!;
      expect(a.isOverToday, isTrue);
      expect(a.leftToday, -500);
    });

    test('rounds the daily amount down to whole units', () {
      final a = compute(10000, [])!;
      expect(a.perDay, 1000);
      expect(compute(10005, [])!.perDay, 1000);
    });

    test('budget already used up before today', () {
      final a = compute(5000, [spend(6000, DateTime(2026, 9, 2))])!;
      expect(a.budgetUsedUp, isTrue);
      expect(a.perDay, 0);
    });

    test('ignores income and other cycles', () {
      final a = compute(30000, [
        TransactionModel(
          id: 'salary',
          title: 'Salary',
          amount: 100000,
          type: TransactionType.income,
          date: DateTime(2026, 9, 1),
        ),
        spend(9999, DateTime(2026, 8, 31)),
      ])!;
      expect(a.perDay, 3000);
    });
  });

  group('MoneyFormatter.hidden', () {
    const money = MoneyFormatter(symbol: 'Rs.');

    test('masks the number but keeps the symbol and sign', () {
      expect(money.hidden.format(120000), 'Rs. ••••');
      expect(
        money.hidden.format(3450, sign: MoneySign.expense),
        '${kMinus}Rs. ••••',
      );
      expect(money.hidden.number(42), '••••');
    });

    test('the normal formatter is unchanged', () {
      expect(money.format(120000), 'Rs. 120,000');
      expect(money.hidden == money, isFalse);
    });
  });

  group('AppSettings home options', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('start with the classic Home and no privacy button', () {
      final settings = AppSettings(load: false);
      expect(settings.showPrivacyButton, isFalse);
      expect(settings.amountsHidden, isFalse);
      expect(settings.isDefaultHome, isTrue);
    });

    test('amounts only hide while the privacy button is on', () async {
      final settings = AppSettings(load: false);
      await settings.setHideAmounts(true);
      expect(settings.amountsHidden, isFalse);
      await settings.setShowPrivacyButton(true);
      expect(settings.amountsHidden, isTrue);
    });

    test('turning the privacy button off shows amounts again', () async {
      final settings = AppSettings(load: false);
      await settings.setShowPrivacyButton(true);
      await settings.setHideAmounts(true);
      await settings.setShowPrivacyButton(false);
      expect(settings.hideAmounts, isFalse);
      expect(settings.amountsHidden, isFalse);
    });

    test('reset restores the default Home', () async {
      final settings = AppSettings(load: false);
      await settings.setShowPrivacyButton(true);
      await settings.setHomeLayout(
        HomeLayout.defaults.withVisibility(HomeCard.dailyAllowance, true),
      );
      expect(settings.isDefaultHome, isFalse);
      await settings.resetHome();
      expect(settings.isDefaultHome, isTrue);
    });
  });
}
