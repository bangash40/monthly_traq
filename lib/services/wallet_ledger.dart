import 'package:monthly_traq/models/wallet_models.dart';

/// One wallet's money: everything in it, and how much of that belongs to
/// other people.
class WalletBalance {
  final double total;
  final double others;

  const WalletBalance({this.total = 0, this.others = 0});

  /// The person's own share. Below zero when they've spent some of the
  /// money they're keeping for others.
  double get own => total - others;
}

/// Works out every wallet's balance and what's owed to each person from
/// the wallets, people and entries. Pure, so it's easy to test.
///
/// Spending comes out of a wallet as a whole, never out of one person's
/// money: what's owed to someone only goes down when money is given back
/// to them.
class WalletLedger {
  final Map<String, WalletBalance> _wallets;
  final Map<String, double> _owed;

  /// Per person, how their money is spread over the wallets.
  final Map<String, Map<String, double>> _placement;

  const WalletLedger._(this._wallets, this._owed, this._placement);

  static const empty = WalletLedger._({}, {}, {});

  factory WalletLedger.compute({
    required List<WalletModel> wallets,
    required List<PersonModel> people,
    required List<WalletEntry> entries,
  }) {
    final walletIds = [for (final w in wallets) w.id];
    final personIds = {for (final p in people) p.id};
    final totals = {for (final w in wallets) w.id: w.openingBalance};
    // Per person, per wallet: received there minus given back from there.
    final net = {for (final id in personIds) id: <String, double>{}};

    void addTo(String id, double amount) {
      if (totals.containsKey(id)) totals[id] = totals[id]! + amount;
    }

    for (final e in entries) {
      if (!totals.containsKey(e.walletId)) continue;
      switch (e.kind) {
        case WalletEntryKind.spend:
          addTo(e.walletId, -e.amount);
        case WalletEntryKind.add:
        case WalletEntryKind.adjust:
          addTo(e.walletId, e.amount);
        case WalletEntryKind.transfer:
          if (!totals.containsKey(e.toWalletId)) continue;
          addTo(e.walletId, -e.amount);
          addTo(e.toWalletId!, e.amount);
        case WalletEntryKind.receive:
        case WalletEntryKind.giveBack:
          final person = net[e.personId];
          if (person == null) continue;
          final signed = e.kind == WalletEntryKind.receive
              ? e.amount
              : -e.amount;
          addTo(e.walletId, signed);
          person[e.walletId] = (person[e.walletId] ?? 0) + signed;
      }
    }

    final owed = <String, double>{};
    final placement = <String, Map<String, double>>{};
    final others = {for (final id in walletIds) id: 0.0};
    for (final MapEntry(key: personId, value: byWallet) in net.entries) {
      owed[personId] = byWallet.values.fold(0.0, (a, b) => a + b);
      placement[personId] = _place(byWallet, walletIds);
      for (final MapEntry(key: walletId, value: amount)
          in placement[personId]!.entries) {
        others[walletId] = others[walletId]! + amount;
      }
    }

    return WalletLedger._(
      {
        for (final id in walletIds)
          id: WalletBalance(total: totals[id]!, others: others[id]!),
      },
      owed,
      placement,
    );
  }

  /// Where someone's money sits. Money given back from a wallet that held
  /// less of theirs (or none) comes off their money in the other wallets,
  /// in wallet order — so it never shows as a negative amount anywhere.
  static Map<String, double> _place(
    Map<String, double> byWallet,
    List<String> walletIds,
  ) {
    var shortfall = 0.0;
    final placed = <String, double>{};
    for (final id in walletIds) {
      final amount = byWallet[id] ?? 0;
      if (amount < 0) {
        shortfall -= amount;
      } else if (amount > 0) {
        placed[id] = amount;
      }
    }
    for (final id in walletIds) {
      if (shortfall <= 0) break;
      final amount = placed[id];
      if (amount == null) continue;
      final taken = amount < shortfall ? amount : shortfall;
      shortfall -= taken;
      if (amount - taken < 0.005) {
        placed.remove(id);
      } else {
        placed[id] = amount - taken;
      }
    }
    return placed;
  }

  WalletBalance of(String walletId) =>
      _wallets[walletId] ?? const WalletBalance();

  /// What's still owed back to [personId] (never below zero).
  double owedTo(String personId) {
    final owed = _owed[personId] ?? 0;
    return owed > 0 ? owed : 0;
  }

  /// Which wallets [personId]'s money is in, and how much in each.
  Map<String, double> placementOf(String personId) =>
      _placement[personId] ?? const {};

  /// Everyone with money in [walletId], and how much.
  Map<String, double> peopleIn(String walletId) => {
    for (final MapEntry(key: personId, value: byWallet) in _placement.entries)
      if ((byWallet[walletId] ?? 0) > 0) personId: byWallet[walletId]!,
  };

  double get total => _wallets.values.fold(0.0, (a, b) => a + b.total);
  double get others => _wallets.values.fold(0.0, (a, b) => a + b.others);
  double get own => total - others;
}
