import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A card the Home screen can show, in its default order.
enum HomeCard {
  balance(
    'Balance',
    'Your balance, with this month\'s income and spending',
    Icons.account_balance_wallet_outlined,
  ),
  wallets(
    'Wallets',
    'What\'s in your wallets, and money you\'re holding for others. '
        'Shows once you add a wallet.',
    Icons.account_balance_wallet,
  ),
  repayments(
    'Repayments',
    'What\'s due next on money you owe. Shows once you add a repayment.',
    Icons.event_repeat,
  ),
  budget(
    'Monthly budget',
    'How much of your budget is left',
    Icons.pie_chart_outline,
  ),
  dailyAllowance(
    'Daily allowance',
    'How much you can spend today and stay on budget. Needs a monthly '
        'budget.',
    Icons.today_outlined,
  ),
  topSpending(
    'Top spending',
    'Your three biggest categories this month',
    Icons.leaderboard_outlined,
  ),
  recent('Recent', 'Your latest transactions', Icons.receipt_long_outlined);

  final String label;
  final String description;
  final IconData icon;

  const HomeCard(this.label, this.description, this.icon);
}

/// Which Home cards show, and in what order. Every card is always in
/// [order] exactly once; hidden ones are skipped when Home is built.
@immutable
class HomeLayout {
  final List<HomeCard> order;
  final Set<HomeCard> hidden;

  const HomeLayout._(this.order, this.hidden);

  /// Extra cards that start switched off, so the default Home stays the
  /// classic balance → budget → top spending → recent.
  static const offByDefault = {
    HomeCard.dailyAllowance,
    HomeCard.wallets,
    HomeCard.repayments,
  };

  static final defaults = HomeLayout._(
    List.unmodifiable(HomeCard.values),
    Set.unmodifiable(offByDefault),
  );

  /// Cleans up [order]: drops repeats and adds any missing card in its
  /// default place, so every card is always listed.
  factory HomeLayout({
    required List<HomeCard> order,
    Set<HomeCard> hidden = const {},
  }) {
    final cleaned = <HomeCard>[
      ...{...order},
    ];
    // A card missing from [order] (new in this app version) goes right
    // after the card it follows by default — so a saved layout that was
    // otherwise the default stays the default — or first if nothing before
    // it is there.
    for (final (i, card) in HomeCard.values.indexed) {
      if (cleaned.contains(card)) continue;
      final before = HomeCard.values.take(i).toList().reversed;
      final anchor = before.where(cleaned.contains).firstOrNull;
      cleaned.insert(anchor == null ? 0 : cleaned.indexOf(anchor) + 1, card);
    }
    return HomeLayout._(List.unmodifiable(cleaned), Set.unmodifiable(hidden));
  }

  /// Reads the saved form; names this version doesn't know are ignored.
  /// A card added in a later version joins in its default place —
  /// switched off if it's one of the [offByDefault] extras.
  factory HomeLayout.fromNames(List<String>? order, List<String>? hidden) {
    if (order == null) return defaults;
    HomeCard? byName(String name) =>
        HomeCard.values.where((card) => card.name == name).firstOrNull;
    final saved = [...order.map(byName).nonNulls];
    return HomeLayout(
      order: saved,
      hidden: {
        ...?hidden?.map(byName).nonNulls,
        for (final card in offByDefault)
          if (!saved.contains(card)) card,
      },
    );
  }

  List<String> get orderNames => [for (final card in order) card.name];
  List<String> get hiddenNames => [for (final card in hidden) card.name];

  List<HomeCard> get visible => [
    for (final card in order)
      if (!hidden.contains(card)) card,
  ];

  bool isVisible(HomeCard card) => !hidden.contains(card);

  bool get isDefault => this == defaults;

  /// Whether [card]'s switch can be turned off — Home always keeps at least
  /// one card.
  bool canHide(HomeCard card) => !isVisible(card) || visible.length > 1;

  HomeLayout withVisibility(HomeCard card, bool show) {
    if (!show && !canHide(card)) return this;
    return HomeLayout(
      order: order,
      hidden: show ? ({...hidden}..remove(card)) : {...hidden, card},
    );
  }

  /// Moves the card at [from] so it ends up at index [to].
  HomeLayout moved(int from, int to) {
    final next = [...order];
    next.insert(to, next.removeAt(from));
    return HomeLayout(order: next, hidden: hidden);
  }

  @override
  bool operator ==(Object other) =>
      other is HomeLayout &&
      listEquals(other.order, order) &&
      setEquals(other.hidden, hidden);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(order), Object.hashAllUnordered(hidden));
}
