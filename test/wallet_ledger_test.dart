import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_traq/models/wallet_models.dart';
import 'package:monthly_traq/services/wallet_ledger.dart';

WalletModel _wallet(String id, {double own = 0}) => WalletModel(
  id: id,
  name: id,
  icon: Icons.account_balance_wallet,
  color: Colors.blue,
  openingBalance: own,
);

PersonModel _person(String id) => PersonModel(id: id, name: id);

var _n = 0;
WalletEntry _entry(
  WalletEntryKind kind,
  String walletId,
  double amount, {
  String? person,
  String? to,
}) => WalletEntry(
  id: 'e${_n++}',
  kind: kind,
  walletId: walletId,
  toWalletId: to,
  personId: person,
  amount: amount,
  date: DateTime(2026, 10, 5),
);

WalletEntry _spend(String w, double a) => _entry(WalletEntryKind.spend, w, a);
WalletEntry _add(String w, double a) => _entry(WalletEntryKind.add, w, a);
WalletEntry _receive(String w, String p, double a) =>
    _entry(WalletEntryKind.receive, w, a, person: p);
WalletEntry _giveBack(String w, String p, double a) =>
    _entry(WalletEntryKind.giveBack, w, a, person: p);
WalletEntry _move(String from, String to, double a) =>
    _entry(WalletEntryKind.transfer, from, a, to: to);

void main() {
  test('a wallet starts at the own money it was added with', () {
    final ledger = WalletLedger.compute(
      wallets: [_wallet('jazz', own: 5000)],
      people: [],
      entries: [],
    );
    expect(ledger.of('jazz').total, 5000);
    expect(ledger.of('jazz').others, 0);
    expect(ledger.own, 5000);
  });

  test('the cousin example: spending never lowers what is owed', () {
    // Cousin gives 20,000; 3,000 is spent; he sends 9,000 more; 5,000 is
    // sent back to him.
    final ledger = WalletLedger.compute(
      wallets: [_wallet('jazz')],
      people: [_person('cousin')],
      entries: [
        _receive('jazz', 'cousin', 20000),
        _spend('jazz', 3000),
        _receive('jazz', 'cousin', 9000),
        _giveBack('jazz', 'cousin', 5000),
      ],
    );
    expect(ledger.of('jazz').total, 21000);
    expect(ledger.owedTo('cousin'), 24000);
    expect(ledger.of('jazz').others, 24000);
    expect(ledger.of('jazz').own, -3000);
    expect(ledger.own, -3000);
  });

  test('two people in one wallet keep separate accounts', () {
    final ledger = WalletLedger.compute(
      wallets: [_wallet('jazz', own: 5000)],
      people: [_person('cousin'), _person('friend')],
      entries: [
        _receive('jazz', 'cousin', 20000),
        _receive('jazz', 'friend', 10000),
        _spend('jazz', 8000),
        _giveBack('jazz', 'cousin', 5000),
        _receive('jazz', 'friend', 4000),
      ],
    );
    expect(ledger.of('jazz').total, 26000);
    expect(ledger.owedTo('cousin'), 15000);
    expect(ledger.owedTo('friend'), 14000);
    expect(ledger.of('jazz').own, -3000);
    expect(ledger.peopleIn('jazz'), {'cousin': 15000, 'friend': 14000});
  });

  test('adding own money raises only the own share', () {
    final ledger = WalletLedger.compute(
      wallets: [_wallet('jazz')],
      people: [_person('cousin')],
      entries: [
        _receive('jazz', 'cousin', 20000),
        _spend('jazz', 3000),
        _add('jazz', 3000),
      ],
    );
    expect(ledger.of('jazz').total, 20000);
    expect(ledger.of('jazz').own, 0);
    expect(ledger.owedTo('cousin'), 20000);
  });

  test('one person across two wallets shows one total and where it is', () {
    final ledger = WalletLedger.compute(
      wallets: [_wallet('jazz'), _wallet('easy')],
      people: [_person('cousin')],
      entries: [
        _receive('jazz', 'cousin', 20000),
        _receive('easy', 'cousin', 5000),
      ],
    );
    expect(ledger.owedTo('cousin'), 25000);
    expect(ledger.placementOf('cousin'), {'jazz': 20000, 'easy': 5000});
  });

  test('sending back from another wallet comes off their money elsewhere', () {
    final ledger = WalletLedger.compute(
      wallets: [_wallet('jazz'), _wallet('easy', own: 10000)],
      people: [_person('cousin')],
      entries: [
        _receive('jazz', 'cousin', 20000),
        _giveBack('easy', 'cousin', 5000),
      ],
    );
    expect(ledger.owedTo('cousin'), 15000);
    expect(ledger.placementOf('cousin'), {'jazz': 15000});
    expect(ledger.of('jazz').own, 5000);
    expect(ledger.of('easy').total, 5000);
    expect(ledger.of('easy').own, 5000);
    expect(ledger.own, 10000);
  });

  test('a fully returned person owes nothing and is in no wallet', () {
    final ledger = WalletLedger.compute(
      wallets: [_wallet('jazz')],
      people: [_person('cousin')],
      entries: [
        _receive('jazz', 'cousin', 20000),
        _giveBack('jazz', 'cousin', 20000),
      ],
    );
    expect(ledger.owedTo('cousin'), 0);
    expect(ledger.placementOf('cousin'), isEmpty);
    expect(ledger.peopleIn('jazz'), isEmpty);
  });

  test('moves change both wallets but not the total', () {
    final ledger = WalletLedger.compute(
      wallets: [_wallet('jazz', own: 10000), _wallet('easy')],
      people: [],
      entries: [_move('jazz', 'easy', 4000)],
    );
    expect(ledger.of('jazz').total, 6000);
    expect(ledger.of('easy').total, 4000);
    expect(ledger.total, 10000);
  });

  test('a correction adds its signed difference', () {
    final ledger = WalletLedger.compute(
      wallets: [_wallet('jazz', own: 10000)],
      people: [],
      entries: [_entry(WalletEntryKind.adjust, 'jazz', -1500)],
    );
    expect(ledger.of('jazz').total, 8500);
  });

  test('entries for deleted wallets or people are ignored', () {
    final ledger = WalletLedger.compute(
      wallets: [_wallet('jazz', own: 1000)],
      people: [],
      entries: [
        _spend('gone', 500),
        _receive('jazz', 'nobody', 9000),
        _move('jazz', 'gone', 300),
      ],
    );
    expect(ledger.of('jazz').total, 1000);
    expect(ledger.others, 0);
  });
}
