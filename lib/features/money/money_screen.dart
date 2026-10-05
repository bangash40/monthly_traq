import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/money/money_common.dart';
import 'package:monthly_traq/features/money/money_sheets.dart';
import 'package:monthly_traq/models/wallet_models.dart';
import 'package:monthly_traq/services/wallet_ledger.dart';
import 'package:monthly_traq/services/wallets_repository.dart';
import 'package:monthly_traq/widgets/ui.dart';

void _open(BuildContext context, Widget screen) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));

/// Profile → Wallets, and the Home card: every wallet, how much of the
/// money is the person's own and how much is other people's, and what's
/// owed to each of them. Separate from monthly income and spending.
class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final repo = context.watch<WalletsRepository>();
    final ledger = repo.ledger;
    final wallets = repo.wallets;
    final keeping = [
      for (final p in repo.people)
        if (ledger.owedTo(p.id) > 0) p,
    ]..sort((a, b) => ledger.owedTo(b.id).compareTo(ledger.owedTo(a.id)));
    final settled = [
      for (final p in repo.people)
        if (ledger.owedTo(p.id) <= 0) p,
    ];

    return SubPageScaffold(
      title: 'Wallets',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          if (wallets.isEmpty)
            EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Track your wallets',
              message:
                  'Add JazzCash, Easypaisa, your bank or cash to always know '
                  'what\'s in each — and how much of it is money you\'re '
                  'keeping for someone else.',
              actionLabel: 'Add a wallet',
              onAction: () => showWalletEditor(context),
            )
          else ...[
            BalanceSplitCard(
              label: 'In all wallets',
              total: ledger.total,
              others: ledger.others,
            ),
            const SizedBox(height: 16),
            const EntryActions(),
            const SizedBox(height: 24),
            SectionHeader(
              'Wallets',
              actionLabel: 'Add',
              onAction: () => showWalletEditor(context),
            ),
            const SizedBox(height: 8),
            GroupCard(
              children: [
                for (final w in wallets)
                  _WalletRow(
                    wallet: w,
                    balance: ledger.of(w.id),
                    onTap: () => _open(context, WalletScreen(walletId: w.id)),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SectionHeader(
              'Money you\'re keeping',
              actionLabel: 'Add',
              onAction: () =>
                  showEntrySheet(context, kind: WalletEntryKind.receive),
            ),
            const SizedBox(height: 8),
            if (keeping.isEmpty)
              Text(
                'When someone gives you money to keep, add it with Received. '
                'It stays in your wallet but isn\'t counted as yours.',
                style: AppText.body.copyWith(color: c.muted),
              )
            else
              GroupCard(
                children: [
                  for (final p in keeping)
                    PersonRow(person: p, ledger: ledger, wallets: wallets),
                ],
              ),
            if (settled.isNotEmpty) ...[
              const SizedBox(height: 24),
              const SectionHeader('All returned'),
              const SizedBox(height: 8),
              GroupCard(
                children: [
                  for (final p in settled)
                    PersonRow(person: p, ledger: ledger, wallets: wallets),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// A total split into the person's own money and other people's, with a
/// bar. "Yours" goes below zero when some of the others' money was spent.
class BalanceSplitCard extends StatelessWidget {
  final String label;
  final double total;
  final double others;
  final Widget? leading;

  const BalanceSplitCard({
    super.key,
    required this.label,
    required this.total,
    required this.others,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Text(label, style: AppText.body.copyWith(color: c.muted)),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              signedMoney(money, total),
              style: AppText.amountLarge.copyWith(fontSize: 32),
            ),
          ),
          const SizedBox(height: 14),
          SplitBar(own: total - others, others: others),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Legend(
                  color: c.accent,
                  label: 'Yours',
                  value: signedMoney(money, total - others),
                ),
              ),
              Expanded(
                child: _Legend(
                  color: othersColor,
                  label: 'Others\' money',
                  value: money.format(others),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A thin bar showing how much of the money is the person's own (accent)
/// vs other people's (blue).
class SplitBar extends StatelessWidget {
  final double own;
  final double others;

  const SplitBar({super.key, required this.own, required this.others});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ownPart = own > 0 ? own : 0.0;
    final total = ownPart + others;
    final ownShare = total <= 0 ? 0.0 : ownPart / total;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 8,
        child: total <= 0
            ? ColoredBox(color: c.surfaceHigh)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (ownShare > 0)
                    Expanded(
                      flex: (ownShare * 1000).round().clamp(1, 1000),
                      child: ColoredBox(color: c.accent),
                    ),
                  if (ownShare > 0 && ownShare < 1) const SizedBox(width: 2),
                  if (ownShare < 1)
                    Expanded(
                      flex: ((1 - ownShare) * 1000).round().clamp(1, 1000),
                      child: const ColoredBox(color: othersColor),
                    ),
                ],
              ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _Legend({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.label.copyWith(color: c.muted)),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value, style: AppText.statValue),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The four (or five) things that happen in a wallet, as round buttons.
/// With [walletId] they start on that wallet.
class EntryActions extends StatelessWidget {
  final String? walletId;

  const EntryActions({super.key, this.walletId});

  @override
  Widget build(BuildContext context) {
    final walletCount = context.select<WalletsRepository, int>(
      (r) => r.wallets.length,
    );
    Widget action(IconData icon, String label, WalletEntryKind kind) =>
        Expanded(
          child: _ActionButton(
            icon: icon,
            label: label,
            onTap: () =>
                showEntrySheet(context, kind: kind, walletId: walletId),
          ),
        );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        action(Icons.shopping_bag_outlined, 'Spent', WalletEntryKind.spend),
        action(Icons.add, 'Add', WalletEntryKind.add),
        action(Icons.call_received, 'Received', WalletEntryKind.receive),
        action(Icons.call_made, 'Send back', WalletEntryKind.giveBack),
        if (walletCount > 1)
          action(Icons.swap_horiz, 'Move', WalletEntryKind.transfer),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: c.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: c.primary, size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppText.label.copyWith(
                  color: c.ink,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletRow extends StatelessWidget {
  final WalletModel wallet;
  final WalletBalance balance;
  final VoidCallback onTap;

  const _WalletRow({
    required this.wallet,
    required this.balance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconTile(icon: wallet.icon, color: wallet.color, size: 46),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.name,
                    style: AppText.rowTitle.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    balance.others > 0
                        ? 'Others\' ${money.format(balance.others)}'
                        : 'All yours',
                    style: AppText.label.copyWith(color: c.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              signedMoney(money, balance.total),
              style: AppText.amount.copyWith(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: c.faint),
          ],
        ),
      ),
    );
  }
}

/// Someone whose money the person keeps: how much is owed back and which
/// wallets it's in. Tap for their account.
class PersonRow extends StatelessWidget {
  final PersonModel person;
  final WalletLedger ledger;
  final List<WalletModel> wallets;

  /// Show only the amount in this wallet (on a wallet's screen).
  final String? inWalletId;

  const PersonRow({
    super.key,
    required this.person,
    required this.ledger,
    required this.wallets,
    this.inWalletId,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final owed = ledger.owedTo(person.id);
    final placement = ledger.placementOf(person.id);
    final settled = owed <= 0;
    final amount = inWalletId == null
        ? owed
        : (placement[inWalletId] ?? 0).toDouble();
    final where = [
      for (final w in wallets)
        if (placement.containsKey(w.id)) w.name,
    ];
    final subtitle = settled
        ? 'All returned'
        : inWalletId != null
        ? (placement.length > 1
              ? 'Of ${money.format(owed)} in all'
              : 'All of it is here')
        : 'In ${where.join(', ')}';

    return InkWell(
      onTap: () => _open(context, PersonScreen(personId: person.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            PersonAvatar(name: person.name, muted: settled),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    style: AppText.rowTitle.copyWith(
                      fontSize: 16,
                      color: settled ? c.muted : c.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: AppText.label.copyWith(color: c.muted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (!settled)
              Text(
                money.format(amount),
                style: AppText.amount.copyWith(fontSize: 16),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: c.faint),
          ],
        ),
      ),
    );
  }
}

/// One wallet: its balance split, the actions, whose money is in it, and
/// everything that happened in it.
class WalletScreen extends StatelessWidget {
  final String walletId;

  const WalletScreen({super.key, required this.walletId});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final repo = context.watch<WalletsRepository>();
    final wallet = repo.walletById(walletId);
    if (wallet == null) {
      // Deleted (here or elsewhere): close this screen.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.maybePop(context);
      });
      return const Scaffold();
    }
    final ledger = repo.ledger;
    final balance = ledger.of(walletId);
    final peopleHere = ledger.peopleIn(walletId).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final activity = [
      for (final e in repo.entries.reversed)
        if (e.walletId == walletId || e.toWalletId == walletId) e,
    ];

    return SubPageScaffold(
      title: wallet.name,
      trailing: PopupMenuButton<String>(
        tooltip: 'Wallet options',
        icon: Icon(Icons.more_vert, color: c.ink),
        onSelected: (action) => action == 'edit'
            ? showWalletEditor(context, existing: wallet)
            : showCorrectBalanceSheet(context, wallet, balance.total),
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit wallet')),
          PopupMenuItem(value: 'correct', child: Text('Correct balance')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          BalanceSplitCard(
            label: 'Balance',
            total: balance.total,
            others: balance.others,
            leading: IconTile(icon: wallet.icon, color: wallet.color, size: 40),
          ),
          const SizedBox(height: 16),
          EntryActions(walletId: walletId),
          if (peopleHere.isNotEmpty) ...[
            const SizedBox(height: 24),
            const SectionHeader('Others\' money in it'),
            const SizedBox(height: 8),
            GroupCard(
              children: [
                for (final MapEntry(key: personId) in peopleHere)
                  if (repo.personById(personId) case final person?)
                    PersonRow(
                      person: person,
                      ledger: ledger,
                      wallets: repo.wallets,
                      inWalletId: walletId,
                    ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          const SectionHeader('Activity'),
          const SizedBox(height: 8),
          if (activity.isEmpty)
            Text(
              'What you spend, add, receive or send back in ${wallet.name} '
              'shows up here.',
              style: AppText.body.copyWith(color: c.muted),
            )
          else
            GroupCard(
              children: [
                for (final e in activity.take(60))
                  EntryRow(entry: e, walletId: walletId),
              ],
            ),
        ],
      ),
    );
  }
}

/// Someone's account: what's owed back to them, where it is, and every
/// time money came from them or went back.
class PersonScreen extends StatelessWidget {
  final String personId;

  const PersonScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final repo = context.watch<WalletsRepository>();
    final person = repo.personById(personId);
    if (person == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.maybePop(context);
      });
      return const Scaffold();
    }
    final ledger = repo.ledger;
    final owed = ledger.owedTo(personId);
    final placement = ledger.placementOf(personId);
    final history = [
      for (final e in repo.entries.reversed)
        if (e.personId == personId) e,
    ];

    return SubPageScaffold(
      title: person.name,
      trailing: IconButton(
        tooltip: 'Edit person',
        onPressed: () => showPersonEditor(context, person),
        icon: Icon(Icons.edit_outlined, color: c.ink),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PersonAvatar(name: person.name, radius: 20),
                    const SizedBox(width: 12),
                    Text(
                      owed > 0 ? 'You\'re keeping' : 'All returned',
                      style: AppText.body.copyWith(color: c.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    money.format(owed),
                    style: AppText.amountLarge.copyWith(fontSize: 32),
                  ),
                ),
                for (final w in repo.wallets)
                  if (placement[w.id] case final amount?) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconTile(icon: w.icon, color: w.color, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'In ${w.name}',
                            style: AppText.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(money.format(amount), style: AppText.statValue),
                      ],
                    ),
                  ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showEntrySheet(
                    context,
                    kind: WalletEntryKind.receive,
                    personId: personId,
                  ),
                  icon: const Icon(Icons.call_received),
                  label: const Text('Received'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => showEntrySheet(
                    context,
                    kind: WalletEntryKind.giveBack,
                    personId: personId,
                  ),
                  icon: const Icon(Icons.call_made),
                  label: const Text('Send back'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader('History'),
          const SizedBox(height: 8),
          GroupCard(
            children: [
              for (final e in history) EntryRow(entry: e, showWallet: true),
            ],
          ),
        ],
      ),
    );
  }
}

/// One wallet entry. On a wallet's screen ([walletId]) moves read as "to"
/// or "from" that wallet; [showWallet] adds the wallet's name. Tap to edit.
class EntryRow extends StatelessWidget {
  final WalletEntry entry;
  final String? walletId;
  final bool showWallet;

  const EntryRow({
    super.key,
    required this.entry,
    this.walletId,
    this.showWallet = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final repo = context.watch<WalletsRepository>();
    final e = entry;
    final person = repo.personById(e.personId)?.name ?? 'someone';
    final walletName = repo.walletById(e.walletId)?.name ?? 'a wallet';
    final movedIn =
        e.kind == WalletEntryKind.transfer && e.toWalletId == walletId;

    final (IconData icon, String title, double amount) = switch (e.kind) {
      WalletEntryKind.spend => (
        Icons.shopping_bag_outlined,
        e.note ?? 'Spent',
        -e.amount,
      ),
      WalletEntryKind.add => (
        Icons.add,
        e.note ?? 'Added your money',
        e.amount,
      ),
      WalletEntryKind.receive => (
        Icons.call_received,
        'Received from $person',
        e.amount,
      ),
      WalletEntryKind.giveBack => (
        Icons.call_made,
        'Sent back to $person',
        -e.amount,
      ),
      WalletEntryKind.transfer when movedIn => (
        Icons.swap_horiz,
        'Moved from $walletName',
        e.amount,
      ),
      WalletEntryKind.transfer => (
        Icons.swap_horiz,
        'Moved to ${repo.walletById(e.toWalletId)?.name ?? 'a wallet'}',
        -e.amount,
      ),
      WalletEntryKind.adjust => (Icons.tune, 'Balance corrected', e.amount),
    };
    // The note shows under the title unless it already is the title.
    final noteIsTitle =
        e.kind == WalletEntryKind.spend || e.kind == WalletEntryKind.add;
    final subtitle = [
      DateFormat(e.date.year == DateTime.now().year ? 'd MMM' : 'd MMM y')
          .format(e.date),
      if (showWallet) walletName,
      if (!noteIsTitle && e.note != null) e.note!,
    ].join(' · ');

    return InkWell(
      onTap: () => showEntrySheet(context, existing: e),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconTile(icon: icon, color: c.muted, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.rowTitle.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: AppText.label.copyWith(color: c.muted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              money.format(
                amount,
                sign: amount >= 0 ? MoneySign.income : MoneySign.expense,
              ),
              style: AppText.amount.copyWith(
                fontSize: 16,
                color: amount >= 0 ? c.income : c.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
